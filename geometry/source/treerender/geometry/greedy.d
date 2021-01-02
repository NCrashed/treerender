module treerender.geometry.greedy;

import treerender.geometry.mesh;
import treerender.geometry.voxel;

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
  foreach(i; 0 .. n) {

  }
}
unittest {
  auto grid = Voxels!(int, 1).replicate(42);
  auto mesh = grid.greedyTriangulate!(Topology.TRIANGLES);
}
