import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Custom Font Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '터치 ',
                    style: TextStyle(
                      fontFamily: 'Galmuri',
                      fontSize: 70,
                      color: Color.fromARGB(255, 255, 90, 90),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(-20.0, 10.0), // 이 값을 조절하여 위치를 변경
                    child: const Text(
                      '해서 ',
                      style: TextStyle(
                        fontFamily: 'Galmuri',
                        fontSize: 40,
                      ),
                    ),
                  ),
                ],
              ),
              const Text(
                '동물 키우기',
                style: TextStyle(
                  fontFamily: 'Galmuri',
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
