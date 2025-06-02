import 'package:flutter/material.dart';
import 'package:my_app/sleep_dashboard/monthly_sleep_screen.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'weekly_sleep_screen.dart';

class SleepDashboard extends StatelessWidget {
  const SleepDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'USERNAME',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              const Text(
                'Good Morning',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTab(context, 'Days', true),
                  _buildTab(context, 'Weeks', false),
                  _buildTab(context, 'Months', false),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2C2C72), Color(0xFF1F1F4C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'You have slept '),
                      TextSpan(
                        text: '4h 30m',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: ' that is above your '),
                      TextSpan(
                        text: 'recommendation',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ],
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _InfoItem(
                    icon: Icons.nights_stay,
                    time: '4시간 30분',
                    label: '총 수면 시간',
                  ),
                  _InfoItem(
                    icon: Icons.access_time,
                    time: '3시간',
                    label: '목표 수면 시간',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/time-set'); // 👉 이 안에 있어야 함!
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Color(0xFF5890FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('목표 수면시간 수정하기  +'),
                ),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    '오늘 00님의 수면점수는..',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('수면점수 더 알아보기 >'),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: CircularPercentIndicator(
                  radius: 80.0,
                  lineWidth: 14.0,
                  percent: 0.7,
                  center: const Text(
                    "70점",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  progressColor: Color(0xFFF6D35F),
                  backgroundColor: Colors.black,
                  circularStrokeCap: CircularStrokeCap.round,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const ListTile(
                title: Text('수면 사운드 추천받기'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
              const ListTile(
                title: Text('수면 조언 받으러 가기'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '수면'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '사운드'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, bool selected) {
    return GestureDetector(
      onTap: () {
        if (label == 'Weeks') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WeeklySleepScreen()),
          );
        } else if (label == 'Months') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MonthlySleepScreen()),
          );
        } else if (label == "Days") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SleepDashboard()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
    ); // ✅ 이 줄이 함수의 return 닫힘!
  } // ✅ 그리고 이 중괄호는 함수 자체 닫는 거!
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String time;
  final String label;

  const _InfoItem({
    required this.icon,
    required this.time,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 32, color: Colors.blueAccent),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              time,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}
