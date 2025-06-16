import 'package:flutter/material.dart';

class SleepSurveyHome extends StatefulWidget {
  const SleepSurveyHome({super.key});

  @override
  State<SleepSurveyHome> createState() => _SleepSurveyHomeState();
}

class _SleepSurveyHomeState extends State<SleepSurveyHome> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // 응답 데이터
  String? lightUsage;
  String? lightTone;
  String? noisePreference;
  String? youtubeContent;
  String? sleepTime;
  String? wakeTime;
  String? activityType;
  String? sunlightExposure;
  String? napFrequency;
  String? napDuration;
  String? sleepyTime;
  String? avgSleep;
  String? sleepProblem;
  String? emotionalFactor;
  String? soundPreference;
  String? calmingSound;
  String? deviceUsage;
  String? autoStopPreference;
  String? sleepLatency;
  String? caffeineIntake;
  String? exerciseFrequency;
  String? screenTimeBeforeBed;
  String? stressLevel;
  String? sleepGoal;
  String? feedbackPreference;

  void _nextPage() {
    if (_isCurrentPageValid()) {
      if (_currentPage < 5) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      } else {
        Navigator.pushNamed(context, '/setup');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 문항에 답해주세요.')),
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  bool _isCurrentPageValid() {
    switch (_currentPage) {
      case 0:
        return lightUsage != null && lightTone != null && noisePreference != null && youtubeContent != null;
      case 1:
        return sleepTime != null && wakeTime != null && activityType != null && sunlightExposure != null && napFrequency != null && napDuration != null && sleepyTime != null && avgSleep != null;
      case 2:
        return sleepProblem != null && emotionalFactor != null;
      case 3:
        return soundPreference != null && calmingSound != null && deviceUsage != null && autoStopPreference != null;
      case 4:
        return sleepLatency != null && caffeineIntake != null && exerciseFrequency != null && screenTimeBeforeBed != null && stressLevel != null;
      case 5:
        return sleepGoal != null && feedbackPreference != null;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildEnvironmentPage(),
      _buildHabitRhythmPage(),
      _buildSleepProblemPage(),
      _buildSoundPreferencePage(),
      _buildHealthLifestylePage(),
      _buildGoalFeedbackPage(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('수면 설문')),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentPage = index),
        children: pages,
        physics: const NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentPage > 0)
                ElevatedButton(onPressed: _prevPage, child: const Text('이전')),
              ElevatedButton(
                onPressed: _nextPage,
                child: Text(_currentPage == pages.length - 1 ? '다음 단계로' : '다음'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioGroup(String title, List<String> options, String? groupValue, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ...options.map((option) => RadioListTile(
          title: Text(option),
          value: option,
          groupValue: groupValue,
          onChanged: onChanged,
        )),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEnvironmentPage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildRadioGroup('Q1. 수면 시 조명을 어떻게 사용하나요?', ['완전히 끄고 잔다', '무드등 또는 약한 조명', '형광등/밝은 조명'], lightUsage, (v) => setState(() => lightUsage = v)),
        _buildRadioGroup('Q2. 사용하는 조명의 색온도는?', ['차가운 하얀색 (6500K)', '중간 톤 (4000K)', '따뜻한 노란색 (2700K)', '잘 모르겠음'], lightTone, (v) => setState(() => lightTone = v)),
        _buildRadioGroup('Q3. 수면 시 주변 소음에 대한 본인의 선호는?', ['완전한 무음이 좋아요', '백색소음이 필요해요', '유튜브 등을 틀어두는 편이에요', '기타'], noisePreference, (v) => setState(() => noisePreference = v)),
        _buildRadioGroup('Q4. 유튜브를 튼다면 어떤 콘텐츠를 듣나요?', ['ASMR', '음악 (재즈, 클래식 등)', '라디오/토크 방송', '드라마/영상 콘텐츠', '기타'], youtubeContent, (v) => setState(() => youtubeContent = v)),
      ],
    );
  }

  Widget _buildHabitRhythmPage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildRadioGroup('Q5. 보통 취침 시간은 언제인가요?', ['오후 9시 이전', '오후 9시 ~ 자정', '자정 ~ 새벽 2시', '새벽 2시 이후'], sleepTime, (v) => setState(() => sleepTime = v)),
        _buildRadioGroup('Q6. 보통 기상 시간은 언제인가요?', ['오전 5시 이전', '오전 5시 ~ 7시', '오전 7시 ~ 9시', '오전 9시 이후'], wakeTime, (v) => setState(() => wakeTime = v)),
        _buildRadioGroup('Q7. 하루 중 어느 활동이 더 많은가요?', ['실내 활동이 많아요', '실외 활동이 많아요', '비슷하게 활동해요'], activityType, (v) => setState(() => activityType = v)),
        _buildRadioGroup('Q8. 평소 아침 햇빛을 쬐는 빈도는?', ['거의 매일 쬐어요', '가끔 쬐어요', '거의 쬐지 않아요'], sunlightExposure, (v) => setState(() => sunlightExposure = v)),
        _buildRadioGroup('Q9. 낮잠을 자는 빈도는?', ['매일', '주 3~4회', '가끔 (주 1~2회)', '거의 안 잔다'], napFrequency, (v) => setState(() => napFrequency = v)),
        _buildRadioGroup('Q10. 보통 낮잠 시간은?', ['15분 이내', '15~30분', '30분~1시간', '1시간 이상'], napDuration, (v) => setState(() => napDuration = v)),
        _buildRadioGroup('Q11. 가장 졸리거나 피곤한 시간대는?', ['오전', '오후', '저녁', '새벽', '일정치 않음'], sleepyTime, (v) => setState(() => sleepyTime = v)),
        _buildRadioGroup('Q12. 최근 1주일 평균 수면 시간은?', ['4시간 이하', '4~6시간', '6~7시간', '7~8시간', '8시간 이상'], avgSleep, (v) => setState(() => avgSleep = v)),
      ],
    );
  }

  Widget _buildSleepProblemPage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildRadioGroup('Q13. 평소 겪는 수면 문제를 선택해주세요.', ['잠들기 어려움', '자주 깸', '너무 일찍 깸', '낮 동안 졸림', '악몽/불안감', '수면 중 움직임 많음', '없음'], sleepProblem, (v) => setState(() => sleepProblem = v)),
        _buildRadioGroup('Q14. 수면을 방해하는 감정 요인은?', ['스트레스', '불안감', '외로움', '긴장/예민함', '기타'], emotionalFactor, (v) => setState(() => emotionalFactor = v)),
      ],
    );
  }

  Widget _buildSoundPreferencePage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildRadioGroup('Q15. 수면 시 듣기 편한 사운드는?', ['자연 소리', '음악', '저주파/백색소음', '목소리 (ASMR 등)', '무음이 가장 편함'], soundPreference, (v) => setState(() => soundPreference = v)),
        _buildRadioGroup('Q16. 마음을 안정시켜주는 사운드는?', ['비 오는 소리', '파도/물소리', '잔잔한 피아노', '사람의 말소리', '기타'], calmingSound, (v) => setState(() => calmingSound = v)),
        _buildRadioGroup('Q17. 수면 시 사용하는 기기는?', ['스마트워치', '스마트폰 앱', '스마트 조명', '사운드 기기 (스피커, 이어폰 등)', '없음'], deviceUsage, (v) => setState(() => deviceUsage = v)),
        _buildRadioGroup('Q18. 사운드 자동 종료 방식은?', ['고정 시간 후 종료', '수면 상태 감지 시 자동 종료', '수동 종료', '사용하지 않음'], autoStopPreference, (v) => setState(() => autoStopPreference = v)),
      ],
    );
  }

  Widget _buildHealthLifestylePage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildRadioGroup('Q19. 잠들기까지 걸리는 시간은?', ['5분 이내', '5~15분', '15~30분', '30분 이상'], sleepLatency, (v) => setState(() => sleepLatency = v)),
        _buildRadioGroup('Q20. 카페인 섭취량은?', ['안 마심', '하루 1~2잔', '하루 3잔 이상'], caffeineIntake, (v) => setState(() => caffeineIntake = v)),
        _buildRadioGroup('Q21. 운동 빈도 및 시간대는?', ['하지 않음', '주 2~3회', '매일 아침'], exerciseFrequency, (v) => setState(() => exerciseFrequency = v)),
        _buildRadioGroup('Q22. 취침 전 전자기기 사용 시간은?', ['없음', '30분 미만', '1시간 이상'], screenTimeBeforeBed, (v) => setState(() => screenTimeBeforeBed = v)),
        _buildRadioGroup('Q23. 최근 스트레스 수준은?', ['높음', '보통', '낮음'], stressLevel, (v) => setState(() => stressLevel = v)),
      ],
    );
  }

  Widget _buildGoalFeedbackPage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildRadioGroup('Q24. 수면 목표는?', ['깊은 수면', '빠른 수면', '숙면 지속'], sleepGoal, (v) => setState(() => sleepGoal = v)),
        _buildRadioGroup('Q25. 피드백 형태는?', ['텍스트 요약', '그래프', '음성으로 안내'], feedbackPreference, (v) => setState(() => feedbackPreference = v)),
      ],
    );
  }
}
