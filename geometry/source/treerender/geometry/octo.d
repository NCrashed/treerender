module treerender.geometry.octo;

import std.container.array;

/// Octo tree separates cubic volume to 8 subcubes. The implementation is packed
/// into array and has interpolation data in non leaf nodes for LOD.
struct OctoTree(T, index = ushort) {
  /// Indexing child cube within node
  enum Child: size_t {
    backLeftBottom   = 0,
    frontLeftBottom  = 1,
    backRightBottom  = 2,
    frontRightBottom = 3,
    backLeftTop      = 4,
    frontLeftTop     = 5,
    backRightTop     = 6,
    frontRightTop    = 7,
  }

  /// One node of octree
  struct Node {
    /// Flags that indicates that corresponding subtree is not empty
    ubyte flags;
    /// Subtrees with indecies to next node
    index[8] children;
    /// Data in the node
    T data;
  }

  /// Nodes of octree. Root node is always first node of array.
  Array!Node nodes;
}
