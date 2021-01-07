module treerender.world;

public import treerender.component;

import treerender.input;
import treerender.math.vector;
import std.math;
import std.random;
import std.typecons;

/// The game uses Entity-Component-System (ECS) design where all game entities
/// are decomposed into data pieces called Components. Components are stored
/// in structure-of-arrays style and an entity is a simple integer that points
/// to the arrays.
class World {
  /// Container for all storages of the world supported.
  Storages!AllComponents storages;

  final:

  /// Intialize internal storage, allocates memory for them
  this(string soundsDir) {
    storages.init();
    storages.rng.global = Rng(Random(unpredictableSeed)); // seeding random number generator
    initCamera();
  }

  ///  Make one tick of world simulation with given inputs. Return non zero if failed.
  void step(float dt, in InputEvents events) {
    storages.deltaTime.global = dt;
    applyEvents(dt, events);
  }

  /// Maintain world delayed actions
  void maintain() {
    storages.entities.maintain();
  }

  /// Render world in current frame
  void render() {

  }

  /// Get current active camera. Renderer use this method to get view-projection
  /// matrix.
  Nullable!Camera activeCamera() inout {
    const e = storages.activeCamera.global.cameraEntity;
    if (storages.entities.has(e)) {
      return nullable(storages.camera.get(e));
    } else {
      return Nullable!Camera();
    }
  }

  /// Apply player input to ship components
  private void applyEvents(float dt, InputEvents inputs) {
    auto mcam = activeCamera;
    if(!mcam.isNull) {
      auto e = storages.activeCamera.global.cameraEntity;
      const x = inputs.playerMouseDelta.x;
      const y = inputs.playerMouseDelta.y;
      if(x != 0 || y != 0 || inputs.playerForward || inputs.playerBack || inputs.playerLeft || inputs.playerRight || inputs.playerJump || inputs.playerCrouch) {
        auto cam = mcam.get;

        if(x != 0) cam = cam.rotateUp(-x * dt * Camera.rotationSpeed);
        if(y != 0) cam = cam.rotateRight(-y * dt * Camera.rotationSpeed / storages.windowSize.global.aspect);

        if(inputs.playerForward) cam = cam.moveForward(dt * Camera.moveSpeed);
        if(inputs.playerBack) cam = cam.moveForward(-dt * Camera.moveSpeed);
        if(inputs.playerRight) cam = cam.moveRight(dt * Camera.moveSpeed);
        if(inputs.playerLeft) cam = cam.moveRight(-dt * Camera.moveSpeed);
        if(inputs.playerJump) cam = cam.moveUp(dt * Camera.moveSpeed);
        if(inputs.playerCrouch) cam = cam.moveUp(-dt * Camera.moveSpeed);

        storages.camera.insert(e, cam);
      }
    }
  }

  /// Initialize default camera and make it active
  private void initCamera() {
    auto e = storages.entities.create();
    auto cam = Camera().perspective(PI/3, storages.windowSize.global.aspect, 0.001, 100).lookAt(v3f(-1.5, 0, -1.5), v3f(0, 0, 0), v3f(0, 1, 0));
    storages.camera.insert(e, cam);
    storages.activeCamera.global = e;
  }
}
