module treerender.geometry.octomesh;

import treerender.geometry.greedy;
import treerender.geometry.mesh;
import treerender.geometry.octo;
import treerender.geometry.voxel;
import treerender.geometry.color;

struct VoxelNode(T = Color, size_t n = 16, Primitive prim = Primitive.triangles) if(isVoxel!T) {
  Voxels!(T, n) voxels;
  Mesh!(T, prim) mesh;
}

alias OctoMesh(T = Color, size_t n = 16, Primitive prim = Primitive.triangles)
  = OctoTree!(VoxelNode!(T, n, prim));

/// Procedural generation of octo tree with mesh
OctoMesh!(T, n, prim) octoProcedural(T, n, prim)(size_t maxDepth, T delegate(v3f) gen) {
  return OctoMesh!(T, n, prim).generate(
    (c) => c.depth >= maxDepth ? GenCheck.generate : GenCheck.deeper,
    (c) => A(VoxelNode!(T, n, prim).generate((v) => c.cubeStart + cast(v3f)v / c.gridSize)),
    (a, b) => a.blend(b)
    );
}
