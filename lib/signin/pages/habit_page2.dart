// lib/onboarding/pages/habit_page2.dart
import 'package:flutter/material.dart';
import '../onboarding_data.dart';

class HabitPage2 extends StatefulWidget {
  final VoidCallback onNext;
  const HabitPage2({Key? key, required this.onNext}) : super(key: key);

  @override
  State<HabitPage2> createState() => _HabitPage2State();
}

class _HabitPage2State extends State<HabitPage2> {
  String? napFreq, napDuration, sleepyTime, avgSleep;

  bool get isValid =>
      napFreq != null &&
      napDuration != null &&
      sleepyTime != null &&
      avgSleep != null;

  Widget _q(String t, List<String> opts, String? gv, Function(String?) cg) {
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
            onChanged: cg,
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
                'Q9. 낮잠 빈도는?',
                ['매일', '주3~4', '1~2회', '거의 안 잠'],
                napFreq,
                (v) => setState(() => napFreq = v),
              ),
              _q(
                'Q10. 낮잠 시간은?',
                ['15분 이하', '15~30분', '30분~1시간', '1시간 이상'],
                napDuration,
                (v) => setState(() => napDuration = v),
              ),
              _q(
                'Q11. 피로 최고 시간은?',
                ['오전', '오후', '저녁', '새벽', '일정 없음'],
                sleepyTime,
                (v) => setState(() => sleepyTime = v),
              ),
              _q(
                'Q12. 평균 수면 시간은?',
                ['4시간 이하', '4~6시간', '6~7시간', '7~8시간', '8시간 이상'],
                avgSleep,
                (v) => setState(() => avgSleep = v),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    isValid
                        ? () {
                          final m = OnboardingData.answers;
                          m['napFrequency'] = napFreq;
                          m['napDuration'] = napDuration;
                          m['sleepyTime'] = sleepyTime;
                          m['avgSleep'] = avgSleep;
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
