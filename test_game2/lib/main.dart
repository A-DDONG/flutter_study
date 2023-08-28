import 'package:flutter/material.dart';
import 'package:test_game2/storage.dart';
import 'start_game.dart';

// 앱 시작점
void main() => runApp(const FlutterClickerApp());

// 앱의 루트 위젯
class FlutterClickerApp extends StatelessWidget {
  const FlutterClickerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '터치해서 동물 키우기',
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

class ClickerHomePageState extends State<ClickerHomePage>
    with WidgetsBindingObserver {
  int experience = 0; // 경험치 초기값 설정
  int level = 1; // 레벨 초기값 설정
  int attackPower = 10; // 초기 공격력 설정
  // String petName = '뗑컨';

  // 경험치와 레벨에 관련된 로직 처리
  int get experienceRequiredForNextLevel => 150 * level;

  // 경험치 증가 메서드
  void gainExperience() {
    setState(() {
      experience += attackPower;

      // 경험치가 다음 레벨에 필요한 경험치 이상인 경우 레벨업 처리
      while (experience >= experienceRequiredForNextLevel) {
        experience -= experienceRequiredForNextLevel; // 레벨업에 사용된 경험치만큼 차감
        level += 1; //레벨업
        attackPower += 5; // 레벨업할때마다 공격력 5씩 증가
      }
    });
    _saveGameData();
  }

  @override
  void initState() {
    super.initState();
    // 게임 데이터 로드
    _loadGameData();
    WidgetsBinding.instance.addObserver(this); // 옵저버 등록
  }

  _loadGameData() async {
    var loadedData = await DataStorage().loadData();

    // 로드된 데이터가 있는지 체크
    setState(() {
      experience = loadedData['experience'] ?? 0; // 기본값 설정
      level = loadedData['level'] ?? 1; // 기본값 설정
      attackPower = loadedData['attackPower'] ?? 10; // 기본값 설정
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 옵저버 제거
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 앱이 백그라운드로 이동하거나 일시 중지될 때 저장
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _saveGameData();
    }
  }

  _saveGameData() async {
    await DataStorage().saveData(experience, level, attackPower);
  }

  double scaleValue = 1.0; // 이미지 크기 조절 변수

  bool _isMenuOpen = false; // 메뉴가 열렸는지 판별하는 변수

  void toggleMenu() {
    // 메뉴 상태 토글 함수
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 43,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Level: $level'),
                  const SizedBox(width: 20),
                  Text('이름: ${widget.petName}'),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.1,
            left: MediaQuery.of(context).size.width * 0.05,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('경험치: $experience / $experienceRequiredForNextLevel'),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.1,
            right: MediaQuery.of(context).size.width *
                0.05, // 여기서 right 속성을 사용해 오른쪽 위치를 고정
            child: Column(
              children: [
                const Text('아이템'),
                const SizedBox(height: 10),
                Container(
                  width: 50,
                  height: 50,
                  color: Colors.blue,
                  child: const Center(child: Text('1')),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 50,
                  height: 50,
                  color: Colors.red,
                  child: const Center(child: Text('2')),
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  widget.imagePath,
                  width: 100,
                  height: 100,
                ),
                GestureDetector(
                  onTapDown: (_) {
                    setState(() {
                      scaleValue = 1.1;
                    });
                  },
                  onTapUp: (_) {
                    setState(() {
                      scaleValue = 1.0;
                    });
                    gainExperience();
                  },
                  onTapCancel: () {
                    setState(() {
                      scaleValue = 1.0;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    child: Transform.scale(
                      scale: scaleValue,
                      child: Image.asset('assets/images/dog_food.png',
                          width: 100, height: 100),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 30,
            left: 20,
            child: ElevatedButton(
              onPressed: toggleMenu,
              child: const Text('메뉴'),
            ),
          ),
          if (_isMenuOpen) ...[
            // 메뉴가 열려있을 경우 위젯표시
            // 반투명 오버레이
            Positioned.fill(
              child: Container(
                color: Colors.black54,
              ),
            ),
            Center(
              child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.height * 0.4,
                  color: Colors.white,
                  child: Column(
                    children: [
                      const Text('메뉴',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          )),
                      const Divider(),
                      Expanded(
                        child: ListView(
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const StartGame(),
                                    ),
                                  );
                                },
                                child: const Text('타이틀 화면으로')), // 타이틀 화면 로직//
                            ElevatedButton(
                                onPressed: () {},
                                child: const Text('동물 정보')), // 동물 정보 로직
                            ElevatedButton(
                                onPressed: () {},
                                child: const Text('상점')), // 상점 로직
                            ElevatedButton(
                                onPressed: toggleMenu,
                                child: const Text('메뉴 닫기')),
                          ],
                        ),
                      )
                    ],
                  )),
            )
          ],
          Positioned(
            bottom: 10,
            left: MediaQuery.of(context).size.width * 0.1,
            right: MediaQuery.of(context).size.width * 0.1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(onPressed: () {}, child: const Text('산책하기')),
                ElevatedButton(onPressed: () {}, child: const Text('메뉴1')),
                ElevatedButton(onPressed: () {}, child: const Text('메뉴2')),
                ElevatedButton(onPressed: () {}, child: const Text('메뉴3')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
