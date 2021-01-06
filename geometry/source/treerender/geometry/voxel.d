module treerender.geometry.voxel;

import std.conv;
import std.traits;
import treerender.geometry.axis;
import treerender.geometry.side;
import treerender.math.vector;

/**
Returns `true` is `V` is type that can be a voxel value. Voxel must define
static `empty` value for empty space indication and `opaque` predicate that
tells whether the given voxel is fully opaque.

----
V v; // Can define a voxel value
V v = V.empty; // Has empty value
if (v.opaque) {} // Can test for light penetration property
----
*/
template isVoxel(V) {
  static if(!__traits(compiles, V.init.opaque)) enum isVoxel = false;
  else enum isVoxel =
        is(typeof(V.init) == V)
        && is(ReturnType!((V v) => V.empty) == V)
        && is(ReturnType!((V v) => v.opaque) == bool)
        && hasFunctionAttributes!(V.opaque, "inout");
}

unittest {
  struct A {}
  struct B {
    enum empty = B.init;
  }
  struct C {
    enum empty = C.init;
    bool opaque() { return true; }
  }
  struct D {
    bool opaque() { return true; }
  }
  struct E {
    enum empty = E.init;
    string opaque() { return ""; }
  }
  struct V {
    bool v = false;
    alias v This;
    enum empty = V.init;
    bool opaque() inout { return true; }
  }
  struct C2 {
    enum empty = C2.init;
    bool opaque() inout { return true; }
  }

  static assert(!isVoxel!C);
  static assert(isVoxel!C2);
  static assert(!isVoxel!A);
  static assert(!isVoxel!float);
  static assert(!isVoxel!int);
  static assert(!isVoxel!B);
  static assert(!isVoxel!D);
  static assert(!isVoxel!E);
  static assert(isVoxel!V);
}

/// Mutable square 3D grid of unboxed data.
///
/// @par T Is voxel type that has to implement voxel interface $(REF isVoxel)
/// @par empty Value that is considered as empty space.
///
struct Voxels(T, size_t n) if(isVoxel!T) {
  /// Data is plain array, row-column major.
  T[n][n][n] data;

  /// Shortcut fot self
  alias This = Voxels!(T, n);
  /// Amount of voxels inside
  enum length = n*n*n;
  /// Size of one side
  enum size = n;

  /// Create voxel grid filled with given value
  static This replicate(T val) {
    T[length] data;
    data[] = val;
    return This(cast(T[n][n][n])data);
  }

  /// Check that given index in bounds of voxel grid
  bool inBounds(v3u i) inout {
    return i.x < n && i.y < n && i.z < n;
  }

  /// Read single element of voxel grid
  T get(v3u i) inout {
    assert(inBounds(i), "Voxel offset is out of bounds " ~ i.stringof ~ ", voxel size " ~ size.stringof);
    return data[i.z][i.y][i.x];
  }

  /// Set single element of
  void set(v3u i, T value) {
    assert(inBounds(i), "Voxel offset is out of bounds " ~ i.stringof ~ ", voxel size " ~ size.stringof);
    data[i.z][i.y][i.x] = value;
  }

  /// Make 2D slice for given axis at given axis position. Data of voxels is copied to slice.
  T[n][n] slice(Axis a)(uint i) inout {
    T[n][n] data;
    foreach(j; 0..n) {
      foreach(k; 0..n) {
        data[k][j] = get(a.axisSlice(cast(uint)j, cast(uint)k, i));
      }
    }
    return data;
  }

  /// Check if given voxel is visible from given side
  bool sideVisible(v3u i, Side s) inout {
    const v3u j = cast(v3u)(cast(v3i)i + s.sideOffset);
    if(!inBounds(i)) return false;
    if(!inBounds(j)) return true;
    const a = get(i);
    const b = get(j);
    return a != T.empty && (b == T.empty || b.opaque);
  }

  /// Allows to use [x, y, z]
  T opIndex(size_t x, size_t y, size_t z) {
    assert(x < n, "Voxel x " ~ x.to!string ~ " offset is out of bounds " ~ size.stringof);
    assert(y < n, "Voxel y " ~ y.to!string ~ " offset is out of bounds " ~ size.stringof);
    assert(z < n, "Voxel z " ~ z.to!string ~ " offset is out of bounds " ~ size.stringof);
    return data[z][y][x];
  }

  /// Allows to use [x, y, z] assign
  void opIndexAssign(T value, size_t x, size_t y, size_t z) {
    assert(x < n, "Voxel x " ~ x.to!string ~ " offset is out of bounds " ~ size.stringof);
    assert(y < n, "Voxel y " ~ y.to!string ~ " offset is out of bounds " ~ size.stringof);
    assert(z < n, "Voxel z " ~ z.to!string ~ " offset is out of bounds " ~ size.stringof);
    data[z][y][x] = value;
  }
}
