// lib/onboarding/pages/sound_page.dart
import 'package:flutter/material.dart';
import '../onboarding_data.dart';

class SoundPage extends StatefulWidget {
  final VoidCallback onNext;
  const SoundPage({Key? key, required this.onNext}) : super(key: key);

  @override
  State<SoundPage> createState() => _SoundPageState();
}

class _SoundPageState extends State<SoundPage> {
  String? soundPref, calmingSound;
  bool get isValid => soundPref != null && calmingSound != null;

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
                'Q15. 수면 시 듣고 싶은 소리는?',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ...['자연 소리', '음악', '백색소음', '목소리 (ASMR)', '무음'].map(
                (o) => RadioListTile(
                  title: Text(o),
                  value: o,
                  groupValue: soundPref,
                  onChanged: (v) => setState(() => soundPref = v),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Q16. 마음을 안정시키는 사운드?',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ...['비 오는 소리', '파도/물소리', '잔잔한 피아노', '말소리', '기타'].map(
                (o) => RadioListTile(
                  title: Text(o),
                  value: o,
                  groupValue: calmingSound,
                  onChanged: (v) => setState(() => calmingSound = v),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    isValid
                        ? () {
                          final m = OnboardingData.answers;
                          m['soundPreference'] = soundPref;
                          m['calmingSound'] = calmingSound;
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
