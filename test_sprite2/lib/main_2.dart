import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setOrientation(DeviceOrientation.portraitUp);
  final game = MyGame();
  runApp(
    GameWidget(game: game),
  );
}

enum CharacterState {
  idle,
  running,
}

class MyGame extends FlameGame with MultiTouchDragDetector, TapDetector {
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimationGroupComponent<CharacterState> character;
  CharacterState state = CharacterState.idle;
  Vector2? targetPosition;
  bool isMoving = false;
  final double fixedDistance = 50.0;

  @override
  Future<void> onLoad() async {
    try {
      final image = await Flame.images.load('practice.png');
      if (kDebugMode) {
        print("Image loaded: ${image.width} x ${image.height}");
      }

      // Manual frame creation
      final frameSize = Vector2(82, 82);
      final runningFrames = [
        Sprite(image, srcPosition: Vector2(0, 0), srcSize: frameSize),
        Sprite(image, srcPosition: Vector2(80, 0), srcSize: frameSize),
        Sprite(image, srcPosition: Vector2(160, 0), srcSize: frameSize),
        Sprite(image, srcPosition: Vector2(240, 0), srcSize: frameSize),
      ];

      final idleFrames = [
        Sprite(image, srcPosition: Vector2(80, 0), srcSize: frameSize),
      ];

      runningAnimation =
          SpriteAnimation.spriteList(runningFrames, stepTime: 0.1);
      idleAnimation = SpriteAnimation.spriteList(idleFrames, stepTime: 1);

      character = SpriteAnimationGroupComponent<CharacterState>(
        animations: {
          CharacterState.running: runningAnimation,
          CharacterState.idle: idleAnimation,
        },
        current: CharacterState.idle,
        position: Vector2(100, 100),
      );

      await add(character);

      if (kDebugMode) {
        print("Running Animation: ${runningAnimation.frames.length}");
        print("Idle Animation: ${idleAnimation.frames.length}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error during onLoad: $e");
      }
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    final direction =
        (info.eventPosition.game - character.position).normalized();
    targetPosition = character.position + direction * fixedDistance;
    state = CharacterState.running;
    character.current = CharacterState.running;
    isMoving = true;
  }

  @override
  void onDragStart(int pointerId, DragStartInfo info) {
    super.onDragStart(pointerId, info);
    targetPosition = info.eventPosition.game;
    state = CharacterState.running;
    character.current = CharacterState.running;
    isMoving = true;
  }

  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    super.onDragUpdate(pointerId, info);
    targetPosition = info.eventPosition.game;
  }

  @override
  void onDragEnd(int pointerId, DragEndInfo info) {
    super.onDragEnd(pointerId, info);
    isMoving = false;
  }

  @override
  void onDragCancel(int pointerId) {
    super.onDragCancel(pointerId);
    isMoving = false;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (targetPosition != null) {
      final moveVector = targetPosition! - character.position;
      if (moveVector.length < 5) {
        character.position = targetPosition!;
        targetPosition = null;
        state = CharacterState.idle;
        character.current = CharacterState.idle;
        isMoving = false;
      } else {
        moveVector.normalize();
        character.position += moveVector * 150 * dt; // 100 is the speed.
        state = CharacterState.running;
        character.current = CharacterState.running;
      }
    } else {
      state = CharacterState.idle;
      character.current = CharacterState.idle;
    }
  }
}
