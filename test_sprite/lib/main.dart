import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  final game = MyGame();
  runApp(
    GameWidget(game: game),
  );
}

class MyGame extends FlameGame {
  late SpriteAnimationComponent animationComponent;

  @override
  Future<void> onLoad() async {
    final spriteSheetImage =
        await Flame.images.load('pratice.png'); // await 키워드를 사용하여 결과를 기다립니다.

    final spriteSize = Vector2(82, 82); // 각 프레임의 크기
    final animation = SpriteAnimation.fromFrameData(
      spriteSheetImage, // 이미 Future가 완료된 Image 객체를 전달합니다.
      SpriteAnimationData.sequenced(
        amount: 4, // 프레임 수
        stepTime: 0.2,
        textureSize: spriteSize,
      ),
    );

    animationComponent = SpriteAnimationComponent(
      animation: animation,
      size: Vector2.all(160), // 화면에서의 크기 (2배로 확대했다고 가정)
      position: Vector2(100, 100),
    );

    add(animationComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final screenSize = size;
    if (animationComponent.position.x > screenSize.x - 160) {
      return;
    }
    animationComponent.position += Vector2(10 * dt, 0);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromPoints(const Offset(0, 0), Offset(size.x, size.y)),
      Paint()..color = Colors.white,
    );
    super.render(canvas);
  }
}
