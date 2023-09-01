import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setOrientation(DeviceOrientation.portraitUp);
  final game = MyGame();
  runApp(GameWidget(game: game));
}

enum CharacterState { idle, running }

class MyGame extends FlameGame with MultiTouchDragDetector, TapDetector {
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimationGroupComponent<CharacterState> character;
  CharacterState state = CharacterState.idle;
  Vector2? targetPosition;
  bool isTapHeld = false;
  Vector2? tapPosition;
  bool isDragging = false;

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromPoints(const Offset(0, 0), Offset(size.x, size.y));
    canvas.drawRect(rect, Paint()..color = Colors.white);
    super.render(canvas);
  }

  @override
  Future<void> onLoad() async {
    // 이미지 로딩
    final image = await Flame.images.load('test.png');

    // 프레임 크기 설정
    final frameSize = Vector2(320, 400); // 1600 / 5 = 320, 1200 / 3 = 400

    // 1행의 이미지만 사용
    final runningFrames = [
      Sprite(image, srcPosition: Vector2(370, 0), srcSize: frameSize),
      Sprite(image, srcPosition: Vector2(640, 0), srcSize: frameSize),
      Sprite(image, srcPosition: Vector2(960, 0), srcSize: frameSize),
      Sprite(image, srcPosition: Vector2(1280, 0), srcSize: frameSize),
    ];

    // 정지 상태의 이미지는 3번 이미지
    final idleFrames = [
      Sprite(image, srcPosition: Vector2(640, 0), srcSize: frameSize),
    ];

    // 애니메이션 설정
    runningAnimation = SpriteAnimation.spriteList(runningFrames, stepTime: 0.1);
    idleAnimation = SpriteAnimation.spriteList(idleFrames, stepTime: 1);

    // 캐릭터 설정
    character = SpriteAnimationGroupComponent<CharacterState>(
      animations: {
        CharacterState.running: runningAnimation,
        CharacterState.idle: idleAnimation,
      },
      current: CharacterState.idle,
      position: Vector2(100, 100),
      size: Vector2(100, 100), // 캐릭터 크기 설정
    );

    await add(character); // 캐릭터 추가
  }

  @override
  void onTapDown(TapDownInfo info) {
    isTapHeld = true;
    tapPosition = info.eventPosition.game;
    setTargetPosition(tapPosition!);
  }

  @override
  void onTapUp(TapUpInfo info) {
    isTapHeld = false;
    targetPosition = null; // 추가
  }

  @override
  void onDragStart(int pointerId, DragStartInfo info) {
    isDragging = true;
    setTargetPosition(info.eventPosition.game);
  }

  @override
  void onDragEnd(int pointerId, DragEndInfo info) {
    isDragging = false;
    targetPosition = null; // 추가
  }

  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    setTargetPosition(info.eventPosition.game);
  }

  void setTargetPosition(Vector2 position) {
    final direction = (position - character.position).normalized();
    targetPosition = character.position + direction * 40.0;
    state = CharacterState.running;
    character.current = CharacterState.running;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isTapHeld && !isDragging && tapPosition != null) {
      setTargetPosition(tapPosition!);
    }

    if (targetPosition != null) {
      final moveVector = targetPosition! - character.position;
      if (moveVector.length < 5) {
        character.position = targetPosition!;
        if (!isTapHeld || isDragging) {
          // 수정: isDragging도 확인
          targetPosition = null;
          state = CharacterState.idle;
          character.current = CharacterState.idle;
        }
      } else {
        moveVector.normalize();
        Vector2 newPosition = character.position + moveVector * 150 * dt;
        character.position = newPosition;
        state = CharacterState.running;
        character.current = CharacterState.running;
      }
    }
  }
}
