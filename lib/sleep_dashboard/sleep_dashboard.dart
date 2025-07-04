import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:health/health.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:my_app/bottomNavigationBar.dart';
import 'package:my_app/TopNav.dart';
import 'package:my_app/sleep_dashboard/monthly_sleep_screen.dart';
import 'package:my_app/sleep_dashboard/weekly_sleep_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
  DateTime? sleepStart;
  DateTime? sleepEnd;
  int deepMin = 0, remMin = 0, lightMin = 0, awakeMin = 0;

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

  Future<void> sendSleepData({
    required String userId,
    required String token,
    required DateTime sleepStart,
    required DateTime sleepEnd,
    required int deepSleep,
    required int remSleep,
    required int lightSleep,
    required int awakeDuration,
    required int sleepScore,
  }) async {
    final url = Uri.parse('https://kooala.tassoo.uk/sleep-data');
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String fm(DateTime t) => t.toIso8601String().substring(11, 16);

    final body = {
      "userID": userId,
      "date": date,
      "startTime": fm(sleepStart),
      "endTime": fm(sleepEnd),
      "segments": [
        {"start": fm(sleepStart), "end": fm(sleepEnd)},
      ],
      "totalSleepDuration": sleepEnd.difference(sleepStart).inMinutes,
      "deepSleepDuration": deepSleep,
      "remSleepDuration": remSleep,
      "lightSleepDuration": lightSleep,
      "awakeDuration": awakeDuration,
      "sleepScore": sleepScore,
    };

    final resp = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      print('✅ 수면 데이터 전송 성공');
    } else {
      print('❌ 전송 실패: ${resp.statusCode} / ${resp.body}');
    }
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

    final now = DateTime.now();
    sleepStart = DateTime(now.year, now.month, now.day - 1, 18);
    sleepEnd = DateTime(now.year, now.month, now.day, 12);

    final authorized = await health.requestAuthorization(types);
    if (!authorized) {
      setState(() => formattedDuration = '❌ 건강 앱 접근 거부됨');
      return;
    }

    try {
      final data = await health.getHealthDataFromTypes(
        types: types,
        startTime: sleepStart!,
        endTime: sleepEnd!,
      );

      deepMin = remMin = lightMin = awakeMin = 0;
      Duration total = Duration.zero;
      for (var d in data) {
        final dur = d.dateTo.difference(d.dateFrom);
        total += dur;
        switch (d.type) {
          case HealthDataType.SLEEP_DEEP:
            deepMin += dur.inMinutes;
            break;
          case HealthDataType.SLEEP_REM:
            remMin += dur.inMinutes;
            break;
          case HealthDataType.SLEEP_LIGHT:
          case HealthDataType.SLEEP_ASLEEP:
            lightMin += dur.inMinutes;
            break;
          case HealthDataType.SLEEP_AWAKE:
            awakeMin += dur.inMinutes;
            break;
          default:
            break;
        }
      }

      setState(() {
        todaySleep = total;
        formattedDuration = '${total.inHours}시간 ${total.inMinutes % 60}분';
      });

      print(
        '🔁 요약 - total:${total.inMinutes}m, deep:$deepMin, rem:$remMin, light:$lightMin, awake:$awakeMin',
      );
    } catch (e) {
      setState(() => formattedDuration = '⚠️ 오류 발생');
      print('⚠️ 오류: $e');
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
              ElevatedButton(
                onPressed: () async {
                  final token = await storage.read(key: 'authToken');
                  final userId = await storage.read(key: 'userID');
                  if (token == null ||
                      userId == null ||
                      todaySleep == null ||
                      sleepStart == null ||
                      sleepEnd == null) {
                    print('❌ 유저/토큰/수면데이터 부족');
                    return;
                  }
                  await sendSleepData(
                    userId: userId,
                    token: token,
                    sleepStart: sleepStart!,
                    sleepEnd: sleepEnd!,
                    deepSleep: deepMin,
                    remSleep: remMin,
                    lightSleep: lightMin,
                    awakeDuration: awakeMin,
                    sleepScore: 0,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C2C72),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('🛏️ 오늘 수면 데이터 전송하기'),
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
    Widget to = SleepDashboard();
    if (label == 'Weeks') to = WeeklySleepScreen();
    if (label == 'Months') to = MonthlySleepScreen();
    return GestureDetector(
      onTap:
          () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => to),
          ),
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
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 32, color: Colors.blueAccent),
      const SizedBox(width: 8),
      Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              time,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
