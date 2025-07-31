// lib/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_app/signin/pages/intro_question.dart';
import '../signin/onboarding_screen.dart';
import '../signin//onboarding_data.dart';
import 'pages/welcome_page.dart';
import 'pages/nickname_greeting_page.dart';
import 'pages/environment_page.dart';
import 'pages/habit_page1.dart';
import 'pages/habit_page2.dart';
import 'pages/problem_page.dart';
import 'pages/sound_page.dart';
import 'pages/device_page.dart';
import 'pages/health_page.dart';
import 'pages/goal_page.dart';
import 'pages/account_page.dart';
import 'pages/complete_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  final storage = const FlutterSecureStorage();

  List<Widget> get pages => [
    WelcomePage(onNext: _next),
    NicknameGreetPage(onNext: _next),
    IntroQuestionPage(onNext: _next),
    EnvironmentPage(onNext: _next),
    HabitPage1(onNext: _next),
    HabitPage2(onNext: _next),
    ProblemPage(onNext: _next),
    SoundPage(onNext: _next),
    DevicePage(onNext: _next),
    HealthPage(onNext: _next),
    GoalPage(onNext: _next),
    AccountPage(onNext: _next),

    CompletePage(onSubmit: _submitAll),
  ];

  void _next() {
    if (_currentIndex < pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  Future<void> _submitAll() async {
    final signupUrl = Uri.parse('https://kooala.tassoo.uk/users/signup');
    final surveyUrl = Uri.parse('https://kooala.tassoo.uk/users/survey');
    final answers = OnboardingData.answers;

    final signupResp = await http.post(
      signupUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userID': answers['userID'],
        'name': answers['name'],
        'password': answers['password'],
        'age': 25,
        'gender': 'female',
      }),
    );
    if (signupResp.statusCode == 200 || signupResp.statusCode == 201) {
      final token = jsonDecode(signupResp.body)['data']['token'];
      await storage.write(key: 'jwt', value: token);
      final surveyResp = await http.patch(
        surveyUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, dynamic>{
          // survey 맵으로 채우기...
          ...answers,
        }),
      );
      // 이후 다음 화면 이동
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // 오류 처리
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: PageView(
          controller: _controller,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (i) => setState(() => _currentIndex = i),
          children: pages,
        ),
      ),
    );
  }
}
