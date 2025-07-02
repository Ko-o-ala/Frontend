import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_app/TopNav.dart';
import 'package:my_app/bottomNavigationBar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MonthlySleepScreen extends StatefulWidget {
  const MonthlySleepScreen({super.key});

  @override
  State<MonthlySleepScreen> createState() => _MonthlySleepScreenState();
}

class _MonthlySleepScreenState extends State<MonthlySleepScreen> {
  final storage = FlutterSecureStorage();
  String username = '사용자';
  bool _isLoggedIn = false;

  Future<Map<DateTime, Map<String, dynamic>>> fetchSleepData() async {
    final token = await storage.read(key: 'authToken');
    final uri = Uri.parse(
      'https://kooala.tassoo.uk/sleep-data/{userID}/{date}',
    );
    final resp = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode != 200)
      throw Exception('Load failed: ${resp.statusCode}');
    final data = jsonDecode(resp.body) as List;
    final Map<DateTime, Map<String, dynamic>> map = {};
    for (var item in data) {
      final date = DateTime.parse(item['date']);
      map[date] = {
        'time': item['totalSleepDurationStr'],
        'score': item['sleepScore'],
      };
    }
    return map;
  }

  @override
  void initState() {
    super.initState();
    storage.read(key: 'username').then((v) {
      setState(() {
        username = v ?? '사용자';
        _isLoggedIn = v != null;
      });
    });
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
    await storage.delete(key: 'authToken');
    setState(() {
      username = '사용자';
      _isLoggedIn = false;
    });
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Scaffold(
      appBar: TopNav(
        isLoggedIn: _isLoggedIn,
        onLogin: () => Navigator.pushNamed(context, '/login'),
        onLogout: _handleLogout,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  username,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              const SizedBox(height: 4),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Good Morning',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTab('Days', false),
                  const SizedBox(width: 8),
                  _buildTab('Weeks', false),
                  const SizedBox(width: 8),
                  _buildTab('Months', true),
                ],
              ),
              const SizedBox(height: 16),
              FutureBuilder<Map<DateTime, Map<String, dynamic>>>(
                future: fetchSleepData(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snap.hasError) {
                    return Expanded(
                      child: Center(child: Text('로딩 실패: ${snap.error}')),
                    );
                  }
                  final sleepData = snap.data!;
                  return Expanded(child: _buildCalendar(now, sleepData));
                },
              ),
              const SizedBox(height: 16),
              Text(
                '$username님은 ${now.month}월에 ...',
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
        onTap: (i) {
          if (i == 0) Navigator.pushReplacementNamed(context, '/real-home');
          if (i == 1) Navigator.pushReplacementNamed(context, '/sleep');
          if (i == 3) Navigator.pushReplacementNamed(context, '/setting');
        },
      ),
    );
  }

  Widget _buildTab(String label, bool selected) {
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

  Widget _buildCalendar(
    DateTime now,
    Map<DateTime, Map<String, dynamic>> sleepData,
  ) {
    final currentMonth = DateTime(now.year, now.month);
    final daysInMonth = DateUtils.getDaysInMonth(
      currentMonth.year,
      currentMonth.month,
    );
    final startWeekday =
        DateTime(currentMonth.year, currentMonth.month, 1).weekday;
    List<Widget> rows = [];

    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    rows.add(
      Row(
        children:
            weekdays
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );

    int day = 1 - (startWeekday % 7);
    while (day <= daysInMonth) {
      List<Widget> weekRows = [];
      for (int i = 0; i < 7; i++) {
        if (day < 1 || day > daysInMonth) {
          weekRows.add(const Expanded(child: SizedBox()));
        } else {
          final date = DateTime(currentMonth.year, currentMonth.month, day);
          final data = sleepData[date];
          weekRows.add(
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
      rows.add(Row(children: weekRows));
    }

    return Column(children: rows);
  }
}
