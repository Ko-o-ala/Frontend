// lib/onboarding/pages/health_page.dart
import 'package:flutter/material.dart';
import '../onboarding_data.dart';

class HealthPage extends StatefulWidget {
  final VoidCallback onNext;
  const HealthPage({Key? key, required this.onNext}) : super(key: key);

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  String? sleepLatency, caffeineIntake, exerciseFreq, screenTime, stressLevel;

  bool get isValid =>
      sleepLatency != null &&
      caffeineIntake != null &&
      exerciseFreq != null &&
      screenTime != null &&
      stressLevel != null;

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
                'Q19. 잠드는 시간은?',
                ['5분 이하', '5~15분', '15~30분', '30분 이상'],
                sleepLatency,
                (v) => setState(() => sleepLatency = v),
              ),
              _q(
                'Q20. 카페인 섭취량은?',
                ['안 마심', '1~2잔', '3잔 이상'],
                caffeineIntake,
                (v) => setState(() => caffeineIntake = v),
              ),
              _q(
                'Q21. 운동 빈도는?',
                ['하지 않음', '주2~3회', '매일 아침'],
                exerciseFreq,
                (v) => setState(() => exerciseFreq = v),
              ),
              _q(
                'Q22. 수면 전 화면 사용 시간은?',
                ['없음', '30분 이하', '1시간 이상'],
                screenTime,
                (v) => setState(() => screenTime = v),
              ),
              _q(
                'Q23. 스트레스 수준은?',
                ['높음', '보통', '낮음'],
                stressLevel,
                (v) => setState(() => stressLevel = v),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    isValid
                        ? () {
                          final m = OnboardingData.answers;
                          m['sleepLatency'] = sleepLatency;
                          m['caffeineIntake'] = caffeineIntake;
                          m['exerciseFrequency'] = exerciseFreq;
                          m['screenTimeBeforeBed'] = screenTime;
                          m['stressLevel'] = stressLevel;
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
