module treerender.component.camera;

import decs.entity;
import decs.storage.global;
import decs.storage.vector;
import treerender.math.matrix;
import treerender.math.quaternion;
import treerender.math.v3;

/// Describes a view into game world. Contains translation, rotation and pespective
/// information.
struct Camera {
  /// Projection matrix. Remaps camera space to rasterization space.
  /// Usually it is perspective matrix, can be ortho projection matrix.
  mat4 proj;
  /// Rotation of camera
  quatf rot;
  /// Position of camera
  v3f pos;

  /// Name of component
  enum name = "camera";
  /// We store size as global value
  alias Storage = VecStorage!Camera;

  /** Make camera with perspective projection
  * @par fovy - field of view angle in radians
  * @par aspect - height / width of viewport
  * @par near - distance to near clip plane from camera
  * @par far - distance to far clip plane from camera
  */
  static Camera perspective(float fovy, float aspect, float near, float far) {
    Camera cam;
    cam.proj = projection!float(fovy, aspect, near, far);
    cam.rot = quatf.fromAxis(v3f(0, 0, 1), 0);
    cam.pos = v3f(0, 0, 0);
    return cam;
  }

  /// Get view matrix from the camera
  mat4 view() inout {
    return pos.translation * rot.matrix;
  }
}

/// Tag that given entity has camera which should be used for rendering.
struct ActiveCamera {
  Entity cameraEntity;
  alias cameraEntity this;

  /// Name of component
  enum name = "activeCamera";
  /// We store size as global value
  alias Storage = GlobalStorage!ActiveCamera;
}
