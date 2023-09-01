import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen(); // 전체 화면 모드 설정
  await Flame.device.setOrientation(DeviceOrientation.portraitUp); // 화면 방향 설정
  final game = MyGame();
  runApp(
    GameWidget(game: game), // 게임 위젯 실행
  );
}

enum CharacterState {
  idle, // 캐릭터가 멈춰있는 상태
  running, // 캐릭터가 움직이는 상태
}

class MyGame extends FlameGame with MultiTouchDragDetector, TapDetector {
  late final SpriteAnimation runningAnimation; // 달리기 애니메이션
  late final SpriteAnimation idleAnimation; // 정지 애니메이션
  late final SpriteAnimationGroupComponent<CharacterState> character; // 캐릭터
  CharacterState state = CharacterState.idle; // 초기 상태는 'idle'
  Vector2? targetPosition; // 캐릭터가 이동할 목표 위치
  bool isMoving = false; // 캐릭터가 움직이고 있는지 여부
  final double fixedDistance = 40.0; // 탭할 때 이동할 거리
  bool isTapHeld = false; // 탭이 눌린 상태인지 확인하는 변수
  Vector2? tapPosition; // 탭이 발생한 위치를 저장할 변수
  bool isDragging = false; // 드래그 중인지 확인하는 변수

  @override
  void render(Canvas canvas) {
    // 배경을 흰색으로 설정
    final rect = Rect.fromPoints(const Offset(0, 0), Offset(size.x, size.y));
    canvas.drawRect(rect, Paint()..color = Colors.white);
    super.render(canvas); // 기본 렌더링
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
    super.onTapDown(info);
    isTapHeld = true; // 탭이 눌린 상태로 설정
    tapPosition = info.eventPosition.game; // 탭이 발생한 위치를 저장
    // 탭한 위치로 이동할 방향 계산
    final direction =
        (info.eventPosition.game - character.position).normalized();
    targetPosition = character.position + direction * fixedDistance;
    state = CharacterState.running;
    character.current = CharacterState.running;
    isMoving = true;
  }

  @override
  void onTapUp(TapUpInfo info) {
    super.onTapUp(info);
    isTapHeld = false; // 탭이 떼어진 상태로 설정
  }

  @override
  void onTapCancel() {
    super.onTapCancel();
    isTapHeld = false; // 탭이 취소된 상태로 설정
  }

  // 드래그가 시작되면 드래그 중인 상태로 설정
  @override
  void onDragStart(int pointerId, DragStartInfo info) {
    super.onDragStart(pointerId, info);
    isDragging = true; // 드래그 시작
    targetPosition = info.eventPosition.game;
    state = CharacterState.running;
    character.current = CharacterState.running;
    isMoving = true;
  }

  @override
  void onDragEnd(int pointerId, DragEndInfo info) {
    super.onDragEnd(pointerId, info);
    isDragging = false; // 드래그 종료
    isMoving = false;
    targetPosition = null;
    state = CharacterState.idle;
    character.current = CharacterState.idle;
  }

  @override
  void onDragCancel(int pointerId) {
    super.onDragCancel(pointerId);
    isDragging = false; // 드래그 취소
    isMoving = false;
    targetPosition = null;
    state = CharacterState.idle;
    character.current = CharacterState.idle;
  }

  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    super.onDragUpdate(pointerId, info);
    // 드래그 중인 위치로 이동
    targetPosition = info.eventPosition.game;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isTapHeld || isMoving) {
      if (isTapHeld && tapPosition != null) {
        // 탭을 꾹 누르고 있을 때 새로운 targetPosition을 계산
        final direction = (tapPosition! - character.position).normalized();
        targetPosition = character.position + direction * fixedDistance;
      }
      if (isTapHeld && !isDragging) {
        // 드래그 중이 아닐 때만 tapPosition을 사용
        final direction = (tapPosition! - character.position).normalized();
        targetPosition = character.position + direction * fixedDistance;
      }
      if (targetPosition != null) {
        // 추가: targetPosition이 null이 아닌 경우에만 실행
        // 목표 위치까지 이동
        final moveVector = targetPosition! - character.position;
        if (moveVector.length < 5) {
          character.position = targetPosition!;
          // targetPosition = null;
          // state = CharacterState.idle;
          // character.current = CharacterState.idle;
          // isMoving = false;
          // 탭을 꾹 누르고 있을 때는 targetPosition을 유지
          if (!isTapHeld) {
            targetPosition = null;
            state = CharacterState.idle;
            character.current = CharacterState.idle;
            isMoving = false;
          }
        } else {
          moveVector.normalize();
          Vector2 newPosition =
              character.position + moveVector * 150 * dt; // 속도조정

          // 화면 밖으로 나가지 않도록 위치 조정
          if (newPosition.x < 0) newPosition.x = 0;
          if (newPosition.y < 0) newPosition.y = 0;
          if (newPosition.x > size.x - character.width) {
            newPosition.x = size.x - character.width;
          }
          if (newPosition.y > size.y - character.height) {
            newPosition.y = size.y - character.height;
          }

          character.position = newPosition;
          state = CharacterState.running;
          character.current = CharacterState.running;
        }
      } else {
        // 정지 상태
        state = CharacterState.idle;
        character.current = CharacterState.idle;
      }
    }
  }
}
