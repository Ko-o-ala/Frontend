// lib/onboarding/pages/problem_page.dart
import 'package:flutter/material.dart';
import '../onboarding_data.dart';

class ProblemPage extends StatefulWidget {
  final VoidCallback onNext;
  const ProblemPage({Key? key, required this.onNext}) : super(key: key);

  @override
  State<ProblemPage> createState() => _ProblemPageState();
}

class _ProblemPageState extends State<ProblemPage> {
  String? sleepProblem, emotionalFactor;
  bool get isValid => sleepProblem != null && emotionalFactor != null;

  Widget _q(String t, List<String> opts, String? gv, Function(String?) oc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        ...opts.map(
          (o) => RadioListTile(
            title: Text(o),
            value: o,
            groupValue: gv,
            onChanged: oc,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

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
              _q(
                'Q13. 수면 문제는?',
                ['잠들기 어려움', '자주 깨요', '일찍 깨요', '낮 졸림', '악몽/불안', '움직임 많음', '없음'],
                sleepProblem,
                (v) => setState(() => sleepProblem = v),
              ),
              _q(
                'Q14. 감정으로 인한 방해는?',
                ['스트레스', '불안감', '외로움', '긴장', '기타'],
                emotionalFactor,
                (v) => setState(() => emotionalFactor = v),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    isValid
                        ? () {
                          final m = OnboardingData.answers;
                          m['sleepProblem'] = sleepProblem;
                          m['emotionalFactor'] = emotionalFactor;
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
