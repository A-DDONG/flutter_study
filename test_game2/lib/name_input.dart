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
        appBar: AppBar(title: const Text("이름 입력")),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("${widget.animalType}의 이름을 입력해주세요."),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '이름',
                    border: OutlineInputBorder(),
                  ),
                ),
                ElevatedButton(
                  child: const Text("확인"),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClickerHomePage(
                          animalType: widget.animalType,
                          petName: nameController.text,
                          imagePath: widget.imagePath,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ]));
  }
}
