module treerender.geometry.mesh;

import std.container.array;
import treerender.math.v2;
import treerender.math.v3;

/// Primitive types that are located inside mesh
enum Primitive {
  triangles,
  lines,
}

/// Amount of indices in primitive
size_t primitiveParts(Primitive p) {
  final switch(p) {
    case Primitive.triangles: return 3;
    case Primitive.lines: return 2;
  }
}

/// Encapsulates indices that are required to define a one instance of primitive
struct PrimIndex(Primitive prim) {
  static if (prim == Primitive.triangles) {
    uint start;
    uint middle;
    uint end;
  } else static if (prim == Primitive.lines) {
    uint start;
    uint end;
  }
}

/// Zero size place holder for mesh where no additional data is required
struct NoData {}

/// Mes is set of triangles with attached data to each vertex.
struct Mesh(T, Primitive primitive = Primitive.triangles) {
  /// All vertecies of mesh
  Array!v3f vertices;
  /// Normal vector of vertecies, each vertex has corresponding normal.
  Array!v3f normals;
  /// Texture coordinates of vertecies, each vertex has corresponding uv.
  Array!v2f uvs;
  /// Vertex custom data (for instance color)
  Array!T data;
  /// Indecies of primitives
  Array!(PrimIndex!primitive) indices;

  /// Alias to self
  alias This = Mesh!(T, primitive);

  /// Allocate mesh for given amount of primitives
  static This allocate(size_t n) {
    Array!T prealloc(T)(size_t i) {
      Array!T arr;
      arr.reserve(i);
      return arr;
    }
    enum k = primitiveParts(primitive);
    return Mesh(
        prealloc!v3f(k * n),
        prealloc!v3f(k * n),
        prealloc!v2f(k * n),
        prealloc!T(k * n),
        prealloc!(PrimIndex!primitive)(n),
      );
  }

  /// Get next free index value for vertex
  uint currentIndex() inout {
    return cast(uint)vertices.length;
  }

  /// Write single vertex into mesh
  void insertVertex(v3f position, v3f normal, v2f uv, T value) {
    vertices.insert(position);
    normals.insert(normal);
    uvs.insert(uv);
    data.insert(value);
  }

  /// Write triangle indices to mesh
  void insertTriangle()(v3u i) if(primitive == Primitive.triangles) {
    indices.insert(PrimIndex!primitive(i.x, i.y, i.z));
  }

  /// Write triangle indices to mesh
  void insertLine()(v2u i) if(primitive == Primitive.lines) {
    indices.insert(PrimIndex!primitive(i.x, i.y));
  }
}
unittest {
  auto test = Mesh!float.allocate(100);
  test.insertVertex(v3f(1.0, 1.0, 1.0), v3f(0.1, 0.1, 0.1), v2f(2.0, 2.0), 42.0);
  test.insertVertex(v3f(1.0, 1.0, 2.0), v3f(0.1, 0.1, 0.1), v2f(2.0, 2.0), 23.0);
  test.insertVertex(v3f(1.0, 1.0, 3.0), v3f(0.1, 0.1, 0.1), v2f(2.0, 2.0), 16.0);
  test.insertTriangle(v3u(0, 1, 2));
}
unittest {
  auto test = Mesh!(float, Primitive.lines).allocate(100);
  test.insertVertex(v3f(1.0, 1.0, 1.0), v3f(0.1, 0.1, 0.1), v2f(2.0, 2.0), 42.0);
  test.insertVertex(v3f(1.0, 1.0, 2.0), v3f(0.1, 0.1, 0.1), v2f(2.0, 2.0), 23.0);
  test.insertLine(v2u(0, 1));
}
unittest {
  auto test = Mesh!NoData.allocate(100);
  test.insertVertex(v3f(1.0, 1.0, 1.0), v3f(0.1, 0.1, 0.1), v2f(2.0, 2.0), NoData());
  test.insertVertex(v3f(1.0, 1.0, 2.0), v3f(0.1, 0.1, 0.1), v2f(2.0, 2.0), NoData());
  test.insertVertex(v3f(1.0, 1.0, 3.0), v3f(0.1, 0.1, 0.1), v2f(2.0, 2.0), NoData());
  test.insertTriangle(v3u(0, 1, 2));
}
