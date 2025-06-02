import 'package:flutter/material.dart';

class WeekdaySelector extends StatelessWidget {
  final Set<int> selectedDays;
  final ValueChanged<int> onDayToggle;

  const WeekdaySelector({
    Key? key,
    required this.selectedDays,
    required this.onDayToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const dayLabels = ['SU', 'M', 'T', 'W', 'TH', 'F', 'S'];

    return Wrap(
      spacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(7, (index) {
        return ChoiceChip(
          label: Text(dayLabels[index]),
          selected: selectedDays.contains(index),
          onSelected: (_) => onDayToggle(index),
          selectedColor: const Color(0xFF8183D9),
          backgroundColor: Colors.grey.shade200,
          labelStyle: TextStyle(
            color: selectedDays.contains(index) ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
          shape: CircleBorder(side: BorderSide.none),
          padding: EdgeInsets.all(10),
        );
      }),
    );
  }
}
