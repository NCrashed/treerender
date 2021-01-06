module treerender.component.size;

import decs.storage.global;
import treerender.math.vector;

/// Window size of renderer
struct WindowSize {
  v2i v;
  alias v this;

  /// Name of component
  enum name = "windowSize";
  /// We store size as global value
  alias Storage = GlobalStorage!WindowSize;

  int width() inout {
    return v.x;
  }

  void width(int w) {
    v.x = w;
  }

  int height() inout {
    return v.y;
  }

  void height(int h) {
    v.y = h;
  }

  /// Calculate aspect ratio of window
  float aspect() inout {
    return cast(float)v.y / cast(float)v.x;
  }
}
