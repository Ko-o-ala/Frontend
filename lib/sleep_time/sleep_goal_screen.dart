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

                // 🕰️ 시간 선택 버튼
                OutlinedButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked != null) {
                      setState(() {
                        selectedTime = picked;
                      });
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    side: BorderSide(color: Colors.black),
                  ),
                  child: Text(
                    isWakeUpMode ? 'Wake up at...' : 'Go to bed at...',
                    style: TextStyle(color: Colors.black),
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
                    // TODO: 저장 로직
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

      // ⛵ 바텀 네비게이션
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.brightness_2),
            label: 'Discover',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
