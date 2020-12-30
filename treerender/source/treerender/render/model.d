module treerender.render.model;

import std.array;
import std.container.array;
import std.exception;
import std.file;
import std.stdio;
import treerender.v2;
import treerender.v3;

void loadObj(string file, out v3f[] outVerticies, out v2f[] outUvs, out v3f[] outNormals) {
  writeln("Opening obj file ", file, "...");

  auto vertexIndicies = Array!uint();
  auto uvIndicies = Array!uint();
  auto normalIndicies = Array!uint();

  auto vertecies = Array!v3f();
  auto uvs = Array!v2f();
  auto normals = Array!v3f();

  auto f = File(file, "r");

  while(true) {
    string lineHeader;
    auto notEnd = f.readf!"%s "(lineHeader);
    if(!notEnd) break;

    if(lineHeader == "v") {
      v3f vertex;
      f.readf!"%f %f %f\n"(vertex.x, vertex.y, vertex.z);
      vertecies.insert(vertex);
    } else if(lineHeader == "vt") {
      v2f uv;
      f.readf!"%f %f\n"(uv.x, uv.y);
      uvs.insert(uv);
    } else if(lineHeader == "vn") {
      v3f normal;
      f.readf!"%f %f %f\n"(normal.x, normal.y, normal.z);
      normals.insert(normal);
    } else if(lineHeader == "f") {
      uint[3] vertexIndex, uvIndex, normalIndex;
      auto matches = f.readf!"%d/%d/%d %d/%d/%d %d/%d/%d\n"(
        vertexIndex[0], uvIndex[0], normalIndex[0],
        vertexIndex[1], uvIndex[1], normalIndex[1],
        vertexIndex[2], uvIndex[2], normalIndex[2]);
      enforce(matches == 9, "Failed to read face of format %d/%d/%d %d/%d/%d %d/%d/%d");

      vertexIndicies.insert(vertexIndex[0]);
      vertexIndicies.insert(vertexIndex[1]);
      vertexIndicies.insert(vertexIndex[2]);

      uvIndicies.insert(uvIndex[0]);
      uvIndicies.insert(uvIndex[1]);
      uvIndicies.insert(uvIndex[2]);

      normalIndicies.insert(normalIndex[0]);
      normalIndicies.insert(normalIndex[1]);
      normalIndicies.insert(normalIndex[2]);
    } else {
      // probably a comment, eat line
      f.readln();
    }
  }

  auto unpackedVerticies = Array!v3f();
  auto unpackedUvs = Array!v2f();
  auto unpackedNormals = Array!v3f();

  // For each vertex of each triangle
  for(size_t i=0; i<vertexIndicies.length; i++) {
    // Get the indices of its attributes
    auto vertexIndex = vertexIndicies[i];
    auto uvIndex = uvIndicies[i];
    auto normalIndex = normalIndicies[i];
    // Put the attributes in buffers
    unpackedVerticies.insert(vertecies[vertexIndex-1]);
    unpackedUvs.insert(uvs[uvIndex-1]);
    unpackedNormals.insert(normals[normalIndex-1]);
  }

  outVerticies = unpackedVerticies[].array;
  outUvs = unpackedUvs[].array;
  outNormals = unpackedNormals[].array;
}
