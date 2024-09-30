import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import './task_page.dart'; // Import the TaskPage

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  List<DateTime?> _dialogCalendarPickerValue = [
    DateTime(2021, 8, 10),
    DateTime(2021, 8, 13),
  ];
  List<DateTime?> _singleDatePickerValueWithDefaultValue = [
    DateTime.now().add(const Duration(days: 1)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCalendarDialogButton(),
            _buildSingleDatePickerWithValue(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarDialogButton() {
    final config = CalendarDatePicker2WithActionButtonsConfig(
      calendarType: CalendarDatePicker2Type.single,
      selectedDayHighlightColor: Colors.purple[800],
    );
    return Padding(
      padding: const EdgeInsets.all(15),
      child: ElevatedButton(
        onPressed: () async {
          final values = await showCalendarDatePicker2Dialog(
            context: context,
            config: config,
            dialogSize: const Size(325, 400),
            borderRadius: BorderRadius.circular(15),
            value: _dialogCalendarPickerValue,
            dialogBackgroundColor: Colors.white,
          );
          if (values != null && values.isNotEmpty) {
            setState(() {
              _dialogCalendarPickerValue = values;
            });
            // Navigate to TaskPage with the selected date
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TaskPage(selectedDate: values[0]!),
              ),
            );
          }
        },
        child: const Text('Open Calendar Dialog'),
      ),
    );
  }

  Widget _buildSingleDatePickerWithValue() {
    final config = CalendarDatePicker2Config(
      selectedDayHighlightColor: Colors.amber[900],
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Single Date Picker'),
        CalendarDatePicker2(
          config: config,
          value: _singleDatePickerValueWithDefaultValue,
          onValueChanged: (dates) {
            setState(() => _singleDatePickerValueWithDefaultValue = dates);
            if (dates.isNotEmpty && dates[0] != null) {
              // Navigate to TaskPage with the selected date
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TaskPage(selectedDate: dates[0]!),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}