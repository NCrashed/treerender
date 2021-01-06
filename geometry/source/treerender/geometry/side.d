module treerender.geometry.side;

import std.typecons;
import treerender.geometry.axis;
import treerender.math.vector;

/// Encoding of one of 6 directions of faces of cube
enum Side {
  backward,
  forward,
  left,
  right,
  down,
  up,
}

/// Coordinates offset by side
v3i sideOffset(Side side) {
  final switch(side) {
    case Side.forward:  return (v3i( 1,  0,  0));
    case Side.backward: return (v3i(-1,  0,  0));
    case Side.right:    return (v3i( 0,  1,  0));
    case Side.left:     return (v3i( 0, -1,  0));
    case Side.up:       return (v3i( 0,  0,  1));
    case Side.down:     return (v3i( 0,  0, -1));
  }
}

/// Revert of $(REF sideOffset)
Nullable!Side offsetSide(v3i v) {
  auto vs = v.signum;
  if(vs == v3i( 1,  0,  0)) return nullable(Side.forward);
  if(vs == v3i(-1,  0,  0)) return nullable(Side.backward);
  if(vs == v3i( 0,  1,  0)) return nullable(Side.right);
  if(vs == v3i( 0, -1,  0)) return nullable(Side.left);
  if(vs == v3i( 0,  0,  1)) return nullable(Side.up);
  if(vs == v3i( 0,  0, -1)) return nullable(Side.down);
  return Nullable!Side();
}

/// Get opposite side of given
Side oppositeSide(Side side) {
  final switch(side) {
    case Side.forward:  return Side.backward;
    case Side.backward: return Side.forward;
    case Side.right:    return Side.left;
    case Side.left:     return Side.right;
    case Side.up:       return Side.down;
    case Side.down:     return Side.up;
  }
}

/// Return `true` if given side facing negative direction
bool sideNegative(Side side) {
  final switch(side) {
    case Side.forward:  return false;
    case Side.backward: return true;
    case Side.right:    return false;
    case Side.left:     return true;
    case Side.up:       return false;
    case Side.down:     return true;
  }
}

/// Return `true` if given side facing positive direction
bool sidePositive(Side side) {
  return !side.sideNegative;
}

/// Get axis of side
Axis sideAxis(Side side) {
  final switch(side) {
    case Side.forward:  return Axis.x;
    case Side.backward: return Axis.x;
    case Side.right:    return Axis.y;
    case Side.left:     return Axis.y;
    case Side.up:       return Axis.z;
    case Side.down:     return Axis.z;
  }
}
