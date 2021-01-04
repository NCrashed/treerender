module treerender.geometry.greedy;

import treerender.geometry.mesh;
import treerender.geometry.axis;
import treerender.geometry.cube;
import treerender.geometry.side;
import treerender.geometry.voxel;
import treerender.math.v2;
import treerender.math.v3;

/// Convert each voxel into triangle mesh using greedy meshing algorithm.
Mesh!T greedyTriangulate(Primitive p, T, size_t n)(Voxels!(T, n) grid) {
  // Estimate as each voxel will have a two triangles in average
  enum prealloc = 2 * n * n * n;
  auto mesh = Mesh!T.allocate(prealloc);
  static foreach(i; 0 .. n) {
    mesh.triangulateSlice!(p, Axis.x, Side.backward)(grid, i);
    mesh.triangulateSlice!(p, Axis.x, Side.forward)(grid, i);
    mesh.triangulateSlice!(p, Axis.y, Side.left)(grid, i);
    mesh.triangulateSlice!(p, Axis.y, Side.right)(grid, i);
    mesh.triangulateSlice!(p, Axis.z, Side.down)(grid, i);
    mesh.triangulateSlice!(p, Axis.z, Side.up)(grid, i);
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
  auto mesh = grid.greedyTriangulate!(Primitive.triangles);
}

private void triangulateSlice(Primitive p, Axis a, Side s, T, size_t n)(Mesh!T mesh, Voxels!(T, n) grid, uint i) {
  auto mask = grid.slice!a(i);
  foreach(j; 0..n) {
    foreach(k; 0..n) {
      const vi = cast(v3u)a.axisSlice(j, k, i);
      const value = grid.get(vi);
      const masked = mask[k][j];
      if(masked != T.empty && grid.sideVisible(vi, s)) {
        import std.stdio;
        v2u peekQuad(size_t ji, size_t w, size_t h) {
          if(k + h >= n) return v2u(cast(uint)w, cast(uint)h);
          else if(j + ji >= n) return peekQuad(0, ji, h+1);
          else if(ji >= w && h > 0) return peekQuad(0, w, h+1);
          else {
            const newj = j + ji;
            const newk = k + h;
            const mvalue = mask[newk][newj];
            const newvi = cast(v3u)a.axisSlice(newj, newk, i);
            const visible = grid.sideVisible(newvi, s);
            if(mvalue == T.empty || mvalue != value || !visible) {
              if(ji == 0) {
                return v2u(cast(uint)w, cast(uint)h);
              } else {
                return peekQuad(0, ji, h+1);
              }
            } else {
              mask[newk][newj] = T.empty;
              return peekQuad(ji+1, w, h);
            }
          }
        }
        writeln(mask);
        auto size = peekQuad(1, 0, 0);
        writeln(mask);
        writeln(vi, " => ", size, " ", s);
        mesh.insertCubeSide!(s, p, n)(vi, size, value);
      }
    }
  }
}
