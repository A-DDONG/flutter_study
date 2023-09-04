import 'package:flame/components.dart';

class World extends SpriteComponent with HasGameRef {
  @override
  Future<void> onLoad() async {
    print("World onLoad called"); // 이 부분이 출력되면 onLoad가 호출된 것입니다.
    super.onLoad();
    try {
      sprite = await gameRef.loadSprite('map.png');
      print("Image loaded successfully");
    } catch (e) {
      print("Failed to load image: $e");
    }
    size = sprite!.originalSize;
  }
}
