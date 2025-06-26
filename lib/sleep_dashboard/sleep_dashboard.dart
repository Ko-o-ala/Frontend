import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:health/health.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:my_app/bottomNavigationBar.dart';
import 'package:my_app/TopNav.dart';
import 'package:my_app/sleep_dashboard/monthly_sleep_screen.dart';
import 'package:my_app/sleep_dashboard/weekly_sleep_screen.dart';

final storage = FlutterSecureStorage();

class SleepDashboard extends StatefulWidget {
  final Duration? goalSleepDuration;

  const SleepDashboard({Key? key, this.goalSleepDuration}) : super(key: key);

  @override
  State<SleepDashboard> createState() => _SleepDashboardState();
}

class _SleepDashboardState extends State<SleepDashboard> {
  String formattedDuration = '불러오는 중...';
  String username = '사용자';
  bool _isLoggedIn = false;
  Duration? todaySleep;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _fetchTodaySleep();
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
  }

  Future<void> _fetchTodaySleep() async {
    final health = Health();
    final types = [
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.SLEEP_LIGHT,
      HealthDataType.SLEEP_DEEP,
      HealthDataType.SLEEP_REM,
    ];
    final permissions = List.filled(types.length, HealthDataAccess.READ);

    final now = DateTime.now();
    final start = DateTime(2025, 4, 6, 18); // 6일 오후 6시
    final end = DateTime(2025, 4, 7, 12); // 7일 정오

    print('요청범위: $start ~ $end');

    final authorized = await health.requestAuthorization(
      types,
      permissions: permissions,
    );
    print('📌 authorize result: $authorized');
    if (!authorized) {
      setState(() => formattedDuration = '❌ 건강 앱 접근 거부됨');
      return;
    }

    try {
      print('수면 데이터 요청: $start ~ $end');
      final data = await health.getHealthDataFromTypes(
        types: types,
        startTime: start,
        endTime: end,
      );

      print('가져온 수면 데이터: ${data.length}');
      for (var d in data) {
        print('${d.type} | ${d.dateFrom} ~ ${d.dateTo} | ${d.value}');
      }

      final totalDuration = data
          .where((d) => types.contains(d.type))
          .fold(
            Duration.zero,
            (sum, d) => sum + d.dateTo.difference(d.dateFrom),
          );

      setState(() {
        todaySleep = totalDuration;
        formattedDuration =
            '${totalDuration.inHours}시간 ${totalDuration.inMinutes % 60}분';
      });
    } catch (e) {
      setState(() => formattedDuration = '⚠️ 오류 발생');
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalText =
        widget.goalSleepDuration != null
            ? '${widget.goalSleepDuration!.inHours}시간 ${widget.goalSleepDuration!.inMinutes % 60}분'
            : '미설정';

    return Scaffold(
      appBar: TopNav(
        isLoggedIn: _isLoggedIn,
        onLogin: () {
          Navigator.pushNamed(context, '/login');
        },
        onLogout: _handleLogout,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                      const TextSpan(text: ' today.'),
                    ],
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.nights_stay,
                      time: formattedDuration,
                      label: '오늘 총 수면 시간',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.access_time,
                      time: goalText,
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
                              (_) => SleepDashboard(goalSleepDuration: result),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFF8183D9),
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
                children: [
                  Text(
                    '오늘 $username님의 수면점수는..',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text('수면점수 더 알아보기 >'),
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
                  progressColor: const Color(0xFFF6D35F),
                  backgroundColor: Colors.black,
                  circularStrokeCap: CircularStrokeCap.round,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              ListTile(
                title: const Text('수면 사운드 추천받기'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.pushNamed(context, '/sound');
                },
              ),
              const ListTile(
                title: Text('수면 조언 받으러 가기'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/real-home');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/sound');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/setting');
          }
        },
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, bool selected) {
    return GestureDetector(
      onTap: () {
        if (label == 'Weeks') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => WeeklySleepScreen()),
          );
        } else if (label == 'Months') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MonthlySleepScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => SleepDashboard()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
