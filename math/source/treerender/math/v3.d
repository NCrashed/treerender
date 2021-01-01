module treerender.math.v3;

import std.math;
import std.random;
import std.traits;
import treerender.math.trigonometry;

/// Shorthand for floating vector
alias v3f = vec3!float;
/// Shorthand for integral vectors
alias v3i = vec3!int;
/// Shorthand for unsigned integral vector
alias v3u = vec3!uint;

/// Vector type for 3 dimensions.
struct vec3(T) {
  T x;
  T y;
  T z;

  /// Generate random vector with components in given range
  static vec3!T uniform(T minv, T maxv, ref Random rng) {
    immutable x = std.random.uniform(minv, maxv, rng);
    immutable y = std.random.uniform(minv, maxv, rng);
    immutable z = std.random.uniform(minv, maxv, rng);
    return vec3!T(x, y, z);
  }

  /// Define operations per component
  vec3!T opBinary(string op)(vec3!T other) inout {
    immutable x = mixin("this.x " ~ op ~ " other.x");
    immutable y = mixin("this.y " ~ op ~ " other.y");
    immutable z = mixin("this.z " ~ op ~ " other.z");
    return vec3!T(x, y, z);
  }

  /// Another way to scale or add or subtract scalar
  vec3!T opBinary(string op)(T scalar) inout {
    immutable x = mixin("this.x " ~ op ~ " scalar");
    immutable y = mixin("this.y " ~ op ~ " scalar");
    immutable z = mixin("this.z " ~ op ~ " scalar");
    return vec3!T(x, y, z);
  }

  /// Compare per field two vectors with given precision (for floating point equality tests)
  bool approxEq(T epsilon = 0.000001)(vec3!T other) inout {
    return (this.x - other.x).abs <= epsilon
        && (this.y - other.y).abs <= epsilon
        && (this.z - other.z).abs <= epsilon;
  }

  /// Return squared distance between two points. Used for collision detection.
  T distSquared(vec3!T other) inout {
    immutable x = this.x - other.x;
    immutable y = this.y - other.y;
    immutable z = this.z - other.z;
    return x * x + y * y + z * z;
  }

  /// Scale given vector by scalar
  vec3!T scale(T scalar) inout {
    immutable x = this.x * scalar;
    immutable y = this.y * scalar;
    immutable z = this.z * scalar;
    return vec3!T(x, y, z);
  }

  /// Return normalized vector with unit length
  static if(isFloatingPoint!T) {
    vec3!T normalized() inout {
      return scale(1 / length);
    }

    /// Calclulate length of vector
    T length() inout {
      return lengthSquared.sqrt;
    }
  }

  /// Calclulate square of length of vector (doesn't involve complex sqrt op)
  T lengthSquared() inout {
    return dot(this);
  }

  /// Calculate dot product with other vector
  T dot(vec3!T v) inout {
    return x * v.x + y * v.y + z * v.z;
  }

  /// Calculate cross product between two vectors
  vec3!T cross(vec3!T v) inout {
    immutable vx = y*v.z - v.y*z;
		immutable vy = v.x*z - x*v.z;
		immutable vz = x*v.y - v.x*y;
    return vec3!T(vx, vy, vz);
  }
}
