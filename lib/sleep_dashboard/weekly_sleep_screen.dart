import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:health/health.dart';
import 'package:my_app/TopNav.dart';
import 'package:my_app/bottomNavigationBar.dart';

class WeeklySleepScreen extends StatefulWidget {
  const WeeklySleepScreen({super.key});

  @override
  State<WeeklySleepScreen> createState() => _WeeklySleepScreenState();
}

class _WeeklySleepScreenState extends State<WeeklySleepScreen> {
  final storage = FlutterSecureStorage();
  final Health health = Health();
  bool _isLoggedIn = true;
  String username = '사용자';
  bool loading = true;
  int weekOffset = 0; // 0: 이번주, -1: 지난주 등
  Map<String, double> scores = {};

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _fetchWeeklySleep();
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

  Future<void> _fetchWeeklySleep() async {
    setState(() => loading = true);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(
      Duration(days: today.weekday - 1 + weekOffset * 7),
    );
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    final sleepTypes = [
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.SLEEP_DEEP,
      HealthDataType.SLEEP_REM,
      HealthDataType.SLEEP_LIGHT,
    ];
    final permissions = List.filled(sleepTypes.length, HealthDataAccess.READ);

    final authorized = await health.requestAuthorization(
      sleepTypes,
      permissions: permissions,
    );
    if (!authorized) {
      print('권한 거부됨');
      setState(() => loading = false);
      return;
    }

    final rawData = await health.getHealthDataFromTypes(
      startTime: startOfWeek,
      endTime: endOfWeek,
      types: sleepTypes,
    );

    final cleanData = health.removeDuplicates(rawData);
    final Map<String, double> tempScores = {
      'Mon': 0,
      'Tue': 0,
      'Wed': 0,
      'Thu': 0,
      'Fri': 0,
      'Sat': 0,
      'Sun': 0,
    };

    for (var entry in cleanData) {
      final day = _dayToKey(entry.dateFrom.weekday);
      final duration =
          entry.dateTo.difference(entry.dateFrom).inMinutes.toDouble();
      tempScores[day] = (tempScores[day] ?? 0) + duration;
    }

    setState(() {
      scores = tempScores.map(
        (key, value) => MapEntry(key, value / 5),
      ); // 점수화 (예시)
      loading = false;
    });
  }

  String _dayToKey(int weekday) {
    return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];
  }

  String _translateDay(String key) {
    switch (key) {
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
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bestDay =
        scores.entries.isNotEmpty
            ? scores.entries.reduce((a, b) => a.value > b.value ? a : b).key
            : '';
    final worstDay =
        scores.entries.isNotEmpty
            ? scores.entries.reduce((a, b) => a.value < b.value ? a : b).key
            : '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TopNav(
        isLoggedIn: _isLoggedIn,
        onLogin: () => Navigator.pushReplacementNamed(context, '/login'),
        onLogout: _handleLogout,
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
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
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '주간 수면 리포트',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios),
                                onPressed: () {
                                  setState(() {
                                    weekOffset -= 1;
                                    _fetchWeeklySleep();
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios),
                                onPressed:
                                    weekOffset == 0
                                        ? null
                                        : () {
                                          setState(() {
                                            weekOffset += 1;
                                            _fetchWeeklySleep();
                                          });
                                        },
                              ),
                            ],
                          ),
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

                      if (scores.isNotEmpty)
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
}
