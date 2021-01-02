module treerender.math.v2;

import std.math;
import std.random;
import std.traits;
import treerender.math.trigonometry;

/// Shorthand for floating vector
alias v2f = vec2!float;
/// Shorthand for integral vectors
alias v2i = vec2!int;
/// Shorthand for unsigned integral vectors
alias v2u = vec2!uint;

/// Vector type for 2 dimensions.
struct vec2(T) {
  T x;
  T y;

  /// Get unit vector corresponding to the angle in radians
  static if(isFloatingPoint!T) {
    static vec2!T fromAngle(float angle) {
      return vec2!T(cos(angle), sin(angle));
    }
  }

  /// Generate random vector with components in given range
  static vec2!T uniform(T minv, T maxv, ref Random rng) {
    immutable x = std.random.uniform(minv, maxv, rng);
    immutable y = std.random.uniform(minv, maxv, rng);
    return vec2!T(x, y);
  }

  /// Define operations per component
  vec2!T opBinary(string op)(vec2!T other) inout {
    immutable x = mixin("this.x " ~ op ~ " other.x");
    immutable y = mixin("this.y " ~ op ~ " other.y");
    return vec2!T(x, y);
  }

  /// Another way to scale or add or subtract scalar
  vec2!T opBinary(string op)(T scalar) inout {
    immutable x = mixin("this.x " ~ op ~ " scalar");
    immutable y = mixin("this.y " ~ op ~ " scalar");
    return vec2!T(x, y);
  }

  /// Define rotation around 0 to given angle
  static if(isFloatingPoint!T) {
    vec2!T rotate(T angle) inout {
      float sina = void;
      float cosa = void;
      sinCos(angle, sina, cosa);
      immutable x = this.x * cosa - this.y * sina;
      immutable y = this.x * sina + this.y * cosa;
      return vec2!T(x, y);
    }
  }

  /// Compare per field two vectors with given precision (for floating point equality tests)
  bool approxEq(T epsilon = 0.000001)(vec2!T other) inout {
    return (this.x - other.x).abs <= epsilon
        && (this.y - other.y).abs <= epsilon;
  }

  /// Return squared distance between two points. Used for collision detection.
  T distSquared(vec2!T other) inout {
    immutable x = this.x - other.x;
    immutable y = this.y - other.y;
    return x * x + y * y;
  }

  /// Scale given vector by scalar
  vec2!T scale(T scalar) inout {
    immutable x = this.x * scalar;
    immutable y = this.y * scalar;
    return vec2!T(x, y);
  }

  /// Calculate sign of each component and return vector with 1 with that sign.
  /// *Note*: corner cases are 0 and NaN, they are returned as is.
  vec2!T signum() inout {
    return vec2!T(x.sgn, y.sgn);
  }
}

unittest {
  v2f v1 = v2f(1, 0);
  assert(v1.rotate(PI * 0.5).approxEq(v2f(0, 1)));
}
