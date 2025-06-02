// ✅ 수면 목표 설정 화면 개선 버전
import 'package:flutter/material.dart';
import 'weekday_selector.dart';

class SleepGoalScreen extends StatefulWidget {
  @override
  State<SleepGoalScreen> createState() => _SleepGoalScreenState();
}

class _SleepGoalScreenState extends State<SleepGoalScreen> {
  bool isWakeUpMode = false;
  TimeOfDay? bedTime;
  TimeOfDay? wakeTime;
  Set<int> selectedDays = {};

  String formatTime(TimeOfDay time) {
    return '${time.hour}시 ${time.minute}분';
  }

  Duration? calculateSleepDuration() {
    if (bedTime == null || wakeTime == null) return null;
    final bed = Duration(hours: bedTime!.hour, minutes: bedTime!.minute);
    final wake = Duration(hours: wakeTime!.hour, minutes: wakeTime!.minute);
    if (wake >= bed) {
      return wake - bed;
    } else {
      return Duration(hours: 24) - bed + wake;
    }
  }

  void _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime:
          isWakeUpMode
              ? (wakeTime ?? TimeOfDay.now())
              : (bedTime ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        if (isWakeUpMode) {
          wakeTime = picked;
        } else {
          bedTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sleepDuration = calculateSleepDuration();
    final durationText =
        sleepDuration != null
            ? '${sleepDuration.inHours}시간 ${sleepDuration.inMinutes % 60}분'
            : '0시간 0분';

    return Scaffold(
      appBar: AppBar(
        title: const Text('목표 수면 시간 수정', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(isWakeUpMode ? 'Wake up at' : 'Go to bed at'),
                    Switch(
                      value: isWakeUpMode,
                      onChanged: (value) {
                        setState(() {
                          isWakeUpMode = value;
                        });
                      },
                    ),
                  ],
                ),

                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade900,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    isWakeUpMode
                        ? '$durationText 수면을 취하실 수 있습니다'
                        : '목표 기상 시간까지 $durationText 남았습니다',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),

                GestureDetector(
                  onTap: () => _selectTime(context),
                  child: AbsorbPointer(
                    child: TextField(
                      controller: TextEditingController(
                        text:
                            (isWakeUpMode ? wakeTime : bedTime)?.format(
                              context,
                            ) ??
                            '',
                      ),
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: '시간 선택',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.access_time),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                const Text('목표를 달성하고 싶은 요일을 알려주세요'),
                WeekdaySelector(
                  selectedDays: selectedDays,
                  onDayToggle: (index) {
                    setState(() {
                      if (selectedDays.contains(index)) {
                        selectedDays.remove(index);
                      } else {
                        selectedDays.add(index);
                      }
                    });
                  },
                ),

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed:
                      (bedTime != null && wakeTime != null)
                          ? () {
                            final sleepDuration = calculateSleepDuration();
                            Navigator.pop(context, sleepDuration);
                          }
                          : null,
                  child: const Text('저장하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB0AEF4),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
