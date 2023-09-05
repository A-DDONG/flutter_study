import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flame/src/experimental/geometry/shapes/shape.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setOrientation(DeviceOrientation.portraitUp);
  final game = SimpleGame();
  runApp(
    GameWidget(game: game),
  );
}

class SimpleGame extends FlameGame with TapCallbacks {
  late final SpriteComponent background;
  late final SpriteAnimationComponent character;
  late final CameraComponent cameraComponent;
  final world = World();
  Vector2? targetPosition;

  @override
  Future<void> onLoad() async {
    cameraComponent = CameraComponent(world: world);
    addAll([cameraComponent, world]);

    final bgImage = await Flame.images.load('map.png');
    background = SpriteComponent(
      sprite: Sprite(bgImage),
      size: Vector2(1600, 1200),
    );
    background.size = Vector2(1600, 1200); // Set the size of the map
    world.add(background);

    final spriteSheet = SpriteSheet(
      image: await Flame.images.load('dog2.png'),
      srcSize: Vector2(90.25, 102.75),
    );

    final spriteAnimation = spriteSheet.createAnimation(
      row: 0,
      from: 0,
      to: 3,
      stepTime: 0.1,
    );

    character = SpriteAnimationComponent(
      animation: spriteAnimation,
      size: Vector2(100, 100),
    );
    character.position = Vector2(480, 347.5);
    world.add(character);
    // cameraComponent
    //     .setBounds(Rectangle.fromPoints(Vector2(0, 0), Vector2(3840, 2460)));

    cameraComponent.viewfinder.anchor = Anchor.center; // viewfinder의 앵커 설정
    cameraComponent.follow(character);
  }

  @override
  void onTapUp(TapUpEvent event) {
    final touchPoint = event.localPosition;
    targetPosition = Vector2(touchPoint.x, touchPoint.y);
  }

  @override
  void update(double dt) {
    super.update(dt);
    cameraComponent.follow(character);
    if (targetPosition != null) {
      final moveVector = targetPosition! - character.position;

      if (moveVector.length < 5) {
        targetPosition = null;
      } else {
        moveVector.normalize();
        character.position += moveVector * 300 * dt;
      }
    }
  }
}
