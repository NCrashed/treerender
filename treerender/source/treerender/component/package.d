module treerender.component;

public import treerender.component.camera;
public import treerender.component.delta;
public import treerender.component.rand;
public import treerender.component.size;

public import decs;

// Also injects AllComponents alias to the list
mixin DeclareComponents!(
  Rng,
  DeltaTime,
  WindowSize,
  Camera,
  ActiveCamera,
  );
