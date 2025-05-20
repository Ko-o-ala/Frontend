import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlySleepScreen extends StatelessWidget {
  MonthlySleepScreen({super.key});

  // 예시 데이터 (수면 시간 + 점수)
  final Map<DateTime, Map<String, dynamic>> sleepData = {
    DateTime(2025, 5, 13): {'time': '6시간', 'score': 80},
    DateTime(2025, 5, 15): {'time': '7시간', 'score': 92},
    DateTime(2025, 5, 17): {'time': '5시간', 'score': 68},
  };

  @override
  Widget build(BuildContext context) {
    final now = DateTime(2025, 5); // 2025년 5월
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final startWeekday = DateTime(now.year, now.month, 1).weekday;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('총 수면 시간'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 탭
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTab('Days', false),
                const Text('|', style: TextStyle(color: Colors.grey)),
                _buildTab('Weeks', false),
                _buildTab('Months', true),
              ],
            ),
            const SizedBox(height: 16),

            // 달력
            _buildCalendar(now, daysInMonth, startWeekday),

            const SizedBox(height: 20),

            // 설명 텍스트
            const Text(
              'OO님은 5월에 ...',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'OO님은 5월에 평균 6시간 12분을 주무셨어요.\n목표보다 아쉽지만, 점점 안정적인 패턴을 찾아가고 있어요!',
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) Navigator.pushNamed(context, '/');
          if (index == 1) Navigator.pushNamed(context, '/statics');
          if (index == 2) {} // 현재 페이지
          if (index == 3) Navigator.pushNamed(context, '/profile');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.nights_stay),
            label: 'Discover',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool selected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
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
      ),
    );
  }

  Widget _buildCalendar(DateTime month, int days, int startWeekday) {
    List<Widget> rows = [];
    int day = 1 - (startWeekday - 1); // 달력 시작일 조정

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
