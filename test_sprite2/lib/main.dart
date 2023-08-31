import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  final game = MyGame();
  final gestureDetector = GestureDetector(
    onPanUpdate: (details) => game.onPanUpdate(details),
    child: GameWidget(game: game),
  );
  runApp(gestureDetector);
}

class MyGame extends FlameGame {
  late SpriteAnimationComponent animationComponent;

  @override
  Future<void> onLoad() async {
    final spriteSheetImage = await Flame.images.load('practice.png');

    final spriteSize = Vector2(83, 83);
    final animation = SpriteAnimation.fromFrameData(
      spriteSheetImage,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: spriteSize,
      ),
    );

    animationComponent = SpriteAnimationComponent(
      animation: animation,
      size: Vector2.all(160),
      position: Vector2(100, 100),
    );

    add(animationComponent);
  }

  void onPanUpdate(DragUpdateDetails details) {
    animationComponent.position += Vector2(details.delta.dx, details.delta.dy);
  }
}
