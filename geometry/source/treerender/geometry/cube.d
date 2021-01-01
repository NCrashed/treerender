module treerender.geometry.cube;

import treerender.geometry.mesh;

Mesh!NoData makeCube() {
  auto mesh = Mesh!NoData.allocate(12);
  mes.insertVertex(v3f( 1,  1, -1), v3f( 0,  0, -1), v2f(0.748573, 0.750412));
  mes.insertVertex(v3f( 1, -1, -1), v3f( 0,  0, -1), v2f(0.749279, 0.501284));
  mes.insertVertex(v3f(-1, -1, -1), v3f( 0,  0, -1), v2f(0.999110, 0.501077));
  mes.insertVertex(v3f(-1,  1, -1), v3f( 0,  0, -1), v2f(0.999455, 0.750380));
  mes.insertTriangle(0, 1, 2);
  mes.insertTriangle(0, 2, 3);

  mes.insertVertex(v3f(-1, -1,  1), v3f(-1,  0, 0), v2f(0.250471, 0.500702));
  mes.insertVertex(v3f(-1,  1,  1), v3f(-1,  0, 0), v2f(0.249682, 0.749677));
  mes.insertVertex(v3f(-1,  1, -1), v3f(-1,  0, 0), v2f(0.001085, 0.750380));
  mes.insertVertex(v3f(-1, -1, -1), v3f(-1,  0, 0), v2f(0.001517, 0.499994));
  mes.insertTriangle(4, 5, 6);
  mes.insertTriangle(4, 6, 7);

  mes.insertVertex(v3f( 1, -1,  1), v3f( 0,  0, 1), v2f(0.499422, 0.500239));
  mes.insertVertex(v3f( 1,  1,  1), v3f( 0,  0, 1), v2f(0.500149, 0.750166));
  mes.insertVertex(v3f(-1, -1,  1), v3f( 0,  0, 1), v2f(0.250471, 0.500702));
  mes.insertVertex(v3f(-1,  1,  1), v3f( 0,  0, 1), v2f(0.249682, 0.749677));
  mes.insertTriangle(8, 9, 10);
  mes.insertTriangle(9, 11, 10);

  mes.insertVertex(v3f( 1, -1, -1), v3f( 1,  0, 0), v2f(0.749279, 0.501284));
  mes.insertVertex(v3f( 1,  1, -1), v3f( 1,  0, 0), v2f(0.749279, 0.501284));
  mes.insertVertex(v3f( 1, -1,  1), v3f( 1,  0, 0), v2f(0.499422, 0.500239));
  mes.insertVertex(v3f( 1,  1,  1), v3f( 1,  0, 0), v2f(0.500149, 0.750166));
  mes.insertTriangle(12, 13, 14);
  mes.insertTriangle(13, 15, 14);

  mes.insertVertex(v3f( 1,  1, -1), v3f( 0,  1, 0), v2f(0.748573, 0.750412));
  mes.insertVertex(v3f(-1,  1, -1), v3f( 0,  1, 0), v2f(0.748355, 0.998230));
  mes.insertVertex(v3f( 1,  1,  1), v3f( 0,  1, 0), v2f(0.500149, 0.750166));
  mes.insertVertex(v3f(-1,  1,  1), v3f( 0,  1, 0), v2f(0.500193, 0.998728));
  mes.insertTriangle(16, 17, 18);
  mes.insertTriangle(17, 19, 18);

  mes.insertVertex(v3f( 1, -1, -1), v3f( 0, -1, 0), v2f(0.749279, 0.501284));
  mes.insertVertex(v3f( 1, -1,  1), v3f( 0, -1, 0), v2f(0.499422, 0.500239));
  mes.insertVertex(v3f(-1, -1,  1), v3f( 0, -1, 0), v2f(0.498993, 0.250415));
  mes.insertVertex(v3f(-1, -1, -1), v3f( 0, -1, 0), v2f(0.748953, 0.250920));
  mes.insertTriangle(20, 21, 22);
  mes.insertTriangle(20, 22, 23);

  return mes;
}
