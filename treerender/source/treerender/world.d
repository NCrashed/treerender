module treerender.world;

public import treerender.component;

import treerender.input;
import std.random;

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
  }

  ///  Make one tick of world simulation with given inputs. Return non zero if failed.
  void step(float dt, in InputEvents events) {
    storages.deltaTime.global = dt;
  }

  /// Maintain world delayed actions
  void maintain() {
    storages.entities.maintain();
  }

  /// Render world in current frame
  void render() {

  }

  /// Apply player input to ship components
  private void applyEvents(float dt, InputEvents inputs) {

  }
}
