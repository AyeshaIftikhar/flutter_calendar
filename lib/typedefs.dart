import 'package:flutter/material.dart';

import 'flutter_calendar_event.dart';

typedef DayBuilder = Function(BuildContext context, DateTime day);
typedef EventListBuilder = Function(
    BuildContext context, List<FlutterCalenderEvent> events);