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

  final Map<String, double> scores = {
    'Mon': 70,
    'Tue': 60,
    'Wed': 85,
    'Thu': 50,
    'Fri': 90,
    'Sat': 88,
    'Sun': 89,
  };

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
    final bestDay =
        scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    final worstDay =
        scores.entries.reduce((a, b) => a.value < b.value ? a : b).key;

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

              SizedBox(
                height: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:
                      scores.entries
                          .map((e) => _buildBar(e.key, e.value))
                          .toList(),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Best 수면 요일',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(_translateDay(bestDay)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'Worst 수면 요일',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(_translateDay(worstDay)),
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
                    style: const TextStyle(color: Colors.white),
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
        Text(
          height.toInt().toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Container(width: 16, height: height, color: const Color(0xFFF6D35F)),
        const SizedBox(height: 4),
        Text(day),
      ],
    );
  }

  String _translateDay(String day) {
    switch (day) {
      case 'Mon':
        return '월요일';
      case 'Tue':
        return '화요일';
      case 'Wed':
        return '수요일';
      case 'Thu':
        return '목요일';
      case 'Fri':
        return '금요일';
      case 'Sat':
        return '토요일';
      case 'Sun':
        return '일요일';
      default:
        return day;
    }
  }
}
