import 'package:flutter/material.dart';
import 'weekday_selector.dart'; // 요일 위젯 import

class SleepGoalScreen extends StatefulWidget {
  @override
  State<SleepGoalScreen> createState() => _SleepGoalScreenState();
}

class _SleepGoalScreenState extends State<SleepGoalScreen> {
  bool isWakeUpMode = false;
  TimeOfDay selectedTime = TimeOfDay(hour: 23, minute: 0);
  Set<int> selectedDays = {};
  final TextEditingController _timeController = TextEditingController();
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _timeController.text = selectedTime.format(context);
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('목표 수면 시간 수정', style: TextStyle(color: Colors.black)),
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
                // 🌓 토글 버튼
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

                // 📘 상태 안내 배너
                Container(
                  margin: EdgeInsets.symmetric(vertical: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade900,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    isWakeUpMode
                        ? '0시간 0분 수면을 취하실 수 있습니다'
                        : '목표 기상 시간까지 0시간 0분 남았습니다',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),

                // 🕰️ 시간 선택 필드 (수정됨)
                GestureDetector(
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            timePickerTheme: TimePickerThemeData(
                              backgroundColor: Colors.white,
                              hourMinuteTextColor: Colors.black,
                              dialHandColor: Colors.indigo,
                              dialBackgroundColor: Colors.indigo.shade50,
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.indigo,
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        selectedTime = picked;
                        _timeController.text = picked.format(context);
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _timeController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: '시간 선택',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.access_time),
                      ),
                    ),
                  ),
                ),

                // 📅 요일 선택
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text('목표를 달성하고 싶은 요일을 알려주세요'),
                ),
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

                SizedBox(height: 24),

                // 💾 저장 버튼
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, selectedTime);
                  },
                  child: Text('저장하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFB0AEF4),
                    minimumSize: Size(double.infinity, 50),
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
