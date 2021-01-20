module treerender.render.mesh;

import bindbc.opengl;
import treerender.geometry.mesh;
import treerender.math.vector;

struct MeshBuffers(T) {
  GLuint vertexbuffer;
  GLuint uvbuffer;
  GLuint normalbuffer;
  GLuint databuffer;
  GLuint elementbuffer;

  static MeshBuffers!T allocate(Mesh!T mesh) {
    MeshBuffers!T ret;

  	glGenBuffers(1, &ret.vertexbuffer);
  	glBindBuffer(GL_ARRAY_BUFFER, ret.vertexbuffer);
  	glBufferData(GL_ARRAY_BUFFER, mesh.vertices.length * v3f.sizeof, &mesh.vertices[0], GL_STATIC_DRAW);

  	glGenBuffers(1, &ret.uvbuffer);
  	glBindBuffer(GL_ARRAY_BUFFER, ret.uvbuffer);
  	glBufferData(GL_ARRAY_BUFFER, mesh.uvs.length * v2f.sizeof, &mesh.uvs[0], GL_STATIC_DRAW);

  	glGenBuffers(1, &ret.normalbuffer);
  	glBindBuffer(GL_ARRAY_BUFFER, ret.normalbuffer);
  	glBufferData(GL_ARRAY_BUFFER, mesh.normals.length * v3f.sizeof, &mesh.normals[0], GL_STATIC_DRAW);

  	glGenBuffers(1, &ret.databuffer);
  	glBindBuffer(GL_ARRAY_BUFFER, ret.databuffer);
  	glBufferData(GL_ARRAY_BUFFER, mesh.data.length * T.sizeof, &mesh.data[0], GL_STATIC_DRAW);

  	glGenBuffers(1, &ret.elementbuffer);
  	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ret.elementbuffer);
  	glBufferData(GL_ELEMENT_ARRAY_BUFFER, mesh.indices.length * 3 * uint.sizeof, &mesh.indices[0] , GL_STATIC_DRAW);

    return ret;
  }

  void dispose() {
    glDeleteBuffers(1, &vertexbuffer);
    glDeleteBuffers(1, &uvbuffer);
    glDeleteBuffers(1, &normalbuffer);
    glDeleteBuffers(1, &databuffer);
    glDeleteBuffers(1, &elementbuffer);
  }
}
