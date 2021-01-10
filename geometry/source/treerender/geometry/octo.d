module treerender.geometry.octo;

import std.container.array;
import std.range;
import std.traits;
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

  /// Copy constructor
  this(Array!Child elems) {
    crumbs = elems;
  }

  /// Allows to make crumbs with direct enumeration of path in argument list
  this(Child[] elems...) {
    crumbs = Array!Child(elems);
  }

  /// Return depth of current subtree the crumbs pointing to
  size_t depth() inout {
    return crumbs.length;
  }

  /// Add child to path with copying of whole array
  Crumbs add(Child c) inout {
    auto ret = (cast(Array!Child)crumbs).dup();
    ret.insertBack(c);
    return Crumbs(ret);
  }

  /// Return current subtree index within all other subtrees of
  /// the same depth. It is index of sell if the tree is filled
  /// with cubes of same size of the current subtree.
  v3s gridIndex() inout {
    auto d = depth;
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

/// Result of check delegate in $(REF generate) that indicates whether we need
/// to go deeper or generate leaf of marks an empty node.
enum GenCheck {
  deeper,
  generate,
  empty,
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
  * @param checkFunc delegate that returns `GenCheck.generate` when we should stop and generate leaf,
  * `GenCheck.deeper` when we need go deeper and `GenCheck.empty` if given node is empty.
  * @param genFunc delegate that generates leaf node. Crumbs parameter indicates which node we are checking at the moment.
  * @param combineFunc delegate that takes data of children and interpolates to new value in upper nonleaf.
  */
  static This generate(GenCheck delegate(const Crumbs) checkFunc, T delegate(const Crumbs) genFunc, T delegate(T, T) combineFunc)
  {
    auto tree = This();
    index go(Crumbs crumbs) {
      if(checkFunc(crumbs) == GenCheck.deeper) {
        index[8] children;
        ubyte tags;
        T interpolated;
        foreach(s; [EnumMembers!Child]) {
          auto childCrumbs = crumbs.add(s);
          if(checkFunc(childCrumbs) != GenCheck.empty) {
            children[cast(size_t)s] = go(childCrumbs);
            tags &= 1 << s;
            interpolated = combineFunc(interpolated, tree.nodes[children[cast(size_t)s]].data);
          }
        }
        Node node = { flags: tags, children: children, data: interpolated };
        auto i = cast(index)tree.nodes.length;
        tree.nodes.insertBack(node);
        return i;
      } else {
        Node node = { data: genFunc(crumbs) };
        const i = cast(index)tree.nodes.length;
        tree.nodes.insertBack(node);
        return i;
      }
    }
    const root = go(Crumbs());
    tree.root = root;
    return tree;
  }
}
unittest {
  struct Node {
    v3f value = v3f(0, 0, 0);
    alias value this;
  }
  import std.stdio;
  auto octree = OctoTree!Node.generate(
    (c) => c.depth >= 1 ? GenCheck.generate : GenCheck.deeper, // Stop right after root node
    (c) => Node(cast(v3f)c.gridIndex),
    (a, b) => Node((a.value + b.value) / 2)
    );

  writeln(octree.nodes[8]);
}
