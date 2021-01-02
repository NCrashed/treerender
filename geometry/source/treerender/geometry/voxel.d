module treerender.geometry.voxel;

import treerender.math.v3;

/// Mutable square 3D grid of unboxed data.
struct Voxels(T, size_t n) {
  /// Data is plain array, row-column major.
  T[length] data;

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
    return This(data);
  }

  /// Convert 3d offset of voxel to linear index in array
  size_t toIndex(v3u i) inout {
    return i.x + i.y * n + i.z * n * n;
  }

  /// Convert linear index of array to 3d offset of voxel
  v3u fromIndex(size_t i) inout {
    const z = i / (n*n);
    const j = i - z * n * n;
    const x = j % n;
    const y = j / n;
    return v3u(cast(uint)x, cast(uint)y, cast(uint)z);
  }

  /// Check that given index in bounds of voxel grid
  bool inBounds(v3u i) inout {
    return i.x < n && i.y < n && i.z < n;
  }

  /// Read single element of voxel grid
  T get(v3u i) inout {
    assert(inBounds(i), "Voxel offset is out of bounds " ~ i.stringof ~ ", voxel size " ~ size.stringof);
    return data[toIndex(i)];
  }

  /// Set single element of
  void set(v3u i, T value) {
    assert(inBounds(i), "Voxel offset is out of bounds " ~ i.stringof ~ ", voxel size " ~ size.stringof);
    data[toIndex(i)] = value;
  }
}
