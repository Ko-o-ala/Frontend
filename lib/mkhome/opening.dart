import 'package:flutter/material.dart';

class opening extends StatelessWidget {
  const opening({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // 🔹 배경 이미지
          Positioned.fill(
            child: Image.asset('lib/assets/opening.png', fit: BoxFit.cover),
          ),

          // 🔹 텍스트 & 버튼 레이어
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/survey');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text("시작하기"),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/home');
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text("홈 화면으로 가기"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
