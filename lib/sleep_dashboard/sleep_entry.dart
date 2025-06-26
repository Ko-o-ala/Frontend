import 'package:health/health.dart';

/// 수면 데이터를 나타내는 클래스
class SleepEntry {
  final DateTime start;
  final DateTime end;
  final HealthDataType type;

  SleepEntry({required this.start, required this.end, required this.type});

  Duration get duration => end.difference(start);

  String get readableType {
    switch (type) {
      case HealthDataType.SLEEP_ASLEEP:
        return '수면';
      case HealthDataType.SLEEP_DEEP:
        return '깊은 수면';
      case HealthDataType.SLEEP_REM:
        return 'REM 수면';
      case HealthDataType.SLEEP_LIGHT:
        return '코어 수면';
      case HealthDataType.SLEEP_AWAKE:
        return '깨어있음';
      default:
        return '기타';
    }
  }
}

class SleepDataFetcher {
  final Health _health = Health();

  // 가져올 수면 관련 데이터 타입
  final List<HealthDataType> sleepTypes = [
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_REM,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_AWAKE,
  ];

  /// 지정한 날짜의 수면 데이터를 가져옴 (예: 2025년 5월 17일)
  Future<List<SleepEntry>> fetchSleepDataForDate(DateTime date) async {
    final permissions = sleepTypes.map((_) => HealthDataAccess.READ).toList();

    final authorized = await _health.requestAuthorization(
      sleepTypes,
      permissions: permissions,
    );

    if (!authorized) {
      throw Exception('❌ 건강 데이터 접근 권한이 거부되었습니다.');
    }

    final startTime = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final endTime = startTime
        .add(const Duration(days: 1))
        .subtract(const Duration(seconds: 1));

    final rawData = await _health.getHealthDataFromTypes(
      types: sleepTypes,
      startTime: startTime,
      endTime: endTime,
    );

    final cleanData = _health.removeDuplicates(rawData);

    return cleanData.map((e) {
      return SleepEntry(start: e.dateFrom, end: e.dateTo, type: e.type);
    }).toList();
  }
}
