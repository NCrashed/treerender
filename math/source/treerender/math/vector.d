module treerender.math.vector;

import std.algorithm;
import std.conv;
import std.math;
import std.random;
import std.range;
import std.traits;
import treerender.math.trigonometry;

/// Shorthand for floating vector
alias v2f = vec2!float;
/// Shorthand for integral vectors
alias v2i = vec2!int;
/// Shorthand for unsigned integral vectors
alias v2u = vec2!uint;

/// Shorthand for floating vector
alias v3f = vec3!float;
/// Shorthand for integral vectors
alias v3i = vec3!int;
/// Shorthand for unsigned integral vector
alias v3u = vec3!uint;

/// Shorthand for floating vector
alias v4f = vec4!float;
/// Shorthand for integral vectors
alias v4i = vec4!int;
/// Shorthand for unsigned integral vector
alias v4u = vec4!uint;

/// Shortcut for 2D vector
alias vec2(T) = vec!(T, 2);
/// Shortcut for 3D vector
alias vec3(T) = vec!(T, 3);
/// Shortcut for 4D vector
alias vec4(T) = vec!(T, 4);

/// Vector type for `n` dimensions.
struct vec(T, size_t n) {
  T[n] data;

  /// Allows to make vector by it component enumeration in constructor
  this(T[n] elems...) {
    data = elems;
  }

  /// Return X component
  T x()() inout if(n >= 1) {
    return data[0];
  }

  /// Return Y component
  T y()() inout if(n >= 2) {
    return data[1];
  }

  /// Return Z component
  T z()() inout if(n >= 3) {
    return data[2];
  }

  /// Return W component
  T w()() inout if(n >= 4) {
    return data[3];
  }

  /// Set X component
  void x()(T v) if(n >= 1) {
    data[0] = v;
  }

  /// Set Y component
  void y()(T v) if(n >= 2) {
    data[1] = v;
  }

  /// Set Z component
  void z()(T v) if(n >= 3) {
    data[2] = v;
  }

  /// Set W component
  void w()(T v) if(n >= 4) {
    data[3] = v;
  }

  /// Return 2d subvector
  vec!(T, 2) xy()() inout if(n >= 2) {
    return vec!(T, 2)(data[0 .. 2]);
  }

  /// Return 3d subvector
  vec!(T, 3) xyz()() inout if(n >= 3) {
    return vec!(T, 3)(data[0 .. 3]);
  }

  /// Return 4d subvector
  vec!(T, 4) xyzw()() inout if(n >= 4) {
    return vec!(T, 4)(data[0 .. 4]);
  }

  /// Set 2d subvector
  void xy(size_t m)(vec!(T, m) v) if(n >= 2 && m >= 2) {
    data[0 .. 2] = v.data[0 .. 2];
  }

  /// Set 3d subvector
  void xyz(size_t m)(vec!(T, 3) v) if(n >= 3 && m >= 3) {
    data[0 .. 3] = v.data[0 .. 3];
  }

  /// Set 4d subvector
  void xyzw(size_t m)(vec!(T, 4) v) if(n >= 4 && m >= 4) {
    data[0 .. 4] = v.data[0 .. 4];
  }

  /// Generate random vector with components in given range
  static vec!(T, n) uniform(T minv, T maxv, ref Random rng) {
    Unqual!T[n] ret;
    static foreach(i; 0 .. n) ret[i] = std.random.uniform(minv, maxv, rng);
    return vec!(T, n)(ret);
  }

  /// Negation of vector
  vec!(T, n) opUnary(string s)() inout if (s == "-")
  {
    vec!(T, n) ret;
    static foreach(i; 0 .. n) ret.data[i] = -data[i];
    return ret;
  }

  /// Define operations per component
  vec!(T, n) opBinary(string op)(vec!(T, n) other) inout {
    Unqual!T[n] ret;
    static foreach(i; 0 .. n)
      ret[i] = mixin("data[i] " ~ op ~ " other.data[i]");
    return vec!(T, n)(ret);
  }

  /// Another way to scale or add or subtract scalar
  vec!(T, n) opBinary(string op)(T scalar) inout {
    Unqual!T[n] ret;
    static foreach(i; 0 .. n)
      ret[i] = mixin("data[i] " ~ op ~ " scalar");
    return vec!(T, n)(ret);
  }

  /// Another way to scale or add or subtract scalar
  vec!(T, n) opBinaryRight(string op)(T scalar) inout {
    vec!(T, n) ret;
    static foreach(i; 0 .. n)
      ret.data[i] = mixin("scalar " ~ op ~ " data[i]");
    return ret;
  }

  /// Reading from vector by elemeint index
  T opIndex(size_t i) inout {
    assert(i < n, "Vector element " ~ i.to!string ~ " is out of bounds " ~ n.stringof);
    return data[i];
  }

  static if(isMutable!T) {
    /// Writing to matrix by column and row index
    void opIndexAssign(T value, size_t i) {
      assert(i < n, "Vector element " ~ i.to!string ~ " is out of bounds " ~ n.stringof);
      data[i] = value;
    }
  }
  
  /// Compare per field two vectors with given precision (for floating point equality tests)
  bool approxEq(T epsilon = 0.000001)(vec!(T, n) other) inout {
    return zip(cast(T[])data[], other.data[]).map!(a => abs(a[0] - a[1]) <= epsilon).all;
  }

  /// Return squared distance between two points. Used for collision detection.
  T distSquared(vec!(T, n) other) inout {
    return zip(cast(T[])data[], other.data[]).map!(a => (a[0] - a[1])*(a[0] - a[1])).sum;
  }

  /// Scale given vector by scalar
  vec!(T, n) scale(T scalar) inout {
    Unqual!T[n] datum;
    static foreach(i; 0..n) datum[i] = data[i] * scalar;
    return vec!(T, n)(datum);
  }

  /// Return normalized vector with unit length
  static if(isFloatingPoint!T) {
    vec!(T, n) normalized() inout {
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
  T dot(vec!(T, n) v) inout {
    return zip(cast(T[])data[], v.data[]).map!(a => a[0]*a[1]).sum;
  }

  static if(n == 3) {
    /// Calculate cross product between two vectors
    vec3!T cross(vec3!T v) inout {
      immutable vx = y*v.z - v.y*z;
  		immutable vy = v.x*z - x*v.z;
  		immutable vz = x*v.y - v.x*y;
      return vec3!T(vx, vy, vz);
    }
  }

  static if(isFloatingPoint!T || isIntegral!T) {
    /// Calculate sign of each component and return vector with 1 with that sign.
    /// *Note*: corner cases are 0 and NaN, they are returned as is.
    vec!(T, n) signum() inout {
      Unqual!T[n] datum;
      static foreach(i; 0..n) datum[i] = data[i].sgn;
      return vec!(T, n)(datum);
    }
  }

  /// Cast by elements vector to another vector
  V opCast(V)() inout if (is(V: vec!(U, n), U)) {
    static if(is(V: vec!(U, n), U)) { // template constraint in function declaration doesn't bring in scope U, so bring it with static if
      Unqual!U[n] datum;
      static foreach(i; 0..n) datum[i] = cast(U)data[i];
      return vec!(U, n)(datum);
    }
  }

  /// Project given vector to the `v`
  vec!(T, n) project(vec!(T, n) v) inout {
    return v * (dot(v) / v.lengthSquared);
  }

  /// Get perpendicular component between given vector and `v`
  vec!(T, n) reject(vec!(T, n) v) inout {
    return this - project(v);
  }

  static if(isFloatingPoint!T && n == 2) {
    /// Rotate 2D vector around z axis
    vec2!T rotate(T angle) inout {
      float sina = void;
      float cosa = void;
      sinCos(angle, sina, cosa);
      immutable x = this.x * cosa - this.y * sina;
      immutable y = this.x * sina + this.y * cosa;
      return vec2!T(x, y);
    }
    unittest {
      v2f v1 = v2f(1, 0);
      assert(v1.rotate(PI * 0.5).approxEq(v2f(0, 1)));
    }
  }
}
