module treerender.geometry.greedy;

import treerender.geometry.mesh;
import treerender.geometry.voxel;
import treerender.geometry.side;
import treerender.geometry.axis;
import treerender.math.v3;

/// How to triangulate volumetric data
enum Topology {
  triangles,
  lines,
}

/// Convert each voxel into triangle mesh using greedy meshing algorithm.
Mesh!T greedyTriangulate(Topology t, T, size_t n)(Voxels!(T, n) grid) {
  // Estimate as each voxel will have a two triangles in average
  enum prealloc = 2 * n * n * n;
  auto mesh = Mesh!T.allocate(prealloc);
  static foreach(i; 0 .. n) {
    mesh.triangulateSlice!(t, Axis.x, Side.backward)(grid, i);
    mesh.triangulateSlice!(t, Axis.x, Side.forward)(grid, i);
    mesh.triangulateSlice!(t, Axis.y, Side.left)(grid, i);
    mesh.triangulateSlice!(t, Axis.y, Side.right)(grid, i);
    mesh.triangulateSlice!(t, Axis.z, Side.down)(grid, i);
    mesh.triangulateSlice!(t, Axis.z, Side.up)(grid, i);
  }
  return mesh;
}
unittest {
  struct V {
    bool v = false;
    enum empty = V.init;
    bool opaque() inout { return true; }
  }
  auto grid = Voxels!(V, 1).replicate(V(true));
  auto mesh = grid.greedyTriangulate!(Topology.triangles);
}

private void triangulateSlice(Topology t, Axis a, Side s, T, size_t n)(Mesh!T mesh, Voxels!(T, n) grid, uint i) {
  auto mask = grid.slice!a(i);
  foreach(j; 0..n) {
    foreach(k; 0..n) {
      const vi = cast(v3u)a.axisSlice(j, k, i);
      const value = grid.get(vi);
      const masked = mask[k][j];
      if(masked != T.empty && grid.sideVisible(vi, s)) {

      }
    }
  }
}
