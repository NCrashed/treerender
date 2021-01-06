module treerender.component.camera;

import decs.entity;
import decs.storage.global;
import decs.storage.vector;
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
    auto rm = rot.matrix;
    const xaxis = rm.row(0).xyz;
    const yaxis = rm.row(1).xyz;
    const zaxis = rm.row(2).xyz;
    rm[0, 3] = -xaxis.dot(pos);
    rm[1, 3] = -yaxis.dot(pos);
    rm[2, 3] = -zaxis.dot(pos);
    return rm;
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
    ret.pos = eye;
    ret.rot = quatf.fromMatrix(lookAtMatrix(eye, target, up));
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
