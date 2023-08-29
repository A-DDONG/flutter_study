import 'package:flutter/material.dart';
import 'package:test_game2/main.dart';

// 동물 이름 입력 위젯
class NameInputPage extends StatefulWidget {
  final String animalType;
  final String imagePath;

  const NameInputPage(
      {required this.animalType, required this.imagePath, Key? key})
      : super(key: key);

  @override
  NameInputPageState createState() => NameInputPageState();
}

class NameInputPageState extends State<NameInputPage> {
  TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: <Widget>[
      // 배경 이미지
      Positioned.fill(
        child: Image.asset(
          'assets/images/background.png',
          fit: BoxFit.cover,
        ),
      ),
      // 이름 입력 UI
      Center(
          child: Container(
              width: 300,
              height: 350,
              padding: const EdgeInsets.all(16.0), // 내부 여백 추가
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9), // 흰색 배경, 약간 투명
                borderRadius: BorderRadius.circular(16.0), // 모서리 둥글게
                boxShadow: [
                  // 그림자 효과
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min, // 최소한의 공간만 사용
                  children: <Widget>[
                    Image.asset(
                      widget.imagePath,
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: 20),
                    Text("${widget.animalType}의 이름을 입력해주세요."),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: '이름',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                        child: const Text("확인"),
                        onPressed: () async {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('이름 확인'),
                                  content: Text(
                                      '"${nameController.text}"으로 게임을 진행할까요?'),
                                  actions: [
                                    TextButton(
                                      child: const Text('네'),
                                      onPressed: () {
                                        // 여기에 게임을 시작하는 로직을 추가하면 됩니다.
                                        Navigator.of(context)
                                            .pop(); // 대화상자를 닫습니다.
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ClickerHomePage(
                                              animalType: widget.animalType,
                                              petName: nameController.text,
                                              imagePath: widget.imagePath,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('아뇨'),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // 대화상자를 닫습니다.
                                      },
                                    ),
                                  ],
                                );
                              });
                        }),
                  ])))
    ]));
  }
}
