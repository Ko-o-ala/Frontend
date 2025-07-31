// lib/onboarding/pages/goal_page.dart
import 'package:flutter/material.dart';
import '../onboarding_data.dart';

class GoalPage extends StatefulWidget {
  final VoidCallback onNext;
  const GoalPage({Key? key, required this.onNext}) : super(key: key);

  @override
  State<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  String? sleepGoal, feedbackPref;
  bool get isValid => sleepGoal != null && feedbackPref != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Image.asset('lib/assets/koala.png', width: 120),
              const SizedBox(height: 16),
              Text(
                'Q24. 수면 목표는?',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ...['깊은 수면', '빠른 수면', '숙면 지속'].map(
                (o) => RadioListTile(
                  title: Text(o),
                  value: o,
                  groupValue: sleepGoal,
                  onChanged: (v) => setState(() => sleepGoal = v),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Q25. 피드백 형태는?',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ...['텍스트 요약', '그래프', '음성 안내'].map(
                (o) => RadioListTile(
                  title: Text(o),
                  value: o,
                  groupValue: feedbackPref,
                  onChanged: (v) => setState(() => feedbackPref = v),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    isValid
                        ? () {
                          final m = OnboardingData.answers;
                          m['sleepGoal'] = sleepGoal;
                          m['feedbackPreference'] = feedbackPref;
                          widget.onNext();
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8183D9),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('다음', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
