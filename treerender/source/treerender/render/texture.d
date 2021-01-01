module treerender.render.texture;

import bindbc.opengl;
import bindbc.sdl;
import std.exception;
import std.string;

GLuint loadTexture(string file) {
  SDL_Surface* imgSurf = IMG_Load(file.toStringz);
  if (imgSurf is null) {
    SDL_Log("IMG_Load: %s\n", IMG_GetError());
    enforce(false, "Failed to load texture ", file);
  }
  scope(exit) SDL_FreeSurface(imgSurf);

  glEnable(GL_TEXTURE_2D);
  GLuint textureId = 0;
  glGenTextures(1, &textureId);
  glBindTexture(GL_TEXTURE_2D, textureId);
  const mode = imgSurf.format.BytesPerPixel == 4 ? GL_RGBA : GL_RGB;
  glTexImage2D(GL_TEXTURE_2D, 0, mode, imgSurf.w, imgSurf.h, 0, mode, GL_UNSIGNED_BYTE, imgSurf.pixels);

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);

  return textureId;
}
