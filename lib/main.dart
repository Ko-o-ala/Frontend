import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ✅ provider 추가
import 'home_page.dart';
import 'sleep_dashboard/sleep_dashboard.dart';
import 'package:my_app/sleep_dashboard/weekly_sleep_screen.dart';
import 'package:my_app/sleep_dashboard/monthly_sleep_screen.dart';
import 'package:my_app/mkhome/opening.dart';
import 'package:my_app/mkhome/survey.dart';
import 'package:my_app/mkhome/sleep_routine_setup_page.dart';
import 'package:my_app/mkhome/setting_page.dart';
import 'package:my_app/connect_settings/notification.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_app/device/alarm/alarm_model.dart';
import 'package:my_app/device/alarm/alarm_provider.dart'; // ✅ AlarmProvider 추가
import 'package:my_app/device/alarm/alarm_dashboard_page.dart';
import 'package:my_app/device/alarm/bedtime_provider.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(AlarmModelAdapter());
  await Hive.openBox<AlarmModel>('alarms');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AlarmProvider()), // ✅ 등록
        ChangeNotifierProvider(create: (_) => BedtimeModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sleep App',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const opening(),
        '/survey': (context) => const SleepSurveyHome(),
        '/setup': (context) => const SleepRoutineSetupPage(),
        '/home': (context) => const HomePage(),
        '/sleep': (context) => const SleepDashboard(),
        '/weekly': (context) => const WeeklySleepScreen(),
        '/monthly': (context) => MonthlySleepScreen(),
        '/setting': (context) => const SettingsScreen(),
        '/notice': (context) => const Notice(),
        '/alarm':(context) => const AlarmDashboardPage(),
      },
    );
  }
}
