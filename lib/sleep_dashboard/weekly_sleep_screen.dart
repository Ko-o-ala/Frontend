import 'package:flutter/material.dart';

class WeeklySleepScreen extends StatefulWidget {
  const WeeklySleepScreen({super.key});

  @override
  State<WeeklySleepScreen> createState() => _WeeklySleepScreenState();
}

class _WeeklySleepScreenState extends State<WeeklySleepScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isEditing = true; // 입력 가능 상태

  @override
  void dispose() {
    _controller.dispose(); // 메모리 누수 방지
    super.dispose();
  }

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

            // 그래프
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
            const Text(
              '00님! 더 완벽한 수면 생활을 위해 다음주 계획을 세워봐요!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 입력창 or 읽기 전용 텍스트
            if (_isEditing)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  decoration: const InputDecoration.collapsed(
                    hintText: '다음 주 수면 계획을 입력하세요',
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _controller.text.isEmpty ? '내용 없음' : _controller.text,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),

            const SizedBox(height: 20),

            // 저장 or 수정 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isEditing = !_isEditing;
                  });
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF5890FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(_isEditing ? '저장하기' : '수정하기'),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // 현재 페이지가 '수면 현황'이므로 index 2
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) Navigator.pushNamed(context, '/home');
          if (index == 1) Navigator.pushNamed(context, '/sleep');
          if (index == 2) {} // 현재 페이지
          if (index == 3) Navigator.pushNamed(context, '/setting');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '탐색하기'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '수면 현황'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF5890FF) : Colors.grey[200],
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
        Container(width: 16, height: percent, color: const Color(0xFFF6D35F)),
        const SizedBox(height: 4),
        Text(day),
      ],
    );
  }
}
