import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_app/TopNav.dart';
import 'package:my_app/bottomNavigationBar.dart';

class MonthlySleepScreen extends StatefulWidget {
  const MonthlySleepScreen({super.key});

  @override
  State<MonthlySleepScreen> createState() => _MonthlySleepScreenState();
}

class _MonthlySleepScreenState extends State<MonthlySleepScreen> {
  final storage = FlutterSecureStorage();
  String username = '사용자';
  bool _isLoggedIn = true;

  final Map<DateTime, Map<String, dynamic>> sleepData = {
    DateTime(2025, 5, 13): {'time': '6시간', 'score': 80},
    DateTime(2025, 5, 15): {'time': '7시간', 'score': 92},
    DateTime(2025, 5, 17): {'time': '5시간', 'score': 68},
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
  Widget build(BuildContext context) {
    final now = DateTime(2025, 5);
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final startWeekday = DateTime(now.year, now.month, 1).weekday;

    return Scaffold(
      appBar: TopNav(
        isLoggedIn: _isLoggedIn,
        onLogin: () => Navigator.pushNamed(context, '/login'),
        onLogout: _handleLogout,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: ListView(
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
                  _buildTab(context, 'Days', false),
                  const SizedBox(width: 8),
                  _buildTab(context, 'Weeks', false),
                  const SizedBox(width: 8),
                  _buildTab(context, 'Months', true),
                ],
              ),
              const SizedBox(height: 16),

              // 달력
              _buildCalendar(now, daysInMonth, startWeekday),
              const SizedBox(height: 20),

              // 설명 텍스트
              Text(
                '$username님은 6월에 ...',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '평균 6시간 12분을 주무셨어요.\n목표보다 아쉽지만, 점점 안정적인 패턴을 찾아가고 있어요!',
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/real-home');
          if (index == 1) Navigator.pushReplacementNamed(context, '/sleep');
          if (index == 3) Navigator.pushReplacementNamed(context, '/setting');
        },
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, bool selected) {
    return GestureDetector(
      onTap: () {
        if (label == 'Days') Navigator.pushReplacementNamed(context, '/sleep');
        if (label == 'Weeks')
          Navigator.pushReplacementNamed(context, '/weekly');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
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

  Widget _buildCalendar(DateTime month, int days, int startWeekday) {
    List<Widget> rows = [];
    int day = 1 - (startWeekday - 1);

    while (day <= days) {
      List<Widget> week = [];

      for (int i = 0; i < 7; i++) {
        if (day < 1 || day > days) {
          week.add(const Expanded(child: SizedBox()));
        } else {
          DateTime currentDate = DateTime(month.year, month.month, day);
          var data = sleepData[currentDate];
          week.add(
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: data != null ? Colors.black : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      '$day',
                      style: TextStyle(
                        color: data != null ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (data != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        data['time'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        '${data['score']}점',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }
        day++;
      }

      rows.add(Row(children: week));
    }

    return Column(children: rows);
  }
}
