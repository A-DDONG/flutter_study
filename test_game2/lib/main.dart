import 'package:flutter/material.dart';
import 'start_game.dart';

// 앱 시작점
void main() => runApp(const FlutterClickerApp());

// 앱의 루트 위젯
class FlutterClickerApp extends StatelessWidget {
  const FlutterClickerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Clicker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StartGame(), // 앱이 시작될 때 첫화면 설정
    );
  }
}

// 게임 메인 화면 위젯
class ClickerHomePage extends StatefulWidget {
  final String animalType;
  final String petName;
  final String imagePath;

  // 위젯 생성자에서 필요한 파라미터 받아오기
  const ClickerHomePage(
      {Key? key,
      required this.animalType,
      required this.petName,
      required this.imagePath})
      : super(key: key);
  @override
  ClickerHomePageState createState() => ClickerHomePageState();
}

class ClickerHomePageState extends State<ClickerHomePage> {
  int experience = 0; // 경험치 초기값 설정
  int level = 1; // 레벨 초기값 설정
  // String petName = '뗑컨';

  // 경험치와 레벨에 관련된 로직 처리
  int get experienceRequiredForNextLevel => 100 * level;

  // 경험치 증가 메서드
  void gainExperience(int amount) {
    setState(() {
      experience += amount;

      // 경험치가 다음 레벨에 필요한 경험치 이상인 경우 레벨업 처리
      while (experience >= experienceRequiredForNextLevel) {
        experience -= experienceRequiredForNextLevel; // 레벨업에 사용된 경험치만큼 차감
        level += 1; //레벨업
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Clicker')),
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
              child: Image.asset(
            'assets/images/background.png',
            fit: BoxFit.cover,
          )),
          // 게임 내용 UI
          Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                widget.imagePath,
                width: 100,
                height: 100,
              ), // 동물 이미지. assets 폴더에 동물 이미지를 넣어주세요.
              const SizedBox(height: 20),
              Text('이름: ${widget.petName}'),
              const SizedBox(height: 10),
              Text('Level: $level'),
              const SizedBox(height: 10),
              Text('Experience: $experience / $experienceRequiredForNextLevel'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  gainExperience(10); // 경험치 증가 메서드 호출
                },
                child: const Text('Feed'),
              ),
            ],
          )),
        ],
      ),
    );
  }
}
