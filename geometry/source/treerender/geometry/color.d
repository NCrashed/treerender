module treerender.geometry.color;

import std.random;
import treerender.math.vector;

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

  /// Return random non transparent color
  static Color randomSolid() {
    auto r = uniform(0.0, 1.0);
    auto g = uniform(0.0, 1.0);
    auto b = uniform(0.0, 1.0);
    return Color(r, g, b, 1.0);
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

  /// Blend with another color with standard alpha blending
  Color blend(Color c) {
    Color res;
    const malpha = (1 - this.a)*c.a;
    res.a = this.a + malpha;
    res.r = (this.a * this.r + malpha * c.r) / res.a;
    res.g = (this.a * this.g + malpha * c.g) / res.a;
    res.b = (this.a * this.b + malpha * c.b) / res.a;
    return res;
  }
}
