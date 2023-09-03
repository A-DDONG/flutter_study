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

// 캐릭터 상태
enum CharacterState {
  idleDown,
  idleUp,
  idleLeft,
  idleRight,
  walkingDown,
  walkingUp,
  walkingLeft,
  walkingRight
}

class MyGame extends FlameGame with MultiTouchDragDetector, TapDetector {
  late final Map<CharacterState, SpriteAnimation> animations; // 캐릭터 애니메이션 저장
  late final SpriteAnimationGroupComponent<CharacterState>
      character; // 캐릭터 컴포넌트
  CharacterState state = CharacterState.idleDown; // 캐릭터 초기 상태

  Vector2? targetPosition; // 캐릭터가 이동할 목표 위치
  bool isTapHeld = false; // 탭이 눌린 상태인지 확인하는 변수
  Vector2? tapPosition; // 탭이 발생한 위치를 저장할 변수
  bool isDragging = false; // 드래그 중인지 확인하는 변수

  Vector2? touchEffectPosition; // 터치 이펙트 위치
  bool shouldRenderTouchEffect = false; // 터치 이펙트를 렌더링할지 여부
  double touchEffectRadius = 0; // 터치 이펙트의 반지름
  double touchEffectOpacity = 1.0; // 터치 이펙트의 투명도

  // 게임이 로드되었는지 확인하는 변수
  @override
  bool isLoaded = false;

  // 게임화면 렌더링
  @override
  void render(Canvas canvas) {
    // 배경을 흰색으로 설정
    final rect = Rect.fromPoints(const Offset(0, 0), Offset(size.x, size.y));
    canvas.drawRect(rect, Paint()..color = Colors.white);
    // 터치 이펙트 그리기
    if (shouldRenderTouchEffect && touchEffectPosition != null) {
      final paint = Paint()
        ..color = Colors.grey.withOpacity(touchEffectOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
          touchEffectPosition!.toOffset(), touchEffectRadius, paint);
    }
    super.render(canvas); // 기본 렌더링 수행
  }

  // 게임 리소스 로드
  @override
  Future<void> onLoad() async {
    // 이미지 로딩
    final image = await Flame.images.load('cat2.png');

// 프레임 크기 설정
    final frameSize = Vector2(32, 32);

    animations = {
      CharacterState.idleDown: SpriteAnimation.spriteList(
        [
          Sprite(image, srcPosition: Vector2(0, 0), srcSize: frameSize),
        ],
        stepTime: 1,
      ),
      CharacterState.walkingDown: SpriteAnimation.spriteList(
        [
          Sprite(image, srcPosition: Vector2(0, 0), srcSize: frameSize),
          Sprite(image, srcPosition: Vector2(32, 0), srcSize: frameSize),
          Sprite(image, srcPosition: Vector2(64, 0), srcSize: frameSize),
          Sprite(image, srcPosition: Vector2(96, 0), srcSize: frameSize),
        ],
        stepTime: 0.1,
      ),
      CharacterState.idleRight: SpriteAnimation.spriteList(
        [
          Sprite(image, srcPosition: Vector2(0, 32), srcSize: frameSize),
        ],
        stepTime: 1,
      ),
      CharacterState.walkingRight: SpriteAnimation.spriteList(
        [
          Sprite(image, srcPosition: Vector2(0, 32), srcSize: frameSize),
          Sprite(image, srcPosition: Vector2(32, 32), srcSize: frameSize),
          Sprite(image, srcPosition: Vector2(64, 32), srcSize: frameSize),
          Sprite(image, srcPosition: Vector2(96, 32), srcSize: frameSize),
        ],
        stepTime: 0.1,
      ),
      CharacterState.idleUp: SpriteAnimation.spriteList(
        [
          Sprite(image, srcPosition: Vector2(0, 64), srcSize: frameSize),
        ],
        stepTime: 1,
      ),
      CharacterState.walkingUp: SpriteAnimation.spriteList(
        [
          Sprite(image, srcPosition: Vector2(0, 64), srcSize: frameSize),
          Sprite(image, srcPosition: Vector2(32, 64), srcSize: frameSize),
          Sprite(image, srcPosition: Vector2(64, 64), srcSize: frameSize),
          Sprite(image, srcPosition: Vector2(96, 64), srcSize: frameSize),
        ],
        stepTime: 0.1,
      ),
      CharacterState.idleLeft: SpriteAnimation.spriteList(
        [
          Sprite(image, srcPosition: Vector2(0, 96), srcSize: frameSize),
        ],
        stepTime: 1,
      ),
      CharacterState.walkingLeft: SpriteAnimation.spriteList(
        [
          Sprite(image, srcPosition: Vector2(0, 96), srcSize: frameSize),
          Sprite(image, srcPosition: Vector2(32, 96), srcSize: frameSize),
          Sprite(image, srcPosition: Vector2(64, 96), srcSize: frameSize),
          Sprite(image, srcPosition: Vector2(96, 96), srcSize: frameSize),
        ],
        stepTime: 0.1,
      ),
    };

    // 캐릭터 컴포넌트 생성
    character = SpriteAnimationGroupComponent<CharacterState>(
      animations: animations,
      current: CharacterState.idleDown,
      position: Vector2(100, 100),
      size: Vector2(100, 100),
    );

    // 캐릭터 초기위치 설정
    // 화면의 중앙 좌표를 계산
    final screenCenterX = size.x / 2;
    final screenCenterY = size.y / 2;

    final characterX = screenCenterX;
    final characterY = screenCenterY;

    character.position = Vector2(characterX, characterY);
    character.anchor = Anchor.center;
    await add(character); // 캐릭터 추가
    isLoaded = true;
  }

  // 화면 크기가 변경되면 호출
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      // 캐릭터의 위치를 화면 중앙으로 재조정
      final screenCenterX = size.x / 2;
      final screenCenterY = size.y / 2;
      final characterX = screenCenterX;
      final characterY = screenCenterY - 50;
      character.position = Vector2(characterX, characterY);
    }
  }

  // 목표 위치와 캐릭터 상태설정
  void setTargetPosition(Vector2 position) {
    final direction = (position - character.position);

    if (direction.x.abs() > direction.y.abs()) {
      state = direction.x > 0
          ? CharacterState.walkingRight
          : CharacterState.walkingLeft;
    } else {
      state = direction.y > 0
          ? CharacterState.walkingDown
          : CharacterState.walkingUp;
    }
    targetPosition = position;
    character.current = state;
  }

  // 상태 변경 로직
  void changeToIdleState() {
    if (state == CharacterState.walkingDown) {
      state = CharacterState.idleDown;
    } else if (state == CharacterState.walkingUp) {
      state = CharacterState.idleUp;
    } else if (state == CharacterState.walkingLeft) {
      state = CharacterState.idleLeft;
    } else if (state == CharacterState.walkingRight) {
      state = CharacterState.idleRight;
    }
    character.current = state;
  }

  // 탭을 눌렀을때
  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);

    touchEffectPosition = info.eventPosition.game; // 터치 이펙트 위치 설정
    shouldRenderTouchEffect = true;
    touchEffectRadius = 50; // 초기 반지름 설정
    touchEffectOpacity = 0.5; // 초기 투명도 설정

    isTapHeld = true; // 탭이 눌린 상태로 설정
    tapPosition = info.eventPosition.game; // 탭이 발생한 위치를 저장
    setTargetPosition(tapPosition!); // 탭한 위치로 이동할 방향 설정
  }

  // 탭을 떼었을때
  @override
  void onTapUp(TapUpInfo info) {
    super.onTapUp(info);

    Future.delayed(const Duration(milliseconds: 100), () {
      shouldRenderTouchEffect = false; // 원을 그리지 않을 것임을 표시
    });

    isTapHeld = false; // 탭이 떼어진 상태로 설정
    tapPosition = info.eventPosition.game; // 탭이 발생한 위치를 저장
    setTargetPosition(tapPosition!); // 탭한 위치로 이동할 방향 설정
  }

  // 탭 취소
  @override
  void onTapCancel() {
    super.onTapCancel();

    shouldRenderTouchEffect = false; // 원을 그리지 않을 것임을 표시
    isTapHeld = false; // 탭이 취소된 상태로 설정
  }

  // 드래그 시작
  @override
  void onDragStart(int pointerId, DragStartInfo info) {
    super.onDragStart(pointerId, info);
    isTapHeld = false; // 여기에 추가
    isDragging = true;
    shouldRenderTouchEffect = true; // 원을 그릴 것임을 표시
    touchEffectOpacity = 0.3; // 투명도 설정
    setTargetPosition(info.eventPosition.game); // 드래그 시작 위치로 이동할 방향 설정
  }

  // 드래그 업데이트
  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    super.onDragUpdate(pointerId, info);

    touchEffectPosition = info.eventPosition.game; // 터치 이펙트 위치 업데이트
    if (isDragging) {
      setTargetPosition(info.eventPosition.game); // 드래그 중인 위치로 이동
    } else if (isTapHeld && tapPosition != null) {
      setTargetPosition(tapPosition!); // 탭을 누르고 있는 경우 탭의 위치로 이동
    }
  }

  // 드래그 끝
  @override
  void onDragEnd(int pointerId, DragEndInfo info) {
    super.onDragEnd(pointerId, info);

    isTapHeld = false; // 여기에 추가

    isDragging = false;
    shouldRenderTouchEffect = false; // 원을 그리지 않을 것임을 표시
    targetPosition = null; // 목표 위치를 null로 설정하여 정지

    changeToIdleState(); // 상태 변경 로직을 함수로 분리
  }

  // 게임상태 업데이트
  @override
  void update(double dt) {
    super.update(dt);
    if (targetPosition != null) {
      final moveVector = targetPosition! - character.position;
      if (moveVector.length < 5) {
        if (!isDragging && !isTapHeld) {
          changeToIdleState();
        }
      } else {
        moveVector.normalize();
        character.position += moveVector * 300 * dt;
      }
    }
  }
}
