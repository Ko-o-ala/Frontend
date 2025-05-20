import 'package:flutter/material.dart';
import 'home_page.dart';
import 'sleep_dashboard/sleep_dashboard.dart';
import 'package:my_app/sleep_dashboard/weekly_sleep_screen.dart';
import 'package:my_app/sleep_dashboard/monthly_sleep_screen.dart';
import 'package:my_app/mkhome/opening.dart';
import 'package:my_app/mkhome/survey.dart';
import 'package:my_app/mkhome/sleep_routine_setup_page.dart';
import 'package:my_app/mkhome/setting_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sleep App',
      routes: {
        '/': (context) => const opening(),
        '/survey': (context) => const SleepSurveyHome(), // 초반 설문조사 페이지
        '/setup': (context) => const SleepRoutineSetupPage(), // 해당 프로그램을 사용할 날짜 표시
        '/home': (context) => const HomePage(),
        '/sleep': (context) => const SleepDashboard(),
        '/weekly': (context) => const WeeklySleepScreen(),
        '/monthly': (context) => MonthlySleepScreen(),
        '/setting' :(context) => const SettingsScreen(), //마이페이지
      },
    );
  }
}