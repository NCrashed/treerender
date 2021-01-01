module treerender.geometry.cube;

import treerender.geometry.mesh;
import treerender.math.v2;
import treerender.math.v3;

Mesh!NoData makeCube() {
  auto mesh = Mesh!NoData.allocate(12);
  mesh.insertVertex(v3f( 1,  1, -1), v3f( 0,  0, -1), v2f(0.748573, 0.750412), NoData());
  mesh.insertVertex(v3f( 1, -1, -1), v3f( 0,  0, -1), v2f(0.749279, 0.501284), NoData());
  mesh.insertVertex(v3f(-1, -1, -1), v3f( 0,  0, -1), v2f(0.999110, 0.501077), NoData());
  mesh.insertVertex(v3f(-1,  1, -1), v3f( 0,  0, -1), v2f(0.999455, 0.750380), NoData());
  mesh.insertTriangle(v3u(0, 1, 2));
  mesh.insertTriangle(v3u(0, 2, 3));

  mesh.insertVertex(v3f(-1, -1,  1), v3f(-1,  0, 0), v2f(0.250471, 0.500702), NoData());
  mesh.insertVertex(v3f(-1,  1,  1), v3f(-1,  0, 0), v2f(0.249682, 0.749677), NoData());
  mesh.insertVertex(v3f(-1,  1, -1), v3f(-1,  0, 0), v2f(0.001085, 0.750380), NoData());
  mesh.insertVertex(v3f(-1, -1, -1), v3f(-1,  0, 0), v2f(0.001517, 0.499994), NoData());
  mesh.insertTriangle(v3u(4, 5, 6));
  mesh.insertTriangle(v3u(4, 6, 7));

  mesh.insertVertex(v3f( 1, -1,  1), v3f( 0,  0, 1), v2f(0.499422, 0.500239), NoData());
  mesh.insertVertex(v3f( 1,  1,  1), v3f( 0,  0, 1), v2f(0.500149, 0.750166), NoData());
  mesh.insertVertex(v3f(-1, -1,  1), v3f( 0,  0, 1), v2f(0.250471, 0.500702), NoData());
  mesh.insertVertex(v3f(-1,  1,  1), v3f( 0,  0, 1), v2f(0.249682, 0.749677), NoData());
  mesh.insertTriangle(v3u(8, 9, 10));
  mesh.insertTriangle(v3u(9, 11, 10));

  mesh.insertVertex(v3f( 1, -1, -1), v3f( 1,  0, 0), v2f(0.748573, 0.750412), NoData());
  mesh.insertVertex(v3f( 1,  1, -1), v3f( 1,  0, 0), v2f(0.749279, 0.501284), NoData());
  mesh.insertVertex(v3f( 1, -1,  1), v3f( 1,  0, 0), v2f(0.499422, 0.500239), NoData());
  mesh.insertVertex(v3f( 1,  1,  1), v3f( 1,  0, 0), v2f(0.500149, 0.750166), NoData());
  mesh.insertTriangle(v3u(12, 13, 14));
  mesh.insertTriangle(v3u(13, 15, 14));

  mesh.insertVertex(v3f( 1,  1, -1), v3f( 0,  1, 0), v2f(0.748573, 0.750412), NoData());
  mesh.insertVertex(v3f(-1,  1, -1), v3f( 0,  1, 0), v2f(0.748355, 0.998230), NoData());
  mesh.insertVertex(v3f( 1,  1,  1), v3f( 0,  1, 0), v2f(0.500149, 0.750166), NoData());
  mesh.insertVertex(v3f(-1,  1,  1), v3f( 0,  1, 0), v2f(0.500193, 0.998728), NoData());
  mesh.insertTriangle(v3u(16, 17, 18));
  mesh.insertTriangle(v3u(17, 19, 18));

  mesh.insertVertex(v3f( 1, -1, -1), v3f( 0, -1, 0), v2f(0.749279, 0.501284), NoData());
  mesh.insertVertex(v3f( 1, -1,  1), v3f( 0, -1, 0), v2f(0.499422, 0.500239), NoData());
  mesh.insertVertex(v3f(-1, -1,  1), v3f( 0, -1, 0), v2f(0.498993, 0.250415), NoData());
  mesh.insertVertex(v3f(-1, -1, -1), v3f( 0, -1, 0), v2f(0.748953, 0.250920), NoData());
  mesh.insertTriangle(v3u(20, 21, 22));
  mesh.insertTriangle(v3u(20, 22, 23));

  return mesh;
}
