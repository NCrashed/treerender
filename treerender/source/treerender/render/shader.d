module treerender.render.shader;

import bindbc.opengl;
import std.exception;
import std.experimental.allocator;
import std.experimental.allocator.showcase;
import std.file;
import std.stdio;
import std.string;

GLuint loadShaders(string vertexFile, string fragmentFile) {
  StackFront!65536 stackAllocator;

  auto vertexShaderId = glCreateShader(GL_VERTEX_SHADER);
  scope(exit) glDeleteShader(vertexShaderId);

  auto fragmentShaderId = glCreateShader(GL_FRAGMENT_SHADER);
  scope(exit) glDeleteShader(fragmentShaderId);

  auto vertexShaderCode = readText(vertexFile);
  auto fragmentShaderCode = readText(fragmentFile);

  GLint result = GL_FALSE;
  int infoLogLength = 0;

  writeln("Compiling vertex shader ", vertexFile);
  auto vertexSourceC = vertexShaderCode.toStringz;
  glShaderSource(vertexShaderId, 1, &vertexSourceC, null);
  glCompileShader(vertexShaderId);

  glGetShaderiv(vertexShaderId, GL_COMPILE_STATUS, &result);
  glGetShaderiv(vertexShaderId, GL_INFO_LOG_LENGTH, &infoLogLength);
  if(infoLogLength > 0) {
    auto errorMsgC = stackAllocator.makeArray!char(infoLogLength+1);
    scope(exit) stackAllocator.dispose(errorMsgC);
    glGetShaderInfoLog(vertexShaderId, infoLogLength, null, &errorMsgC[0]);
    writeln(errorMsgC[0 .. $-1]);
    enforce(false, "Failed to compile vertex shader");
  }

  writeln("Compiling fragment shader ", fragmentFile);
  auto fragmentSourceC = fragmentShaderCode.toStringz;
  glShaderSource(fragmentShaderId, 1, &fragmentSourceC, null);
  glCompileShader(fragmentShaderId);

  glGetShaderiv(fragmentShaderId, GL_COMPILE_STATUS, &result);
  glGetShaderiv(fragmentShaderId, GL_INFO_LOG_LENGTH, &infoLogLength);
  if(infoLogLength > 0) {
    auto errorMsgC = stackAllocator.makeArray!char(infoLogLength+1);
    scope(exit) stackAllocator.dispose(errorMsgC);
    glGetShaderInfoLog(fragmentShaderId, infoLogLength, null, &errorMsgC[0]);
    writeln(errorMsgC[0 .. $-1]);
    enforce(false, "Failed to compile fragment shader");
  }

  writeln("Linking shader program...");
  auto programId = glCreateProgram();
  glAttachShader(programId, vertexShaderId);
  scope(exit) glDetachShader(programId, vertexShaderId);
  glAttachShader(programId, fragmentShaderId);
  scope(exit) glDetachShader(programId, fragmentShaderId);
  glLinkProgram(programId);

  glGetProgramiv(programId, GL_LINK_STATUS, &result);
  glGetProgramiv(programId, GL_INFO_LOG_LENGTH, &infoLogLength);
  if(infoLogLength > 0) {
    auto errorMsgC = stackAllocator.makeArray!char(infoLogLength+1);
    scope(exit) stackAllocator.dispose(errorMsgC);
    glGetProgramInfoLog(programId, infoLogLength, null, &errorMsgC[0]);
    writeln(errorMsgC[0 .. $-1]);
    enforce(false, "Failed to link shader");
  }

  return programId;
}
