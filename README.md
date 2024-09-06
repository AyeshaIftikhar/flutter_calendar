# fluttercalendar

Simple flutter calendar based on [flutter_neat_and_clean_calendar](https://github.com/rwbr/flutter_calendar) package.

| ![screenshot 1](https://github.com/AyeshaIftikhar/flutter_calendar/blob/main/screenshots/flutter_01.png) |  ![screenshot 2](https://github.com/AyeshaIftikhar/flutter_calendar/blob/main/screenshots/flutter_02.png) | 
| --------------------------------------- | --------------------------------------- | 
| ![screenshot 3](https://github.com/AyeshaIftikhar/flutter_calendar/blob/main/screenshot/flutter_03.png)|  

## Features

The calendar view shows a list of events for the selected date with customizable day builder. This list view supports **three different types of events:**

- Single day event (starts and ends at certain time on a single day)
- All-day events (Span over a full day with no specific start and end time, property `isAllDay`)
- Multi-day events (Start at a specific time on one day and end at a specific time on another day, property `isMultiDay`)

## Getting started

Embed the 'Calendar' widget in a column. Below the calendar (as the second widget in the Column) place a 'ListView.separated' widget for rendereing the list of events.

## Usage

### Set dependency

```
dependencies:
  fluttercalendar: ^0.0.1
```

### Install

```
flutter pub get
```

### Import it

```dart
import 'package:fluttercalendar/fluttercalendar.dart';
```

### Use it

```dart
Calendar(
    eventsList: eventList,
    isExpandable: false,
    eventColor: null,
    isExpanded: true,
    todayColor: Colors.teal,
    selectedColor: Colors.blue,
    defaultDayColor: Colors.black,
    selectedTodayColor: Colors.green,
    datePickerType: DatePickerType.date,
    eventDoneColor: Colors.deepPurple,
    defaultOutOfMonthDayColor: Colors.grey,
    expandableDateFormat: 'EEEE, dd. MMMM yyyy',
    onEventSelected: (value) {
        debugPrint('Event selected ${value.summary}');
    },
    onEventLongPressed: (value) {
        debugPrint('Event long pressed ${value.summary}');
    },
    onDateSelected: (value) {
        debugPrint('Date selected $value');
    },
    onRangeSelected: (value) {
        debugPrint('Range selected ${value.from} - ${value.to}');
    },
    dayOfWeekStyle: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.w800,
        fontSize: 11,
    ),
),
```

## complete example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_calendar/enums.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Clean Calendar Demo',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const CalendarScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  bool showEvents = true;

  final List<FlutterCalenderEvent> todaysEvents = [
    FlutterCalenderEvent(
      'Event A',
      startTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 10, 0),
      endTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 12, 0),
      description: 'A special event',
      color: Colors.blue[700],
    ),
  ];

  final List<FlutterCalenderEvent> eventList = [
    FlutterCalenderEvent(
      'MultiDay Event A',
      description: 'test desc',
      startTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 10, 0),
      endTime: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day + 2, 12, 0),
      color: Colors.orange,
      isMultiDay: true,
    ),
    FlutterCalenderEvent(
      'Event X',
      description: 'test desc',
      startTime: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 10, 30),
      endTime: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 11, 30),
      color: Colors.lightGreen,
      isAllDay: false,
      isDone: true,
    ),
    FlutterCalenderEvent(
      'Allday Event B',
      description: 'test desc',
      startTime: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day - 2, 14, 30),
      endTime: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day + 2, 17, 0),
      color: Colors.pink,
      isAllDay: true,
    ),
    FlutterCalenderEvent(
      'Normal Event D',
      description: 'test desc',
      startTime: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 14, 30),
      endTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 17, 0),
      color: Colors.indigo,
    ),
    FlutterCalenderEvent(
      'Normal Event E',
      description: 'test desc',
      startTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 7, 45),
      endTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 9, 0),
      color: Colors.indigo,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Force selection of today on first load, so that the list of today's events gets shown.
    _handleNewDate(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Calendar(
          eventsList: eventList,
          isExpandable: false,
          eventColor: null,
          isExpanded: true,
          todayColor: Colors.teal,
          selectedColor: Colors.blue,
          defaultDayColor: Colors.black,
          selectedTodayColor: Colors.green,
          datePickerType: DatePickerType.date,
          eventDoneColor: Colors.deepPurple,
          defaultOutOfMonthDayColor: Colors.grey,
          expandableDateFormat: 'EEEE, dd. MMMM yyyy',
          onEventSelected: (value) {
            debugPrint('Event selected ${value.summary}');
          },
          onEventLongPressed: (value) {
            debugPrint('Event long pressed ${value.summary}');
          },
          onDateSelected: (value) {
            debugPrint('Date selected $value');
          },
          onRangeSelected: (value) {
            debugPrint('Range selected ${value.from} - ${value.to}');
          },
          dayOfWeekStyle: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w800,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  void _handleNewDate(date) {
    debugPrint('Date selected: $date');
  }
}

```
