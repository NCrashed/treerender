module treerender.math.matrix;

import std.algorithm;
import std.math;
import std.range;

import treerender.math.v3;

alias mat3 = Matrix!(float, 3, 3);
alias mat4 = Matrix!(float, 4, 4);

/// Matrix with static size of n rows and m columns. Represented with flat array.
struct Matrix(T, size_t n, size_t m = n) {
  /// Data of matrix in flat array. Format is row major.
  T[n * m] data;

  /// Shortcut to self
  alias This = Matrix!(T, n, m);

  /// Return matrix with ones in diagonal
  static This identity() {
    T[n * m] data;
    data[] = 0;
    static foreach(i; 0 .. min(n, m)) {
      data[toIndex(i, i)] = 1;
    }
    return This(data);
  }

  /// Make matrix filled with zeros
  static This zeros() {
    T[n * m] data;
    data[] = 0;
    return This(data);
  }

  /// Reading from matrix by column and row index
  T opIndex(size_t row, size_t col) inout {
    assert(row < n, "Matrix row " ~ row.stringof ~ " is out of bounds " ~ n.stringof);
    assert(col < n, "Matrix col " ~ col.stringof ~ " is out of bounds " ~ m.stringof);
    return data[toIndex(row, col)];
  }

  /// Writing to matrix by column and row index
  void opIndexAssign(T value, size_t row, size_t col) {
    assert(row < n, "Matrix row " ~ row.stringof ~ " is out of bounds " ~ n.stringof);
    assert(col < n, "Matrix col " ~ col.stringof ~ " is out of bounds " ~ m.stringof);
    data[toIndex(row, col)] = value;
  }

  /// Matrix multiplication
  Matrix!(T, n, p) opBinary(string op, size_t p)(Matrix!(T, m, p) other) inout if(op == "*") {
    auto ret = zeros;
    T summ;
    static foreach(i; 0..n) {
      static foreach(j; 0..p) {
        summ = 0;
        static foreach(r; 0..m) summ += this[i, r] * other[r, j];
        ret[i,j] = summ;
      }
    }
    return ret;
  }

  /// Convert row and column to flat index
  private static size_t toIndex(size_t row, size_t col) {
    return row * m + col;
  }

}

/// Get perspective projection matrix that maps camera coordinate space into window space.
Matrix!(T, 4) projection(T)(T fovy, T aspect, T near, T far) {
  auto ret = Matrix!(T, 4).zeros;
  const top = near * tan(fovy/2);
  const right = top / aspect;
  ret[0,0] = near/right;
  ret[1,1] = near/top;
  ret[2,2] = -(far+near)/(far-near);
  ret[2,3] = -2*far*near/(far-near);
  ret[3,2] = -1;
  return ret;
}

/// Get view matrix that transforms world coordinate space into camera space.
Matrix!(T, 4) lookAtMatrix(T)(vec3!T eye, vec3!T at, vec3!T up) {
  const zaxis = (eye-at).normalized;
  const xaxis = up.cross(zaxis).normalized;
  const yaxis = zaxis.cross(xaxis).normalized;

  Matrix!(T, 4) ret;
  ret[0,0] = xaxis.x;         ret[0,1] = xaxis.y;         ret[0,2] = xaxis.z;         ret[0,3] = -xaxis.dot(eye);
	ret[1,0] = yaxis.x;         ret[1,1] = yaxis.y;         ret[1,2] = yaxis.z;         ret[1,3] = -yaxis.dot(eye);
	ret[2,0] = zaxis.x;         ret[2,1] = zaxis.y;         ret[2,2] = zaxis.z;         ret[2,3] = -zaxis.dot(eye);
	ret[3,0] = 0.0f;            ret[3,1] = 0.0f;            ret[3,2] = 0.0f;            ret[3,3] = 1.0f;
  return ret;
}

/// Get translation matrix to translate objects across given vector
Matrix!(T, 4) translation(T)(vec3!T v) {
  auto ret = Matrix!(T, 4).identity;
  ret[0,3] = v.x;
	ret[1,3] = v.y;
	ret[2,3] = v.z;
  return ret;
}
