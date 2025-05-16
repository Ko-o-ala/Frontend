import 'package:flutter/material.dart';
import 'home_page.dart';
import 'sleep_dashboard/sleep_dashboard.dart';
import 'package:my_app/sleep_dashboard/weekly_sleep_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sleep App',
      initialRoute: '/', // ✅ 처음 뜰 페이지
      routes: {
        '/': (context) => const HomePage(), // 홈
        '/sleep': (context) => const SleepDashboard(), // 수면대시보드
        '/weekly': (context) => const WeeklySleepScreen(),
      },
    );
  }
}
