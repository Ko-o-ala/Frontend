import 'package:flutter/material.dart';
import 'package:my_app/sleep_dashboard/monthly_sleep_screen.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'weekly_sleep_screen.dart';

class SleepDashboard extends StatefulWidget {
  final Duration? goalSleepDuration;

  const SleepDashboard({Key? key, this.goalSleepDuration}) : super(key: key);

  @override
  State<SleepDashboard> createState() => _SleepDashboardState();
}

class _SleepDashboardState extends State<SleepDashboard> {
  late String formattedDuration;

  @override
  void initState() {
    super.initState();
    if (widget.goalSleepDuration != null) {
      final hours = widget.goalSleepDuration!.inHours;
      final minutes = widget.goalSleepDuration!.inMinutes % 60;
      formattedDuration = '${hours}시간 ${minutes}분';
      print('✅ 전달받은 수면 시간: $formattedDuration');
    } else {
      formattedDuration = '시간 미정';
      print('⚠️ 전달된 수면 시간 없음');
    }
  }

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
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2C2C72), Color(0xFF1F1F4C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'You have slept '),
                      TextSpan(
                        text: formattedDuration,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' that is above your '),
                      const TextSpan(
                        text: 'recommendation',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ],
                  ),
                  style: const TextStyle(color: Colors.white),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.nights_stay,
                      time: '취침시간',
                      label: '총 수면 시간',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.access_time,
                      time: formattedDuration,
                      label: '목표 수면 시간',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      '/time-set',
                    );
                    if (result is Duration) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  SleepDashboard(goalSleepDuration: result),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Color(0xFF5890FF),
                    foregroundColor: Colors.white,
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
    );
  }
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
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
