module treerender.geometry.loader.obj;

import std.array;
import std.container.array;
import std.exception;
import std.file;
import std.stdio;
import std.typecons;
import treerender.geometry.mesh;
import treerender.math.vector;

Mesh!NoData loadObj(string file) {
  writeln("Opening obj file ", file, "...");

  alias ti3 = Tuple!(uint, uint, uint);
  auto vertexIndicies = Array!ti3();
  auto uvIndicies =Array!ti3();
  auto normalIndicies =Array!ti3();

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

      vertexIndicies.insert(tuple(vertexIndex[0], vertexIndex[1], vertexIndex[2]));
      uvIndicies.insert(tuple(uvIndex[0], uvIndex[1], uvIndex[2]));
      normalIndicies.insert(tuple(normalIndex[0], normalIndex[1], normalIndex[2]));
    } else {
      // probably a comment, eat line
      f.readln();
    }
  }

  auto unpackedVerticies = Array!v3f();
  auto unpackedUvs = Array!v2f();
  auto unpackedNormals = Array!v3f();
  auto unpackedIndecies = Array!(PrimIndex!(Primitive.triangles))();
  uint[ti3] index;

  // For each vertex of each triangle
  uint j = 0;
  for(size_t i=0; i<vertexIndicies.length; i++) {
    // Get the indices of its attributes
    auto vertexIndex = vertexIndicies[i];
    auto uvIndex = uvIndicies[i];
    auto normalIndex = normalIndicies[i];

    // Calculate index
    uint updateIndex(size_t k)(ti3 vi, ti3 ui, ti3 ni) {
      auto key = tuple(vi[k], ui[k], ni[k]);
      if(key in index) {
        return index[key];
      } else {
        // Put the attributes in buffers
        unpackedVerticies.insert(vertecies[vertexIndex[k] - 1]);
        unpackedUvs.insert(uvs[uvIndex[k] - 1]);
        unpackedNormals.insert(normals[normalIndex[k] - 1]);

        index[key] = j;
        j += 1;
        return j-1;
      }
    }
    auto k1 = updateIndex!0(vertexIndex, uvIndex, normalIndex);
    auto k2 = updateIndex!1(vertexIndex, uvIndex, normalIndex);
    auto k3 = updateIndex!2(vertexIndex, uvIndex, normalIndex);
    unpackedIndecies.insert(PrimIndex!(Primitive.triangles)(k1, k2, k3));
  }

  return Mesh!NoData(unpackedVerticies, unpackedNormals, unpackedUvs, Array!NoData(), unpackedIndecies);
}
