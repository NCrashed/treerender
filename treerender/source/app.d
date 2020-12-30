import bindbc.sdl;
import bindbc.opengl;
import core.time;
import std.stdio;

import treerender.input;
import treerender.v2;
import treerender.v3;
import treerender.world;
import treerender.render.model;
import treerender.render.shader;
import treerender.render.texture;

/* Import the sharedlib module for error handling. Assigning an alias
 ensures the function names do not conflict with other public APIs
 and makes it obvious that the functions belong to the loader rather
 than bindbc.sdl. */
import loader = bindbc.loader.sharedlib;

/// Iterate through user input and window events
bool process_events(ref InputEvents events, ref v2i viewport) {
	SDL_Event event = void;
	while (SDL_PollEvent(&event) != 0) {
		switch (event.type) {
			case SDL_QUIT: return true;
			case SDL_KEYDOWN: switch (event.key.keysym.sym) {
				case SDLK_ESCAPE: return true;
				case SDLK_w: events.playerForward = true; break;
				case SDLK_s: events.playerBack = true; break;
				case SDLK_a: events.playerLeft = true; break;
				case SDLK_d: events.playerRight = true; break;
				case SDLK_SPACE: events.playerPrimAction = true; break;
				default: {}
			} break;
			case SDL_KEYUP: switch (event.key.keysym.sym) {
				case SDLK_w: events.playerForward = false; break;
				case SDLK_s: events.playerBack = false; break;
				case SDLK_a: events.playerLeft = false; break;
				case SDLK_d: events.playerRight = false; break;
				case SDLK_SPACE: events.playerPrimAction = false; break;
				default: {}
			} break;
			case SDL_WINDOWEVENT: switch (event.window.event) {
				case SDL_WINDOWEVENT_RESIZED:
					viewport.x = event.window.data1;
					viewport.y = event.window.data2;
					break;
				case SDL_WINDOWEVENT_SIZE_CHANGED:
					viewport.x = event.window.data1;
					viewport.y = event.window.data2;
					break;
				default: {}
			} break;
			default: {}
		}
	}

	return false;
}

void main()
{
	if (SDL_Init(SDL_INIT_EVERYTHING)) {
		SDL_Log("SDL init error: %s\n", SDL_GetError());
		return;
	}
	scope(exit) SDL_Quit();

	const iflags = IMG_INIT_PNG | IMG_INIT_JPG;
	if ((IMG_Init(iflags) & iflags) != iflags) {
		SDL_Log("IMG_Init: %s\n", IMG_GetError());
		return;
	}
	scope(exit) IMG_Quit();

	const mflags = 0;
	const initted = Mix_Init(mflags);
	if ((initted & mflags) != mflags) {
		SDL_Log("Unable to initialize SDL Mixer: %s\n", SDL_GetError());
		return;
	}
	scope(exit) Mix_Quit();

	immutable audio_init = Mix_OpenAudio(11025, AUDIO_S16SYS, 2, 1024);
	if (audio_init < 0) {
		SDL_Log("Unable to create audio device: %s\n", Mix_GetError());
		return;
	}
	scope(exit) Mix_CloseAudio();

	SDL_GL_SetAttribute(SDL_GL_ACCELERATED_VISUAL, 1);
	SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
	SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
	SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);
	SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
	SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);

	auto window_size = v2i(1480, 1024);
	const windowFlags = SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN; // SDL_WINDOW_RESIZABLE
	auto window = SDL_CreateWindow("No existonce", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, window_size.x, window_size.y, windowFlags);
	if (!window) {
		SDL_Log("SDL window creation error: %s\n", SDL_GetError());
		return;
	}
	scope(exit) SDL_DestroyWindow(window);

	auto context = SDL_GL_CreateContext(window);
	if (!context) {
		SDL_Log("SDL context creation error: %s\n", SDL_GetError());
		return;
	}
	scope(exit) SDL_GL_DeleteContext(context);

	const GLSupport openglLoaded = loadOpenGL();
	if (openglLoaded < GLSupport.gl33) {
		writeln("Error loading OpenGL shared library ", openglLoaded);
		// Log the error info
		foreach(info; loader.errors) {
			// A hypothetical logging routine
			writeln(info.error, info.message);
		}
		return;
	}
	SDL_GL_MakeCurrent(window, context);

	int w,h;
	SDL_GetWindowSize(window, &w, &h);
	glViewport(0, 0, w, h);
	glClearColor(0.0f, 0.5f, 1.0f, 0.0f);

	glDepthFunc(GL_LESS);
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_CULL_FACE);

	GLuint vertexArrayId;
	glGenVertexArrays(1, &vertexArrayId);
	glBindVertexArray(vertexArrayId);
	scope(exit) glDeleteVertexArrays(1, &vertexArrayId);

	auto programId = loadShaders( "./assets/shader/standard_vertex.glsl", "./assets/shader/standard_fragment.glsl" );
	scope(exit) glDeleteProgram(programId);

	auto matrixId = glGetUniformLocation(programId, "MVP");
	auto viewMatrixId = glGetUniformLocation(programId, "V");
	auto modelMatrixId = glGetUniformLocation(programId, "M");

	auto texture = loadTexture("./assets/texture/test.jpg");
	scope(exit) glDeleteTextures(1, &texture);
	auto textureId = glGetUniformLocation(programId, "myTextureSampler");

	v3f[] verticies;
	v2f[] uvs;
	v3f[] normals;
	loadObj("./assets/model/cube.obj", verticies, uvs, normals);

	// Here we define which components are supported by the world
	auto world = new World("./assets");

	auto fps_file = File("fps.out", "w");
	auto i = 1;
	auto quit = false;
	auto input_events = InputEvents();

	SDL_GL_SetSwapInterval(0); // Disable VSync

	while (!quit) {
		immutable t1 = MonoTime.currTime();
		quit = process_events(input_events, window_size);

		world.render();
		SDL_GL_SwapWindow(window);

		immutable t2 = MonoTime.currTime();
		immutable dt = cast(float)(t2 - t1).total!"usecs"() / 1000_000;
		world.step(dt, input_events);
		world.maintain();

		immutable fps = 1 / dt;
		i += 1;
		if (i % 1000 == 0) {
			SDL_Log("%f", fps);
			fps_file.writeln(i,",",fps);
		}
	}
}
