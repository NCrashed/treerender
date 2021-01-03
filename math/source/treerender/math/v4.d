module treerender.math.v4;

import std.math;
import std.random;
import std.traits;
import treerender.math.trigonometry;

/// Shorthand for floating vector
alias v4f = vec4!float;
/// Shorthand for integral vectors
alias v4i = vec4!int;
/// Shorthand for unsigned integral vector
alias v4u = vec4!uint;

/// Vector type for 4 dimensions.
struct vec4(T) {
  T x;
  T y;
  T z;
  T w;

  /// Generate random vector with components in given range
  static vec4!T uniform(T minv, T maxv, ref Random rng) {
    immutable x = std.random.uniform(minv, maxv, rng);
    immutable y = std.random.uniform(minv, maxv, rng);
    immutable z = std.random.uniform(minv, maxv, rng);
    immutable w = std.random.uniform(minv, maxv, rng);
    return vec4!T(x, y, z, w);
  }

  /// Define operations per component
  vec4!T opBinary(string op)(vec4!T other) inout {
    immutable x = mixin("this.x " ~ op ~ " other.x");
    immutable y = mixin("this.y " ~ op ~ " other.y");
    immutable z = mixin("this.z " ~ op ~ " other.z");
    immutable w = mixin("this.w " ~ op ~ " other.z");
    return vec4!T(x, y, z, w);
  }

  /// Another way to scale or add or subtract scalar
  vec4!T opBinary(string op)(T scalar) inout {
    immutable x = mixin("this.x " ~ op ~ " scalar");
    immutable y = mixin("this.y " ~ op ~ " scalar");
    immutable z = mixin("this.z " ~ op ~ " scalar");
    immutable w = mixin("this.w " ~ op ~ " scalar");
    return vec4!T(x, y, z, w);
  }

  /// Another way to scale or add or subtract scalar
  vec4!T opBinaryRight(string op)(T scalar) inout {
    immutable x = mixin("this.x " ~ op ~ " scalar");
    immutable y = mixin("this.y " ~ op ~ " scalar");
    immutable z = mixin("this.z " ~ op ~ " scalar");
    immutable w = mixin("this.w " ~ op ~ " scalar");
    return vec4!T(x, y, z, w);
  }

  /// Compare per field two vectors with given precision (for floating point equality tests)
  bool approxEq(T epsilon = 0.000001)(vec4!T other) inout {
    return (this.x - other.x).abs <= epsilon
        && (this.y - other.y).abs <= epsilon
        && (this.z - other.z).abs <= epsilon
        && (this.w - other.w).abs <= epsilon;
  }

  /// Return squared distance between two points. Used for collision detection.
  T distSquared(vec4!T other) inout {
    immutable x = this.x - other.x;
    immutable y = this.y - other.y;
    immutable z = this.z - other.z;
    immutable w = this.w - other.w;
    return x * x + y * y + z * z + w * w;
  }

  /// Scale given vector by scalar
  vec4!T scale(T scalar) inout {
    immutable x = this.x * scalar;
    immutable y = this.y * scalar;
    immutable z = this.z * scalar;
    immutable w = this.w * scalar;
    return vec4!T(x, y, z, w);
  }

  /// Return normalized vector with unit length
  static if(isFloatingPoint!T) {
    vec4!T normalized() inout {
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
  T dot(vec4!T v) inout {
    return x * v.x + y * v.y + z * v.z + w * v.w;
  }

  static if(isFloatingPoint!T || isIntegral!T) {
    /// Calculate sign of each component and return vector with 1 with that sign.
    /// *Note*: corner cases are 0 and NaN, they are returned as is.
    vec4!T signum() inout {
      return vec4!T(x.sgn, y.sgn, z.sgn, w.sgn);
    }
  }

  /// Cast by elements vector to another vector
  V opCast(V)() inout if (is(V: vec4!U, U)) {
    static if(is(V: vec4!U, U)) { // template constraint in function declaration doesn't bring in scope U, so bring it with static if
      return vec4!U(cast(U)x, cast(U)y, cast(U)z, cast(U)w);
    }
  }

}
