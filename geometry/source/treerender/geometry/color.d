module treerender.geometry.color;

import treerender.math.v4;

/// The simpliest RGBA color with [0 .. 1] range
struct Color {
  float r = 0.0;
  float g = 0.0;
  float b = 0.0;
  float a = 1.0;

  /// Zero value is considered empty voxel
  enum empty = Color(0.0, 0.0, 0.0, 0.0);

  /// Constant red color
  static Color red() {
    return Color(1.0, 0.0, 0.0, 1.0);
  }

  /// Constant green color
  static Color green() {
    return Color(0.0, 1.0, 0.0, 1.0);
  }

  /// Constant blue color
  static Color blue() {
    return Color(0.0, 0.0, 1.0, 1.0);
  }

  /// Return `true` if the voxel is transparent
  bool opaque() inout {
    return a < 1.0;
  }

  /// Convert to 4D vector
  T opCast(T)() inout if(is(T: v4f)) {
    return v4f(r, g, b, a);
  }

  /// Convert to 3D vector
  T opCast(T)() inout if(is(T: v3f)) {
    return v4f(r, g, b);
  }
}
