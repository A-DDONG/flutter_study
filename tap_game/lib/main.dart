import 'package:flutter/material.dart';
import 'screens/game_page.dart'; // 이 줄을 추가

void main() => runApp(TapGame());

class TapGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tap Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GamePage(), // 이 줄이 게임 페이지를 메인 화면으로 설정합니다.
    );
  }
}
