import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_app/TopNav.dart';
import 'package:my_app/bottomNavigationBar.dart';

class WeeklySleepScreen extends StatefulWidget {
  const WeeklySleepScreen({super.key});

  @override
  State<WeeklySleepScreen> createState() => _WeeklySleepScreenState();
}

class _WeeklySleepScreenState extends State<WeeklySleepScreen> {
  final TextEditingController _controller = TextEditingController();
  final storage = FlutterSecureStorage();
  bool _isEditing = true;
  bool _isLoggedIn = true;
  String username = '사용자';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final name = await storage.read(key: 'username');
    setState(() {
      username = name ?? '사용자';
      _isLoggedIn = name != null;
    });
  }

  Future<void> _handleLogout() async {
    await storage.delete(key: 'username');
    setState(() {
      username = '사용자';
      _isLoggedIn = false;
    });
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TopNav(
        isLoggedIn: _isLoggedIn,
        onLogin: () => Navigator.pushReplacementNamed(context, '/login'),
        onLogout: _handleLogout,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Good Morning',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

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
                    _buildBar('Thu', 50),
                    _buildBar('Fri', 90),
                    _buildBar('Sat', 88),
                    _buildBar('Sun', 89),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Best / Worst
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
              Text(
                '$username님! 더 완벽한 수면 생활을 위해 다음주 계획을 세워봐요!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // 입력창 or 읽기 전용
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
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              const SizedBox(height: 20),

              // 저장 / 수정 버튼
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
                    backgroundColor: const Color(0xFF8183D9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isEditing ? '저장하기' : '수정하기',
                    style: const TextStyle(
                      color: Colors.white,
                    ), // ✅ 글자색 흰색으로 지정
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2,
        onTap: (idx) {
          if (idx == 0) Navigator.pushReplacementNamed(context, '/real-home');
          if (idx == 1) Navigator.pushReplacementNamed(context, '/sleep');
          if (idx == 3) Navigator.pushReplacementNamed(context, '/setting');
        },
      ),
    );
  }

  Widget _buildTab(String label, bool selected) {
    return GestureDetector(
      onTap: () {
        if (label == 'Days') Navigator.pushReplacementNamed(context, '/sleep');
        if (label == 'Months')
          Navigator.pushReplacementNamed(context, '/monthly');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF8183D9) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBar(String day, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(width: 16, height: height, color: const Color(0xFFF6D35F)),
        const SizedBox(height: 4),
        Text(day),
      ],
    );
  }
}
