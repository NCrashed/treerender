module treerender.geometry.axis;

import treerender.math.v2;
import treerender.math.v3;

/// Define a independent perpindicular to all others direction in space
enum Axis {
  x,
  y,
  z,
}

/// Construct vector with value on corresponding axis in the vector
vec3!T along(T)(Axis a, T v) {
  final switch(a) {
    case Axis.x: return vec3!T(v, 0, 0);
    case Axis.y: return vec3!T(0, v, 0);
    case Axis.z: return vec3!T(0, 0, v);
  }
}

/// Places $(B k) to corresponding axis place and i j to rest places.
///
/// The function helps when you need to iterate over 2D slice with fixed coordinate
/// alongside axis.
vec3!T axisSlice(T)(Axis a, T i, T j, T k) {
  final switch(a) {
    case Axis.x: return vec3!T(k, i, j);
    case Axis.y: return vec3!T(i, k, j);
    case Axis.z: return vec3!T(i, j, k);
  }
}

/// Remove given axis from vector to produce 2D truncated vector
vec2!T removeAxis(T)(Axis a, vec3!T v) {
  final switch(a) {
    case Axis.x: return vec2!T(v.y, v.z);
    case Axis.y: return vec2!T(v.x, v.z);
    case Axis.z: return vec2!T(v.x, v.y);
  }
}
