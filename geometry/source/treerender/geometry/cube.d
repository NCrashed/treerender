module treerender.geometry.cube;

import std.traits;
import treerender.geometry.axis;
import treerender.geometry.mesh;
import treerender.geometry.side;
import treerender.math.v2;
import treerender.math.v3;

/// Write cube side of given $(B size) in voxels to given mesh at voxel $(B pos) for grid of size $(B n).
void insertCubeSide(Side s, Primitive p, size_t n, T)(Mesh!T mesh, v3u pos, v2u size, T value)
{
  float norm(uint v) { return cast(float)v / cast(float)n; }

  const normal = cast(v3f)s.sideOffset;

  static if(s == Side.forward) const xn = norm(pos.x+1);
  else const xn = norm(pos.x);

  static if(s == Side.right) const yn = norm(pos.y+1);
  else const yn = norm(pos.y);

  static if(s == Side.up) const zn = norm(pos.z+1);
  else const zn = norm(pos.z);

  const w = size.x;
  const h = size.y;

  static if(s.sideAxis == Axis.x) {
    const p0 = v3f(xn, yn, zn);
    const p1 = v3f(xn, norm(pos.y + w), zn);
    const p2 = v3f(xn, norm(pos.y + w), norm(pos.z + h));
    const p3 = v3f(xn, yn, norm(pos.z + h));
  } else static if(s.sideAxis == Axis.y) {
    const p0 = v3f(xn, yn, zn);
    const p1 = v3f(norm(pos.x + w), yn, zn);
    const p2 = v3f(norm(pos.x + w), yn, norm(pos.z + h));
    const p3 = v3f(xn, yn, norm(pos.z + h));
  } else {
    const p0 = v3f(xn, yn, zn);
    const p1 = v3f(norm(pos.x + w), yn, zn);
    const p2 = v3f(norm(pos.x + w), norm(pos.y + h), zn);
    const p3 = v3f(xn, norm(pos.y + h), zn);
  }

  const u0 = v2f(0, cast(float)h);
  const u1 = v2f(cast(float)w, cast(float)h);
  const u2 = v2f(cast(float)w, 0);
  const u3 = v2f(0, 0);

  auto i = mesh.currentIndex;
  mesh.insertVertex(p0, normal, u0, value);
  mesh.insertVertex(p1, normal, u1, value);
  mesh.insertVertex(p2, normal, u2, value);
  mesh.insertVertex(p3, normal, u3, value);

  static if(p == Primitive.triangles) {
    static if(s == Side.forward || s == Side.left || s == Side.up) {
      mesh.insertTriangle(i + v3u(0, 1, 3));
      mesh.insertTriangle(i + v3u(1, 2, 3));
    } else {
      mesh.insertTriangle(i + v3u(3, 1, 0));
      mesh.insertTriangle(i + v3u(3, 2, 1));
    }
  } else static if(p == Primitive.lines) {
    mesh.insertLine(i + v2u(0, 1));
    mesh.insertLine(i + v2u(1, 3));
    mesh.insertLine(i + v2u(3, 0));
    mesh.insertLine(i + v2u(1, 2));
    mesh.insertLine(i + v2u(2, 3));
    mesh.insertLine(i + v2u(3, 1));
  }
}

Mesh!NoData makeCube() {
  auto mesh = Mesh!NoData.allocate(12);
  static foreach(s; [EnumMembers!Side]) {
    mesh.insertCubeSide!(s, Primitive.triangles, 1)(v3u(0,0,0), v2u(1,1), NoData());
  }
  return mesh;
}
