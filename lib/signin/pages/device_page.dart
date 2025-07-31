// lib/onboarding/pages/device_page.dart
import 'package:flutter/material.dart';
import '../onboarding_data.dart';

class DevicePage extends StatefulWidget {
  final VoidCallback onNext;
  const DevicePage({Key? key, required this.onNext}) : super(key: key);

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  String? deviceUsage, autoStop;

  bool get isValid => deviceUsage != null && autoStop != null;

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
                'Q17. 어떤 기기를 사용하나요?',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ...['스마트워치', '스마트폰 앱', '스마트 조명', '사운드 기기', '없음'].map(
                (o) => RadioListTile(
                  title: Text(o),
                  value: o,
                  groupValue: deviceUsage,
                  onChanged: (v) => setState(() => deviceUsage = v),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Q18. 사운드 자동 종료 방식은?',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ...['고정 시간', '수면 감지', '수동', '사용 없음'].map(
                (o) => RadioListTile(
                  title: Text(o),
                  value: o,
                  groupValue: autoStop,
                  onChanged: (v) => setState(() => autoStop = v),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    isValid
                        ? () {
                          final m = OnboardingData.answers;
                          m['deviceUsage'] = deviceUsage;
                          m['autoStopPreference'] = autoStop;
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
