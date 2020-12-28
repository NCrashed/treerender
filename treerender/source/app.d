import bindbc.sdl;
import bindbc.opengl;
import core.time;
import std.stdio;

import treerender.input;
import treerender.v2;
import treerender.world;

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

	immutable flags = 0;
	immutable initted = Mix_Init(flags);
	if ((initted & flags) != flags) {
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

	auto window_size = v2i(1480, 1024);
	auto screen = SDL_CreateWindow("No existonce", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, window_size.x, window_size.y, SDL_WINDOW_OPENGL);
	if (!screen) {
		SDL_Log("SDL window creation error: %s\n", SDL_GetError());
		return;
	}
	scope(exit) SDL_DestroyWindow(screen);

	auto renderer = SDL_CreateRenderer(screen, -1, SDL_RENDERER_ACCELERATED);
	if (!renderer) {
		SDL_Log("Unable to create renderer: %s\n", SDL_GetError());
		return;
	}
	scope(exit) SDL_DestroyRenderer(renderer);

	// Here we define which components are supported by the world
	auto w = new World("./assets");

	auto fps_file = File("fps.out", "w");
	auto i = 1;
	auto quit = false;
	auto input_events = InputEvents();

	while (!quit) {
		immutable t1 = MonoTime.currTime();
		quit = process_events(input_events, window_size);

		SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
		SDL_RenderClear(renderer);
		SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
		w.render(renderer);
		SDL_RenderPresent(renderer);

		immutable t2 = MonoTime.currTime();
		immutable dt = cast(float)(t2 - t1).total!"usecs"() / 1000_000;
		w.step(dt, input_events);
		w.maintain();

		immutable fps = 1 / dt;
		i += 1;
		if (i % 1000 == 0) {
			SDL_Log("%f", fps);
			fps_file.writeln(i,",",fps);
		}
	}
}
