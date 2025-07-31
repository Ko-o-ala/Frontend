// lib/onboarding/pages/environment_page.dart
import 'package:flutter/material.dart';
import '../onboarding_data.dart';

class EnvironmentPage extends StatefulWidget {
  final VoidCallback onNext;
  const EnvironmentPage({Key? key, required this.onNext}) : super(key: key);

  @override
  State<EnvironmentPage> createState() => _EnvironmentPageState();
}

class _EnvironmentPageState extends State<EnvironmentPage> {
  String? lightUsage, lightTone, noisePref, youtubeContent;

  bool get isValid =>
      lightUsage != null &&
      lightTone != null &&
      noisePref != null &&
      youtubeContent != null;

  Widget _buildQuestion(
    String title,
    List<String> options,
    String? groupValue,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        ...options.map(
          (o) => RadioListTile<String>(
            title: Text(o),
            value: o,
            groupValue: groupValue,
            onChanged: onChanged,
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
              Text(
                'Q1. 수면 시 조명을 어떻게 사용하나요?',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              _buildQuestion(
                '조명 사용은?',
                ['완전히 끄고 잔다', '무드등 또는 약한 조명', '형광등/밝은 조명'],
                lightUsage,
                (v) => setState(() => lightUsage = v),
              ),
              _buildQuestion(
                'Q2. 조명의 색온도는?',
                ['차가운 (6500K)', '중간 (4000K)', '따뜻한 (2700K)', '모르겠어요'],
                lightTone,
                (v) => setState(() => lightTone = v),
              ),
              _buildQuestion(
                'Q3. 조용한 소음을 좋아하나요?',
                ['완전 무음', '백색소음', '유튜브 틀어요', '기타'],
                noisePref,
                (v) => setState(() => noisePref = v),
              ),
              _buildQuestion(
                'Q4. 유튜브 콘텐츠를 틀면 무엇을 선호하시나요?',
                ['ASMR', '음악', '라디오', '드라마', '기타'],
                youtubeContent,
                (v) => setState(() => youtubeContent = v),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    isValid
                        ? () {
                          final m = OnboardingData.answers;
                          m['lightUsage'] = lightUsage;
                          m['lightTone'] = lightTone;
                          m['noisePreference'] = noisePref;
                          m['youtubeContentType'] = youtubeContent;
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
