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

  /// Convert row and column to flat index
  private static size_t toIndex(size_t row, size_t col) {
    return row * m + col;
  }
}
