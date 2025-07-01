import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:health/health.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:my_app/bottomNavigationBar.dart';
import 'package:my_app/TopNav.dart';
import 'package:my_app/sleep_dashboard/monthly_sleep_screen.dart';
import 'package:my_app/sleep_dashboard/weekly_sleep_screen.dart';
import 'package:my_app/sleep_dashboard/sleep_entry.dart';

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
  List<SleepEntry> entries = [];
  bool loading = true;

  int sleepScore = 0;

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
      HealthDataType.SLEEP_REM,
      HealthDataType.SLEEP_DEEP,
      HealthDataType.SLEEP_AWAKE,
      HealthDataType.SLEEP_LIGHT,
    ];
    final permissions = List.filled(types.length, HealthDataAccess.READ);

    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(hours: 6));
    final end = DateTime(now.year, now.month, now.day, 12);

    final authorized = await health.requestAuthorization(
      types,
      permissions: permissions,
    );
    if (!authorized) {
      setState(() => loading = false);
      return;
    }

    try {
      final rawData = await health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: types,
      );

      entries =
          rawData
              .map(
                (d) =>
                    SleepEntry(start: d.dateFrom, end: d.dateTo, type: d.type),
              )
              .toList();

      todaySleep = entries.fold<Duration>(
        Duration.zero,
        (sum, e) => sum + e.duration,
      );

      // 🔍 디버깅 로그
      print('수면 엔트리 개수: ${entries.length}');
      print('총 수면 시간: ${todaySleep}');
      for (var e in entries) {
        print('엔트리: ${e.type} | ${e.duration.inMinutes}분');
      }

      // --- 점수 로직 ---
      final goalMin = widget.goalSleepDuration?.inMinutes ?? 480;
      final totalMin = todaySleep?.inMinutes.toDouble() ?? 0;

      // 1) 수면 시간 점수 (40%)
      final sleepDurationScore =
          ((totalMin / goalMin) * 100).clamp(0, 100).toInt();

      // 2) 수면 구조 점수 (50%)
      double deepMin = 0, remMin = 0;
      for (var e in entries) {
        final m = e.duration.inMinutes.toDouble();
        if (e.type == HealthDataType.SLEEP_DEEP) deepMin += m;
        if (e.type == HealthDataType.SLEEP_REM) remMin += m;
      }
      final deepRatio = totalMin > 0 ? (deepMin / totalMin) * 100 : 0;
      final remRatio = totalMin > 0 ? (remMin / totalMin) * 100 : 0;

      int structureScore = 100;
      if (deepRatio < 20) structureScore -= 20;
      if (remRatio < 25) structureScore -= 20;

      // 3) 깨어난 횟수 점수 (10%)
      final awakenings =
          entries.where((e) => e.type == HealthDataType.SLEEP_AWAKE).length;
      final awakenScore =
          awakenings == 0
              ? 100
              : awakenings == 1
              ? 95
              : 90;

      // 최종 점수 계산
      sleepScore = ((sleepDurationScore * 0.4) +
              (structureScore * 0.5) +
              (awakenScore * 0.1))
          .round()
          .clamp(0, 100);

      final todayKey =
          ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][now.weekday - 1];
      await storage.write(
        key: 'sleepScore_$todayKey',
        value: sleepScore.toString(),
      );

      formattedDuration =
          '${todaySleep!.inHours}시간 ${todaySleep!.inMinutes % 60}분';

      setState(() => loading = false);
    } catch (e) {
      setState(() => loading = false);
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
        onLogin: () => Navigator.pushNamed(context, '/login'),
        onLogout: _handleLogout,
      ),
      backgroundColor: Colors.white,
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
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
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
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
                          ),
                        ),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(text: 'You have slept '),
                              TextSpan(
                                text: formattedDuration,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
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

                      Center(
                        child: CircularPercentIndicator(
                          radius: 80,
                          lineWidth: 14,
                          percent: sleepScore / 100,
                          center: Text(
                            '$sleepScore점',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          progressColor: const Color(0xFFF6D35F),
                          backgroundColor: Colors.black12,
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                      ),

                      const SizedBox(height: 16),
                      const Divider(),

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
                                      (_) => SleepDashboard(
                                        goalSleepDuration: result,
                                      ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF8183D9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('목표 수면시간 수정하기  +'),
                        ),
                      ),

                      const SizedBox(height: 24),
                      ListTile(
                        title: const Text('수면 사운드 추천받기'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => Navigator.pushNamed(context, '/sound'),
                      ),
                      const ListTile(
                        title: Text('수면 조언 받으러 가기'),
                        trailing: Icon(Icons.arrow_forward_ios),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        onTap: (idx) {
          if (idx == 0) Navigator.pushReplacementNamed(context, '/real-home');
          if (idx == 2) Navigator.pushReplacementNamed(context, '/sound');
          if (idx == 3) Navigator.pushReplacementNamed(context, '/setting');
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
