import 'package:health/health.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

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

/// 수면 데이터를 Health API에서 가져오는 클래스
class SleepDataFetcher {
  final Health _health = Health();

  // 가져올 수면 관련 데이터 타입 목록
  final List<HealthDataType> sleepTypes = [
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_REM,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_AWAKE,
  ];

  /// 주어진 날짜(date)에 해당하는 수면 데이터를 가져옵니다.
  Future<List<SleepEntry>> fetchSleepDataForDate(DateTime date) async {
    final permissions = sleepTypes.map((_) => HealthDataAccess.READ).toList();

    final authorized = await _health.requestAuthorization(
      sleepTypes,
      permissions: permissions,
    );

    if (!authorized) {
      throw Exception('❌ 건강 데이터 접근 권한이 거부되었습니다.');
    }

    // 🔸 7월 1일 기준이면 전날 18시부터 당일 정오까지
    final startTime = DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(const Duration(hours: 6)); // 전날 18시
    final endTime = DateTime(date.year, date.month, date.day, 12); // 당일 낮 12시

    final rawData = await _health.getHealthDataFromTypes(
      types: sleepTypes,
      startTime: startTime,
      endTime: endTime,
    );

    final cleanData = _health.removeDuplicates(rawData);

    // JSON 로그 출력 (디버깅용)
    final jsonList =
        cleanData
            .map(
              (e) => {
                'type': e.type.toString(),
                'dateFrom': e.dateFrom.toIso8601String(),
                'dateTo': e.dateTo.toIso8601String(),
                'value': e.value,
                'unit': e.unit.toString(),
                'recordingMethod': e.recordingMethod.toString(),
              },
            )
            .toList();

    const encoder = JsonEncoder.withIndent('  ');
    debugPrint('🧭 Sleep JSON Data:\n${encoder.convert(jsonList)}');

    // SleepEntry 형태로 변환
    return cleanData.map((e) {
      return SleepEntry(start: e.dateFrom, end: e.dateTo, type: e.type);
    }).toList();
  }
}
