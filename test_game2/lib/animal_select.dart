import 'package:flutter/material.dart';
import 'package:test_game2/name_input.dart'; // NameInputPage가 정의된 파일의 경로

// 동물 선택 페이지 위젯
class AnimalSelect extends StatelessWidget {
  const AnimalSelect({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("동물 선택")),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 230.0), // 원하는 간격만큼 상단 패딩 추가
              child: Column(children: <Widget>[
                Image.asset('assets/images/animal_select.png',
                    width: 300, fit: BoxFit.cover),
                const SizedBox(height: 100),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _animalImageButton(context, "강아지",
                        "assets/images/dog_button.png", 100.0, 100.0),
                    _animalImageButton(context, "고양이",
                        "assets/images/cat_button.png", 100.0, 100.0),
                    _animalImageButton(context, "펭귄",
                        "assets/images/penguin_button.png", 100.0, 100.0),
                  ],
                ),
              ]),
            ),
          )
        ],
      ),
    );
  }

  Widget _animalImageButton(BuildContext context, String animalName,
      String assetPath, double width, double height) {
    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NameInputPage(
              animalType: animalName,
              imagePath: assetPath,
            ),
          ),
        );
      },
      child: Image.asset(
        assetPath,
        width: width,
        height: height,
        // fit: BoxFit.cover,
      ),
    );
  }
}
