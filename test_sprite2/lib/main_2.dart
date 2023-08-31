import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
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

class MyGame extends FlameGame with TapCallbacks {
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimationGroupComponent<CharacterState> character;
  CharacterState state = CharacterState.idle;

  @override
  Future<void> onLoad() async {
    try {
      final image = await Flame.images.load('practice.png');
      if (kDebugMode) {
        print("Image loaded: ${image.width} x ${image.height}");
      }

      // Manual frame creation
      final frameSize = Vector2(80, 80);
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


    bool isMoving = false; // 캐릭터가 움직이고 있는지를 나타내는 플래그

  @override
  void onTapDown(TapDownEvent event) {
    isMoving = true; // 움직임 시작
    updateTargetPosition(event.localPosition);
  }

  @override
  void onTapUp(TapUpEvent event) {
    isMoving = false; // 움직임 중지
    state = CharacterState.idle;
    character.current = CharacterState.idle;
  }

  @override
  void onTapCancel() {
    // 탭이 취소되면 움직임을 중지
    isMoving = false;
    state = CharacterState.idle;
    character.current = CharacterState.idle;
  }

  @override
  void onTapMove(TapMoveEvent event) {
    if (isMoving) {
      // 움직이고 있는 상태에서만 타겟 위치를 업데이트
      updateTargetPosition(event.localPosition);
    }
  }

  void updateTargetPosition(Vector2 position) {
    targetPosition = position;
    state = CharacterState.running;
    character.current = CharacterState.running;
  }
  
    
  if(isMoving && targetPosition != null) {
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
      } else {
        moveVector.normalize();
        character.position += moveVector * 100 * dt; // 100은 이동 속도입니다.
      }
    }
  }
  }


}
