module treerender.math.matrix;

import std.range;
import std.algorithm;

alias mat3 = Matrix!(float, 3, 3, 0);
alias mat4 = Matrix!(float, 4, 4, 0);

/// Matrix with static size of n rows and m columns. Represented with flat array.
struct Matrix(T, size_t n, size_t m = n, T initval = T.init) {
  /// Data of matrix in flat array. Format is row major.
  T[n * m] data = initval.repeat(n*m).array;

  /// Shortcut to self
  alias This = Matrix!(T, n, m, initval);

  /// Return matrix with ones in diagonal
  static This identity() {
    T[n * m] data;
    static foreach(i; 0 .. min(n, m)) {
      data[toIndex(i, i)] = 1;
    }
    return This(data);
  }

  /// Make matrix filled with zeros
  static This zeros() {
    T[n * m] data;
    static foreach(i; 0 .. n) {
      static foreach(j; 0 .. m) data[toIndex(i, i)] = 0;
    }
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
  Matrix!(T, n, p) opBinary(string op)(Matrix!(T, m, p) other) inout if(op == "*") {
    auto ret = zeros;
    static foreach(i; 0..n) {
      static foreach(j; 0..p) {
        T value = 0;
        static foreach(r; 0..m) value += this[i, r] * other[r, j];
        ret[i,j] = value;
      }
    }
    return ret;
  }

  /// Convert row and column to flat index
  private static size_t toIndex(size_t row, size_t col) {
    return row * m + col;
  }
}
