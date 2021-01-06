module treerender.input;

import treerender.math.vector;

struct InputEvents {
  bool playerLeft = false;
  bool playerRight = false;
  bool playerForward = false;
  bool playerBack = false;
  bool playerJump = false;
  bool playerPrimAction = false;
  v2i playerMouseDelta = v2i(0, 0);
}
