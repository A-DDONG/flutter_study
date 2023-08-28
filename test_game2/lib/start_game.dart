import 'package:flutter/material.dart';
import 'package:test_game2/animal_select.dart';
import 'storage.dart';

// 게임 시작 화면 위젯
class StartGame extends StatefulWidget {
  const StartGame({Key? key}) : super(key: key);
  @override
  StartGameState createState() => StartGameState();
}

class StartGameState extends State<StartGame> with TickerProviderStateMixin {
  // 애니메이션 컨트롤러와 애니메이션 객체 선언
  late AnimationController _controller;
  late Animation<double> bounceAnimation;
  late Animation<Offset> slideAnimation;
  late AnimationController _fadeController;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // 페이드 애니메이션 컨트롤러 초기화
    _fadeController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // 애니메이션 정의
    bounceAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(_controller);
    slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: const Offset(0, 0))
            .animate(_controller);
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(_fadeController); // fade 애니메이션 정의

    _controller.forward(); // 애니메이션 한번 실행
    _fadeController.repeat(reverse: true); // 페이드 애니메이션 반복
  }

  showResetConfirmation() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("데이터 초기화"),
          content: const Text("데이터를 모두 초기화하겠습니까?"),
          actions: [
            TextButton(
              child: const Text("취소"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("확인"),
              onPressed: () async {
                await DataStorage().resetData();
                Navigator.of(context).pop();
                // 필요하다면 초기화 후 다른 작업을 수행합니다.
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 화면 탭시 메인페이지 이동
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AnimalSelect()),
        );
      },
      child: Scaffold(
        body: Stack(
          children: [
            // 배경 이미지 설정
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 슬라이드 애니메이션 적용
                  SlideTransition(
                    position: slideAnimation,
                    child: Image.asset(
                      'assets/images/touch.png',
                      fit: BoxFit.contain,
                      width: 200,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // 크기 변화 애니메이션 적용
                  TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0.8, end: 1.2),
                      duration: const Duration(seconds: 1),
                      builder:
                          (BuildContext context, double value, Widget? child) {
                        return Transform.scale(
                          scale: value,
                          child: Image.asset(
                            'assets/images/animal.png',
                            fit: BoxFit.contain,
                            width: 100,
                          ),
                        );
                      }),
                  const SizedBox(height: 30),
                  Image.asset(
                    'assets/images/raise.png',
                    fit: BoxFit.contain,
                    width: 130,
                  ),
                  const SizedBox(height: 80),
                  // 페이드 애니메이션 적용
                  FadeTransition(
                    opacity: fadeAnimation,
                    child: Image.asset(
                      'assets/images/screen_touch.png',
                      fit: BoxFit.contain,
                      width: 120,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: showResetConfirmation,
          tooltip: "데이터 초기화",
          child: const Icon(Icons.delete),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // 사용된 애니메이션 컨트롤러 리소스 정리
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }
}
