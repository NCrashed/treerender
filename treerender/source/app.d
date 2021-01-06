import bindbc.opengl;
import bindbc.sdl;
import core.time;
import std.math;
import std.stdio;
import std.random;

import treerender.geometry.color;
import treerender.geometry.cube;
import treerender.geometry.greedy;
import treerender.geometry.loader.obj;
import treerender.geometry.mesh;
import treerender.geometry.voxel;
import treerender.input;
import treerender.math;
import treerender.render;
import treerender.world;

/* Import the sharedlib module for error handling. Assigning an alias
 ensures the function names do not conflict with other public APIs
 and makes it obvious that the functions belong to the loader rather
 than bindbc.sdl. */
import loader = bindbc.loader.sharedlib;

/// Iterate through user input and window events
bool processEvents(ref InputEvents events, ref WindowSize viewport) {
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
					viewport.width = event.window.data1;
					viewport.height = event.window.data2;
					break;
				case SDL_WINDOWEVENT_SIZE_CHANGED:
					viewport.width = event.window.data1;
					viewport.height = event.window.data2;
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

	auto winSize = WindowSize(v2i(1480, 1024));
	const windowFlags = SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN; // SDL_WINDOW_RESIZABLE
	auto window = SDL_CreateWindow("No existonce", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, winSize.width, winSize.height, windowFlags);
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
	glClearColor(0.0f, 0.0f, 0.212f, 0.0f);

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

	// auto mesh = loadObj("./assets/model/suzanne.obj");
	// auto mesh = makeCube();
	enum gridSize = 32;
	auto grid = Voxels!(Color, gridSize).replicate(Color.empty);
	enum n = 30000;
	foreach(i; 0..n) {
		auto x = uniform(0, gridSize);
		auto y = uniform(0, gridSize);
		auto z = uniform(0, gridSize);
		grid[x, y, z] = Color.red;
	}
	auto mesh = grid.greedyTriangulate!(Primitive.triangles);

	// Here we define which components are supported by the world
	auto world = new World("./assets");
	world.storages.windowSize.global = winSize;

	auto fps_file = File("fps.out", "w");
	auto i = 1;
	auto quit = false;
	auto input_events = InputEvents();

	SDL_GL_SetSwapInterval(0); // Disable VSync

	GLuint vertexbuffer;
	glGenBuffers(1, &vertexbuffer);
	scope(exit) glDeleteBuffers(1, &vertexbuffer);
	glBindBuffer(GL_ARRAY_BUFFER, vertexbuffer);
	glBufferData(GL_ARRAY_BUFFER, mesh.vertices.length * v3f.sizeof, &mesh.vertices[0], GL_STATIC_DRAW);

	GLuint uvbuffer;
	glGenBuffers(1, &uvbuffer);
	scope(exit) glDeleteBuffers(1, &uvbuffer);
	glBindBuffer(GL_ARRAY_BUFFER, uvbuffer);
	glBufferData(GL_ARRAY_BUFFER, mesh.uvs.length * v2f.sizeof, &mesh.uvs[0], GL_STATIC_DRAW);

	GLuint normalbuffer;
	glGenBuffers(1, &normalbuffer);
	scope(exit) glDeleteBuffers(1, &normalbuffer);
	glBindBuffer(GL_ARRAY_BUFFER, normalbuffer);
	glBufferData(GL_ARRAY_BUFFER, mesh.normals.length * v3f.sizeof, &mesh.normals[0], GL_STATIC_DRAW);

	GLuint colorbuffer;
	glGenBuffers(1, &colorbuffer);
	scope(exit) glDeleteBuffers(1, &colorbuffer);
	glBindBuffer(GL_ARRAY_BUFFER, colorbuffer);
	glBufferData(GL_ARRAY_BUFFER, mesh.data.length * mesh.Data.sizeof, &mesh.data[0], GL_STATIC_DRAW);

	// Generate a buffer for the indices as well
	GLuint elementbuffer;
	glGenBuffers(1, &elementbuffer);
	scope(exit) glDeleteBuffers(1, &elementbuffer);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, elementbuffer);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, mesh.indices.length * 3 * uint.sizeof, &mesh.indices[0] , GL_STATIC_DRAW);

	// Get a handle for our "LightPosition" uniform
	glUseProgram(programId);
	GLuint lightId = glGetUniformLocation(programId, "LightPosition_worldspace");

	float angle = 0;
	while (!quit) {
		immutable t1 = MonoTime.currTime();
		quit = processEvents(input_events, world.storages.windowSize.global);

		// world.render();
		auto mcam = world.activeCamera;
		if (mcam.isNull) continue;
		auto cam = mcam.get;
		cam.aspect = world.storages.windowSize.global.aspect;
		writeln(cam.view);
		writeln(lookAtMatrix!float(v3f(-0.5, -0.5, 2), v3f(0, 0, 0), v3f(0, 0, 1)));

		// Clear the screen
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		// Use our shader
		glUseProgram(programId);

		// Compute the MVP matrix from keyboard and mouse input
		const mat4 viewMatrix = cam.view;
		const mat4 modelMatrix = quatf.fromAxis(v3f(-1, -1, -1), angle).matrix * translation(v3f(-0.5, -0.5, -0.5));
		const mat4 mvp = cam.projection * viewMatrix * modelMatrix;

		// Send our transformation to the currently bound shader,
		// in the "MVP" uniform
		glUniformMatrix4fv(matrixId, 1, GL_TRUE, mvp.data.ptr);
		glUniformMatrix4fv(modelMatrixId, 1, GL_TRUE, modelMatrix.data.ptr);
		glUniformMatrix4fv(viewMatrixId, 1, GL_TRUE, viewMatrix.data.ptr);

		auto lightPos = v3f(-4,-4,4);
		glUniform3f(lightId, lightPos.x, lightPos.y, lightPos.z);

		// 1rst attribute buffer : vertices
		glEnableVertexAttribArray(0);
		glBindBuffer(GL_ARRAY_BUFFER, vertexbuffer);
		glVertexAttribPointer(
			0,                  // attribute
			3,                  // size
			GL_FLOAT,           // type
			GL_FALSE,           // normalized?
			0,                  // stride
			null                // array buffer offset
		);

		// 2nd attribute buffer : UVs
		glEnableVertexAttribArray(1);
		glBindBuffer(GL_ARRAY_BUFFER, uvbuffer);
		glVertexAttribPointer(
			1,                                // attribute
			2,                                // size
			GL_FLOAT,                         // type
			GL_FALSE,                         // normalized?
			0,                                // stride
			null                             // array buffer offset
		);

		// 3rd attribute buffer : normals
		glEnableVertexAttribArray(2);
		glBindBuffer(GL_ARRAY_BUFFER, normalbuffer);
		glVertexAttribPointer(
			2,                                // attribute
			3,                                // size
			GL_FLOAT,                         // type
			GL_FALSE,                         // normalized?
			0,                                // stride
			null                              // array buffer offset
		);

		// 4rd attribute buffer : colors
		glEnableVertexAttribArray(3);
		glBindBuffer(GL_ARRAY_BUFFER, colorbuffer);
		glVertexAttribPointer(
			3,                                // attribute
			4,                                // size
			GL_FLOAT,                         // type
			GL_FALSE,                         // normalized?
			0,                                // stride
			null                              // array buffer offset
		);

		// Index buffer
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, elementbuffer);

		// Draw the triangles !
		final switch(mesh.primitive) {
			case(Primitive.triangles): {
				glDrawElements(
					GL_TRIANGLES,                         // mode
					3 * cast(uint)mesh.indices.length,    // count
					GL_UNSIGNED_INT,                      // type
					null                                  // element array buffer offset
				);
				break;
			}
			case(Primitive.lines): {
				glDrawElements(
					GL_LINES,                             // mode
					2 * cast(uint)mesh.indices.length,    // count
					GL_UNSIGNED_INT,                      // type
					null                                  // element array buffer offset
				);
				break;
			}
		}

		SDL_GL_SwapWindow(window);

		glDisableVertexAttribArray(0);
		glDisableVertexAttribArray(1);
		glDisableVertexAttribArray(2);
		glDisableVertexAttribArray(3);

		immutable t2 = MonoTime.currTime();
		immutable dt = cast(float)(t2 - t1).total!"usecs"() / 1000_000;
		world.step(dt, input_events);
		world.maintain();

		angle += dt;

		immutable fps = 1 / dt;
		i += 1;
		if (i % 1000 == 0) {
			SDL_Log("%f", fps);
			fps_file.writeln(i,",",fps);
		}
	}
}
