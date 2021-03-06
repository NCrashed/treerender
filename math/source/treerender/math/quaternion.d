module treerender.math.quaternion;

import treerender.math.matrix;
import treerender.math.trigonometry;
import treerender.math.vector;
import std.math;

alias quatf = Quaternion!float;
alias quatd = Quaternion!double;

/// Quaternion is math object that describes rotation in 4D space and used for
/// rotation in 3D as it preserves order and doesn't have gimbal lock.
struct Quaternion(T) {
  T x, y, z, w;

  alias This = Quaternion!T;

  /// Return vector component fo quaternion. It is not axis (actually scaled axis).
  vec3!T vec() inout {
    return vec3!T(x, y, z);
  }

  /// Return axis of rotation for quaternion.
  vec3!T axis() inout {
    return vec.normalized;
  }

  /// Set vector component of the quaternion
  void vec(vec3!T v) {
    x = v.x;
    y = v.y;
    z = v.z;
  }

  /// Define rotation from axis and angle.
  /// @par axis Axis aroun which rotation perfromed, can be not normalized.
  /// @par angle Angle in radians.
  static This fromAxis(vec3!T axis, T angle) {
    T t = void;
    T c = void;
    sinCos(angle/2, t, c);

    const n = axis.normalized;
    return This(n.x * t, n.y * t, n.z * t, c);
  }

  /// Define rotation fro three Euler angles
  static This fromAngles(T pitch, T yaw, T roll) {
    T cosz, sinz, cosy, siny, cosx, sinx;
    sinCos(pitch/2, cosx, sinx);
    sinCos(yaw/2, cosy, siny);
    sinCos(roll/2, cosz, sinz);

    const w = cosz * cosy * cosx + sinz * siny * sinx;
    const x = cosz * cosy * sinx + sinz * siny * cosx;
    const y = cosz * siny * cosx + sinz * cosy * sinx;
    const z = sinz * cosy * cosx + cosz * siny * sinx;
    return This(x, y, z, w);
  }

  /// Create from rotation matrix
  static This fromMatrix(Matrix!(T, 4, 4) m)
	{
		This ret;
    float tr = m[0,0] + m[1,1] + m[2,2]; // trace of martix
    if (tr > 0.0f) { // if trace positive than "w" is biggest component
      ret.x = (m[1,2] - m[2,1]);
			ret.y = (m[2,0] - m[0,2]);
			ret.z = (m[0,1] - m[1,0]);
			ret.w = (tr+1.0f);
			auto t = 0.5/sqrt( ret.w );  // "w" contain the "norm * 4"
			ret.x*=t;
			ret.y*=t;
			ret.z*=t;
			ret.w*=t;
    } else if( (m[0,0] > m[1,1] ) && ( m[0,0] > m[2,2]) ) { // Some of vector components is bigger
			ret.x = (1.0f + m[0,0] - m[1,1] - m[2,2]);
			ret.y = (m[1,0] + m[0,1]);
			ret.z = (m[2,0] + m[0,2]);
			ret.w = (m[1,2] - m[2,1]);
			auto t = 0.5/sqrt( ret.x );
			ret.x*=t;
			ret.y*=t;
			ret.z*=t;
			ret.w*=t;
		} else if ( m[1,1] > m[2,2] ) {
			ret.x = m[1,0] + m[0,1];
			ret.y = 1.0f + m[1,1] - m[0,0] - m[2,2];
			ret.z = m[2,1] + m[1,2];
			ret.w = m[2,0] - m[0,2];
			auto t = 0.5/sqrt( ret.y );
			ret.x*=t;
			ret.y*=t;
			ret.z*=t;
			ret.w*=t;
		} else {
			ret.x = m[2,0] + m[0,2];
			ret.y = m[2,1] + m[1,2];
			ret.z = 1.0f + m[2,2] - m[0,0] - m[1,1];
			ret.w = m[0,1] - m[1,0];
			auto t = 0.5/sqrt( ret.z );
			ret.x*=t;
			ret.y*=t;
			ret.z*=t;
			ret.w*=t;
		}
		return ret;
	}

  /// Convert quaternion to rotation matrix
  Matrix!(T, 4) matrix() inout {
    auto ret = Matrix!(T, 4).zeros;
    T wx, wy, wz, xx, yy, yz, xy, xz, zz, x2, y2, z2;
    auto s  = 2 / length;
    x2 = x * s;    y2 = y * s;    z2 = z * s;
    xx = x * x2;   xy = x * y2;   xz = x * z2;
    yy = y * y2;   yz = y * z2;   zz = z * z2;
    wx = w * x2;   wy = w * y2;   wz = w * z2;

    ret[0,0] = 1 - (yy + zz);
    ret[1,0] = xy - wz;
    ret[2,0] = xz + wy;

    ret[0,1] = xy + wz;
    ret[1,1] = 1 - (xx + zz);
    ret[2,1] = yz - wx;

    ret[0,2] = xz - wy;
    ret[1,2] = yz + wx;
    ret[2,2] = 1 - (xx + yy);
    ret[3,3] = 1;
    return ret;
  }

	/// Length of quaternion
	T length() inout {
		return length2.sqrt;
	}

  /// Squared length. Help to avoid costly sqrt
	T length2() inout {
		return w*w + x*x + y*y + z*z;
	}

	/// Conjugation of this quaternion
	This conjugation() inout {
		return This(x, y, z, -w);
	}

	/// Makint new quaternion with unit length from this one
	This normalize() inout {
    const l = length;
    return This(x/l, y/l, z/l, w);
	}

	/// Inverse quaternion represents inverse rotation
	This invert() inout {
    return conjugation.normalize;
	}

  /// Multiplication of quaternions is how rotation is composed
  This opBinary(string op)(This q) inout if(op=="*")
	{
		This ret; // a = w, b = x, c = y, d = z
		ret.x = w*q.x + x*q.w + y*q.z - z*q.y; // a1*b2+b1*a2+c1*d2-d1*c2
		ret.y = w*q.y - x*q.z + y*q.w + z*q.x; // a1*c2-b1*d2+c1*a2+d1*b2
		ret.z = w*q.z + x*q.y - y*q.x + z*q.w; // a1*d2+b1*c2-c1*b2+d1*a2
		ret.w = w*q.w - x*q.x - y*q.y - z*q.z; // a1*a2-b1*b2-c1*c2-d1*d2
		return ret;
	}

  /// Rotate vector with given quaternion
  vec3!T rotate(vec3!T v) inout {
    const u = this.vec;
    return 2 * u.dot(v) * u + (w*w - u.dot(u)) * v + 2 * w * u.cross(v);
  }
}
