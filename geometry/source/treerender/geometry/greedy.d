module treerender.geometry.greedy;

import treerender.geometry.mesh;
import treerender.geometry.voxel;
import treerender.geometry.side;

/// How to triangulate volumetric data
enum Topology {
  TRIANGLES,
  LINES,
}

/// Convert each voxel into triangle mesh using greedy meshing algorithm.
Mesh!T greedyTriangulate(Topology t, T, size_t n)(Voxels!(T, n) grid) {
  // Estimate as each voxel will have a two triangles in average
  enum prealloc = 2 * n * n * n;
  auto mesh = Mesh!T.allocate(prealloc);
  static foreach(i; 0 .. n) {
    mesh.triangulateX!(t, Side.BACKWARD)(grid);
    mesh.triangulateX!(t, Side.FORWARD)(grid);
    mesh.triangulateY!(t, Side.LEFT)(grid);
    mesh.triangulateY!(t, Side.RIGHT)(grid);
    mesh.triangulateZ!(t, Side.DOWN)(grid);
    mesh.triangulateZ!(t, Side.UP)(grid);
  }
  return mesh;
}
unittest {
  auto grid = Voxels!(int, 1).replicate(42);
  auto mesh = grid.greedyTriangulate!(Topology.TRIANGLES);
}

private void triangulateX(Topology t, Side s, T, size_t n)(Mesh!T mesh, Voxels!(T, n) grid) {

}

private void triangulateY(Topology t, Side s, T, size_t n)(Mesh!T mesh, Voxels!(T, n) grid) {

}

private void triangulateZ(Topology t, Side s, T, size_t n)(Mesh!T mesh, Voxels!(T, n) grid) {

}
