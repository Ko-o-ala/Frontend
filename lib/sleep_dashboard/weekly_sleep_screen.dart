import 'package:flutter/material.dart';

class WeeklySleepScreen extends StatelessWidget {
  const WeeklySleepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('총 수면 시간'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 탭
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTab('Days', false),
                const SizedBox(width: 8),
                _buildTab('Weeks', true),
                const SizedBox(width: 8),
                _buildTab('Months', false),
              ],
            ),
            const SizedBox(height: 20),

            // 그래프 (막대바 대체)
            SizedBox(
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBar('Mon', 70),
                  _buildBar('Tue', 60),
                  _buildBar('Wed', 85),
                  _buildBar('Fri', 90),
                  _buildBar('Sat', 88),
                  _buildBar('Sun', 89),
                ],
              ),
            ),

            const SizedBox(height: 24),
            // Best/Worst
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Column(
                  children: [
                    Text(
                      'Best 수면 요일',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text('금요일'),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Worst 수면 요일',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text('화요일'),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 안내 텍스트
            const Text(
              '00님! 더 완벽한 수면 생활을 위해 다음주 계획을 세워봐요!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 입력창
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Your message goes here',
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 20),

            // 저장 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Color(0xFF5890FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('저장하기'),
              ),
            ),

            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.center,
              child: Text(
                '저장하기 누르면\n수정하기로 바뀜',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? Color(0xFF5890FF) : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBar(String day, double percent) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 16,
          height: percent, // 임시로 퍼센트값을 높이로 씀
          color: Color(0xFFF6D35F),
        ),
        const SizedBox(height: 4),
        Text(day),
      ],
    );
  }
}
