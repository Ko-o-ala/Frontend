// lib/onboarding/pages/habit_page1.dart
import 'package:flutter/material.dart';
import '../onboarding_data.dart';

class HabitPage1 extends StatefulWidget {
  final VoidCallback onNext;
  const HabitPage1({Key? key, required this.onNext}) : super(key: key);

  @override
  State<HabitPage1> createState() => _HabitPage1State();
}

class _HabitPage1State extends State<HabitPage1> {
  String? sleepTime, wakeTime, activityType, sunlightExposure;

  bool get isValid =>
      sleepTime != null &&
      wakeTime != null &&
      activityType != null &&
      sunlightExposure != null;

  Widget _buildQ(
    String title,
    List<String> opts,
    String? gv,
    Function(String?) oc,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
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
              _buildQ(
                'Q5. 평소 취침 시간은?',
                ['오후 9시 이전', '9~12시', '12~2시', '2시 이후'],
                sleepTime,
                (v) => setState(() => sleepTime = v),
              ),
              _buildQ(
                'Q6. 평소 기상 시간은?',
                ['5시 이전', '5~7시', '7~9시', '9시 이후'],
                wakeTime,
                (v) => setState(() => wakeTime = v),
              ),
              _buildQ(
                'Q7. 활동 유형은?',
                ['실내', '실외', '비슷함'],
                activityType,
                (v) => setState(() => activityType = v),
              ),
              _buildQ(
                'Q8. 아침 햇빛 노출은?',
                ['거의 매일', '가끔', '거의 없음'],
                sunlightExposure,
                (v) => setState(() => sunlightExposure = v),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    isValid
                        ? () {
                          final m = OnboardingData.answers;
                          m['sleepTime'] = sleepTime;
                          m['wakeTime'] = wakeTime;
                          m['activityType'] = activityType;
                          m['sunlightExposure'] = sunlightExposure;
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
