module treerender.geometry.octo;

import std.container.array;
import std.typecons;
import treerender.math.vector;

/// Indexing child cube within node
enum Child: ubyte {
  backLeftBottom   = 0,
  frontLeftBottom  = 1,
  backRightBottom  = 2,
  frontRightBottom = 3,
  backLeftTop      = 4,
  frontLeftTop     = 5,
  backRightTop     = 6,
  frontRightTop    = 7,
}

/// Get 3D index offset of octree child
static v3s childOffset(Child c) {
  final switch(c) {
    case(Child.backLeftBottom):   return v3s(0, 0, 0);
    case(Child.frontLeftBottom):  return v3s(1, 0, 0);
    case(Child.backRightBottom):  return v3s(0, 1, 0);
    case(Child.frontRightBottom): return v3s(1, 1, 0);
    case(Child.backLeftTop):      return v3s(0, 0, 1);
    case(Child.frontLeftTop):     return v3s(1, 0, 1);
    case(Child.backRightTop):     return v3s(0, 1, 1);
    case(Child.frontRightTop):    return v3s(1, 1, 1);
  }
}

/// Crumbs are path from root to specific subtree
struct Crumbs {
  Array!Child crumbs;
  alias crumbs this;

  /// Allows to make crumbs with direct enumeration of path in argument list
  this(Child[] elems...) {
    crumbs = Array!Child(elems);
  }

  /// Return depth of current subtree the crumbs pointing to
  size_t depth() inout {
    return crumbs.length;
  }

  /// Return current subtree index within all other subtrees of
  /// the same depth. It is index of sell if the tree is filled
  /// with cubes of same size of the current subtree.
  v3s gridIndex() inout {
    const d = depth;
    v3s go(v3s acc, size_t i) {
      if(i >= d) return acc;
      return go((acc << 1) + crumbs[i].childOffset, i+1);
    }
    return go(v3s(0, 0, 0), 0);
  }
  unittest {
    assert(Crumbs().gridIndex == v3s(0, 0, 0));
    assert(Crumbs(Child.frontRightBottom).gridIndex == v3s(1, 1, 0));
    assert(Crumbs(Child.frontRightTop).gridIndex == v3s(1, 1, 1));
    assert(Crumbs(Child.frontRightTop, Child.frontRightTop).gridIndex == v3s(3, 3, 3));
    assert(Crumbs(Child.frontRightTop, Child.backRightBottom).gridIndex == v3s(2, 3, 2));
    assert(Crumbs(Child.frontRightTop, Child.frontRightTop, Child.frontRightTop).gridIndex == v3s(7, 7, 7));
    assert(Crumbs(Child.frontRightTop, Child.backRightBottom, Child.backRightBottom).gridIndex == v3s(4, 7, 4));
  }
}

/// Octo tree separates cubic volume to 8 subcubes. The implementation is packed
/// into array and has interpolation data in non leaf nodes for LOD.
struct OctoTree(T, index = ushort) {
  /// One node of octree
  struct Node {
    /// Flags that indicates that corresponding subtree is not empty
    ubyte flags;
    /// Subtrees with indecies to next node
    index[8] children;
    /// Data in the node
    T data;
  }

  /// Root node of the octree. Can be reassigned on resizes.
  index root = 0;
  /// Nodes of octree in packed array.
  Array!Node nodes;

  /// Shortcut for self
  alias This = OctoTree!(T, index);

  /** Generate the octotree using delegates
  * @param genFunc delegate that first checks whether we go deeper or generate at given stage.
  *        `null` is go deeper either return value means generate here.
  *         Crumbs parameter indicates which node we are checking at the moment.
  * @param combineFunc delegate that takes data of children and interpolates to new value in upper nonleaf.
  */
  static This generate(Nullable!T delegate(Crumbs) genFunc, T delegate(T, T) combineFunc)
  {
    return This();
  }
}
unittest {
  Nullable!v3f genIndexed(size_t d, Crumbs c) {
    if(c.depth < d) return Nullable!v3f();
    return nullable(cast(v3f)c.gridIndex);
  }

  auto octree = OctoTree!v3f.generate(
    (c) => genIndexed(1, c), // Stop right after root node
    (a, b) => (a + b) / 2
    );

}
