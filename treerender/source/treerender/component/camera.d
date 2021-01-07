module treerender.component.camera;

import decs.entity;
import decs.storage.global;
import decs.storage.vector;
import std.math;
import treerender.math.matrix;
import treerender.math.quaternion;
import treerender.math.vector;

/// Type of projections
enum ProjType {
  perspective
, orthographic
}

/// Container that holds on of `Projection` type
struct Projection {
  ProjType tag;
  union {
    Perspective persp;
    Orthographic ortho;
  }

  /// Make perspective projection in internal tagged union
  static Projection makePerspective(float fovy, float aspect, float near, float far) {
    Projection ret;
    ret.tag = ProjType.perspective;
    ret.persp = Perspective(fovy, aspect, near, far);
    return ret;
  }

  /// Make orthographic projection in internal tagged union
  static Projection makeOrthographic(float right, float aspect, float near, float far) {
    Projection ret;
    ret.tag = ProjType.orthographic;
    ret.ortho = Orthographic(right, aspect, near, far);
    return ret;
  }

  /// Get projection matrix for stored projection way
  mat4 matrix() inout {
    final switch(tag) {
      case(ProjType.perspective): return persp.matrix;
      case(ProjType.orthographic): return ortho.matrix;
    }
  }

  /// Get aspect ratio
  float aspect() inout {
    return persp.aspect; // exploit that aspect is always second float
  }

  /// Set aspect ratio
  void aspect(float v) {
    persp.aspect = v; // exploit that aspect is always second float
  }

  private:

  struct Perspective {
    float fovy;
    float aspect;
    float near;
    float far;

    mat4 matrix() inout {
      return projection!float(fovy, aspect, near, far);
    }
  }

  struct Orthographic {
    float right;
    float aspect;
    float near;
    float far;

    mat4 matrix() inout {
      const left = -right;
      const top = right * aspect;
      const bottom = -top;
      return orthographic!float(left, right, bottom, top, near, far);
    }
  }
}

/// Describes a view into game world. Contains translation, rotation and pespective
/// information.
struct Camera {
  /// Projection info. Remaps camera space to rasterization space.
  /// Usually it is perspective matrix, can be ortho projection matrix.
  Projection proj;
  /// Position of camera
  v3f eye;
  /// Direction of camera
  v3f dir;
  /// Up vector of camera
  v3f up;

  /// Name of component
  enum name = "camera";
  /// We store size as global value
  alias Storage = VecStorage!Camera;
  /// Constatn rotation speed by mouse
  enum rotationSpeed = 4*PI;

  /** Make camera with perspective projection
  * @par fovy - field of view angle in radians
  * @par aspect - height / width of viewport
  * @par near - distance to near clip plane from camera
  * @par far - distance to far clip plane from camera
  */
  Camera perspective(float fovy, float aspect, float near, float far) inout {
    Camera cam = this;
    cam.proj = Projection.makePerspective(fovy, aspect, near, far);
    return cam;
  }

  /** Make camera with orthographic projection
  * @par right - half of width to the right
  * @par aspect - height / width of viewport
  * @par near - distance to near clip plane from camera
  * @par far - distance to far clip plane from camera
  */
  Camera orthographic(float right, float aspect, float near, float far) inout {
    Camera cam = this;
    cam.proj = Projection.makeOrthographic(right, aspect, near, far);
    return cam;
  }

  /// Get view matrix from the camera
  mat4 view() inout {
    return lookAtMatrix(eye, eye+dir, up);
  }

  /// Get projection matrix from the camera
  mat4 projection() inout {
    return proj.matrix;
  }

  /// Return current aspect ratio of camera
  float aspect() inout {
    return proj.aspect;
  }

  /// Set aspect ratio of camera
  void aspect(float v) {
    proj.aspect = v;
  }

  /// Construct new camera that looks at given location
  Camera lookAt(v3f eye, v3f target, v3f up) inout {
    Camera ret = this;
    ret.eye = eye;
    ret.dir = (target-eye).normalized;
    ret.up = up;
    return ret;
  }

  /// Rotate current camera around right axis of camera. It is pitch rotation.
  Camera rotateRight(float angle) inout {
    Camera ret = this;
    const right = dir.cross(up);
    const q = quatf.fromAxis(right, angle);
    ret.dir = q.rotate(dir);
    ret.up = q.rotate(up);
    return ret;
  }

  /// Rotate current camera around up axis of camera. It is yaw rotation.
  Camera rotateUp(float angle) inout {
    Camera ret = this;
    ret.dir = quatf.fromAxis(up, angle).rotate(dir);
    return ret;
  }

  /// Rotate current camera around forward axis of camera. It is roll rotation.
  Camera rotateForward(float angle) inout {
    Camera ret = this;
    ret.up = quatf.fromAxis(dir, angle).rotate(up);
    return ret;
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
