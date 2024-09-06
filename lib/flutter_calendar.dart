library flutter_calendar;

import 'package:flutter/material.dart';
import './date_utils.dart';
import './simple_gesture_detector.dart';
import './calendar_tile.dart';
import 'date_picker_config.dart';
import 'enums.dart';
import 'expansion_cross_fad.dart';
import 'flutter_calendar_event.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'platform_widgets.dart';
import 'typedefs.dart';

// Export FlutterCalendarEvent for using it in the application
export 'flutter_calendar_event.dart';

class Range {
  final DateTime from;
  final DateTime to;
  Range(this.from, this.to);
}

class Calendar extends StatefulWidget {
  const Calendar({
    super.key,
    this.onMonthChanged,
    this.onDateSelected,
    this.onRangeSelected,
    this.onExpandStateChanged,
    this.onEventSelected,
    this.onEventLongPressed,
    this.hideBottomBar = false,
    this.isExpandable = false,
    this.eventsList,
    this.dayBuilder,
    this.eventListBuilder,
    this.datePickerType = DatePickerType.hidden,
    this.hideTodayIcon = false,
    this.hideArrows = false,
    this.defaultDayColor,
    this.defaultOutOfMonthDayColor,
    this.selectedColor,
    this.selectedTodayColor,
    this.todayColor,
    this.todayButtonText = 'Today',
    this.allDayEventText = 'All Day',
    this.multiDayEndText = 'End',
    this.eventColor,
    this.eventDoneColor,
    this.initialDate,
    this.isExpanded = false,
    this.weekDays = const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    this.locale = 'en_US',
    this.startOnMonday = false,
    this.dayOfWeekStyle,
    this.bottomBarTextStyle,
    this.bottomBarArrowColor,
    this.bottomBarColor,
    this.expandableDateFormat = 'EEEE MMMM dd, yyyy',
    this.displayMonthTextStyle,
    this.datePickerConfig,
    this.eventTileHeight,
    this.image,
  });
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<DateTime>? onMonthChanged;
  final ValueChanged<bool>? onExpandStateChanged;
  final ValueChanged? onRangeSelected;
  final ValueChanged<FlutterCalenderEvent>? onEventSelected;
  final ValueChanged<FlutterCalenderEvent>? onEventLongPressed;
  final bool isExpandable;
  final DayBuilder? dayBuilder;
  final EventListBuilder? eventListBuilder;
  final DatePickerType? datePickerType;
  final bool hideArrows;
  final bool hideTodayIcon;

  final List<FlutterCalenderEvent>? eventsList;
  final Color? defaultDayColor;
  final Color? defaultOutOfMonthDayColor;
  final Color? selectedColor;
  final Color? selectedTodayColor;
  final Color? todayColor;
  final String todayButtonText;
  final String allDayEventText;
  final String multiDayEndText;
  final Color? eventColor;
  final Color? eventDoneColor;
  final DateTime? initialDate;
  final bool isExpanded;
  final List<String> weekDays;
  final String? locale;
  final bool startOnMonday;
  final bool hideBottomBar;
  final TextStyle? dayOfWeekStyle;
  final TextStyle? bottomBarTextStyle;
  final Color? bottomBarArrowColor;
  final Color? bottomBarColor;
  final String? expandableDateFormat;
  final TextStyle? displayMonthTextStyle;
  final DatePickerConfig? datePickerConfig;
  final double? eventTileHeight;
  final String? image;

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  final calendarUtils = Utils();
  late List<DateTime> selectedMonthsDays;
  late Iterable<DateTime> selectedWeekDays;
  late Map<DateTime, List<FlutterCalenderEvent>>? eventsMap;
  DateTime _selectedDate = DateTime.now();
  String? currentMonth;
  late bool isExpanded;
  String displayMonth = '';
  DateTime get selectedDate => _selectedDate;
  List<FlutterCalenderEvent>? _selectedEvents;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.isExpanded;
    _selectedDate = widget.initialDate ?? DateTime.now();
    initializeDateFormatting(widget.locale, null).then(
      (_) => setState(() {
        var monthFormat =
            DateFormat('MMMM yyyy', widget.locale).format(_selectedDate);
        displayMonth =
            '${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}';
      }),
    );
  }

  void updateEventsMap() {
    eventsMap = {};
    // If the user provided a list of events, then convert it to a map, but only if there
    // was no map of events provided. To provide the events in form of a map is the way,
    // the library worked before the v0.3.x release. In v0.3.x the possibility to provide
    // the eventsList property was introduced. This simplifies the handaling. In v0.4.0 the
    // property events (the map) will get removed.
    // Here the library checks, if a map was provided. You can not provide a list and a map
    // at the same time. In that case the map will be used, while the list is omitted.
    if (widget.eventsList != null &&
        widget.eventsList!.isNotEmpty &&
        eventsMap!.isEmpty) {
      for (var event in widget.eventsList!) {
        final int range = event.endTime.difference(event.startTime).inDays;
        // Event starts and ends on the same day.
        if (range == 0) {
          List<FlutterCalenderEvent> dateList = eventsMap![DateTime(
                  event.startTime.year,
                  event.startTime.month,
                  event.startTime.day)] ??
              [];
          // Just add the event to the list.
          eventsMap![DateTime(event.startTime.year, event.startTime.month,
              event.startTime.day)] = dateList..add(event);
        } else {
          for (var i = 0; i <= range; i++) {
            List<FlutterCalenderEvent> dateList = eventsMap![DateTime(
                    event.startTime.year,
                    event.startTime.month,
                    event.startTime.day + i)] ??
                [];
            // Iteration over the range (diferrence between start and end time in days).
            FlutterCalenderEvent newEvent = FlutterCalenderEvent(event.summary,
                description: event.description,
                location: event.location,
                color: event.color,
                isAllDay: event.isAllDay,
                isDone: event.isDone,
                // Multi-day events span over several days. They have a start time on the first day
                // and an end time on the last day.  All-day events don't have a start time and end time
                // So if an event ist an all-day event, the multi-day property gets set to false.
                // If the event is not an all-day event, the multi-day property gets set to true, because
                // the difference between
                isMultiDay: event.isAllDay ? false : true,
                // Event spans over several days, but entreis in the list can only cover one
                // day, so the end date of one entry must be on the same day as the start.
                multiDaySegement: MultiDaySegement.first,
                startTime: DateTime(
                    event.startTime.year,
                    event.startTime.month,
                    event.startTime.day + i,
                    event.startTime.hour,
                    event.startTime.minute),
                endTime: DateTime(
                    event.startTime.year,
                    event.startTime.month,
                    event.startTime.day + i,
                    event.endTime.hour,
                    event.endTime.minute));
            if (i == 0) {
              // First day of the event.
              newEvent.multiDaySegement = MultiDaySegement.first;
            } else if (i == range) {
              // Last day of the event.
              newEvent.multiDaySegement = MultiDaySegement.last;
            } else {
              // Middle day of the event.
              newEvent.multiDaySegement = MultiDaySegement.middle;
            }
            eventsMap![DateTime(event.startTime.year, event.startTime.month,
                event.startTime.day + i)] = dateList..add(newEvent);
          }
        }
      }
    }
    selectedMonthsDays = daysInMonth(_selectedDate);
    selectedWeekDays = Utils.daysInRange(
      firstDayOfWeek(_selectedDate),
      lastDayOfWeek(_selectedDate),
    ).toList();

    _selectedEvents = eventsMap?[DateTime(
            _selectedDate.year, _selectedDate.month, _selectedDate.day)] ??
        [];

    debugPrint('eventsMap has ${eventsMap?.length} entries');
  }

  Widget get nameAndIconRow {
    StatelessWidget todayIcon;
    StatelessWidget leftArrow;
    StatelessWidget rightArrow;
    StatelessWidget jumpDateIcon;

    if (!widget.hideArrows) {
      leftArrow = PlatformIconButton(
        onPressed: isExpanded ? previousMonth : previousWeek,
        icon: const Icon(Icons.chevron_left),
      );
      rightArrow = PlatformIconButton(
        onPressed: isExpanded ? nextMonth : nextWeek,
        icon: const Icon(Icons.chevron_right),
      );
    } else {
      leftArrow = Container();
      rightArrow = Container();
    }

    if (!widget.hideTodayIcon) {
      todayIcon = GestureDetector(
        onTap: resetToToday,
        child: Text(widget.todayButtonText),
      );
    } else {
      todayIcon = Container();
    }

    if (widget.datePickerType != null &&
        widget.datePickerType != DatePickerType.hidden) {
      jumpDateIcon = GestureDetector(
        child: const Icon(Icons.date_range_outlined),
        onTap: () {
          if (widget.datePickerType == DatePickerType.year) {
            // show year picker
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Select Year"),
                  content: SizedBox(
                    // Need to use container to add size constraint.
                    width: 300,
                    height: 300,
                    child: YearPicker(
                      firstDate: widget.datePickerConfig?.firstDate ??
                          DateTime(DateTime.now().year - 100, 1),
                      lastDate: widget.datePickerConfig?.lastDate ??
                          DateTime(DateTime.now().year + 100, 1),
                      initialDate: widget.datePickerConfig?.initialDate ??
                          DateTime.now(),
                      // save the selected date to _selectedDate DateTime variable.
                      // It's used to set the previous selected date when
                      // re-showing the dialog.
                      selectedDate: _selectedDate,
                      onChanged: (DateTime dateTime) {
                        // close the dialog when year is selected.
                        onJumpToDateSelected(dateTime);
                        Navigator.pop(context);

                        // Do something with the dateTime selected.
                        // Remember that you need to use dateTime.year to get the year
                      },
                    ),
                  ),
                );
              },
            );
          } else if (widget.datePickerType == DatePickerType.date) {
            showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            ).then((date) {
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                  selectedMonthsDays = daysInMonth(_selectedDate);
                  selectedWeekDays = Utils.daysInRange(
                          firstDayOfWeek(_selectedDate),
                          lastDayOfWeek(_selectedDate))
                      .toList();
                  var monthFormat = DateFormat('MMMM yyyy', widget.locale)
                      .format(_selectedDate);
                  displayMonth =
                      '${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}';
                  _selectedEvents = eventsMap?[DateTime(_selectedDate.year,
                          _selectedDate.month, _selectedDate.day)] ??
                      [];
                });
                debugPrint('Date chosen: ${_selectedDate.toIso8601String()}');
                onJumpToDateSelected(_selectedDate);
              }
            });
          }
        },
      );
    } else {
      jumpDateIcon = Container();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        leftArrow,
        Expanded(
          child: Column(
            children: <Widget>[
              todayIcon,
              Text(
                displayMonth,
                style: widget.displayMonthTextStyle ??
                    const TextStyle(fontSize: 20.0),
              ),
            ],
          ),
        ),
        jumpDateIcon,
        rightArrow,
      ],
    );
  }

  Widget get calendarGridView {
    return SimpleGestureDetector(
      onSwipeUp: onSwipeUp,
      onSwipeDown: onSwipeDown,
      onSwipeLeft: onSwipeLeft,
      onSwipeRight: onSwipeRight,
      swipeConfig: const SimpleSwipeConfig(
        verticalThreshold: 10.0,
        horizontalThreshold: 40.0,
        swipeDetectionMoment: SwipeDetectionMoment.onUpdate,
      ),
      child: Column(children: <Widget>[
        GridView.count(
          childAspectRatio: 1.1,
          primary: false,
          shrinkWrap: true,
          crossAxisCount: 7,
          padding: const EdgeInsets.only(bottom: 0.0),
          children: calendarBuilder(),
        ),
      ]),
    );
  }

  List<Widget> calendarBuilder() {
    List<Widget> dayWidgets = [];
    List<DateTime> calendarDays =
        isExpanded ? selectedMonthsDays : selectedWeekDays as List<DateTime>;
    for (var day in widget.weekDays) {
      dayWidgets.add(
        FlutterCalenderTile(
          // image: widget.image,
          defaultDayColor: widget.defaultDayColor,
          defaultOutOfMonthDayColor: widget.defaultOutOfMonthDayColor,
          selectedColor: widget.selectedColor,
          selectedTodayColor: widget.selectedTodayColor,
          todayColor: widget.todayColor,
          eventColor: widget.eventColor,
          eventDoneColor: widget.eventDoneColor,
          events: eventsMap![day],
          isDayOfWeek: true,
          dayOfWeek: day,
          dayOfWeekStyle: widget.dayOfWeekStyle ??
              TextStyle(
                color: widget.selectedColor,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
        ),
      );
    }

    bool monthStarted = false;
    bool monthEnded = false;

    for (var day in calendarDays) {
      if (day.hour > 0) {
        day = DateFormat("yyyy-MM-dd HH:mm:ssZZZ")
            .parse(day.toString())
            .toLocal();
        day = day.subtract(Duration(hours: day.hour));
      }

      if (monthStarted && day.day == 01) {
        monthEnded = true;
      }

      if (Utils.isFirstDayOfMonth(day)) {
        monthStarted = true;
      }

      if (widget.dayBuilder != null) {
        // Use the dayBuilder widget passed as parameter to render the date tile
        dayWidgets.add(
          FlutterCalenderTile(
            defaultDayColor: widget.defaultDayColor,
            defaultOutOfMonthDayColor: widget.defaultOutOfMonthDayColor,
            selectedColor: widget.selectedColor,
            selectedTodayColor: widget.selectedTodayColor,
            todayColor: widget.todayColor,
            eventColor: widget.eventColor,
            eventDoneColor: widget.eventDoneColor,
            events: eventsMap![day],
            child: widget.dayBuilder!(context, day),
            date: day,
            onDateSelected: () => handleSelectedDateAndUserCallback(day),
          ),
        );
      } else {
        dayWidgets.add(
          FlutterCalenderTile(
              defaultDayColor: widget.defaultDayColor,
              defaultOutOfMonthDayColor: widget.defaultOutOfMonthDayColor,
              selectedColor: widget.selectedColor,
              selectedTodayColor: widget.selectedTodayColor,
              todayColor: widget.todayColor,
              eventColor: widget.eventColor,
              eventDoneColor: widget.eventDoneColor,
              events: eventsMap![day],
              onDateSelected: () => handleSelectedDateAndUserCallback(day),
              date: day,
              dateStyles: configureDateStyle(monthStarted, monthEnded),
              isSelected: Utils.isSameDay(selectedDate, day),
              inMonth: day.month == selectedDate.month),
        );
      }
    }
    return dayWidgets;
  }

  TextStyle? configureDateStyle(monthStarted, monthEnded) {
    TextStyle? dateStyles;
    final TextStyle? body1Style = Theme.of(context).textTheme.bodyMedium;

    if (isExpanded) {
      final TextStyle body1StyleDisabled = body1Style!.copyWith(
          color: Color.fromARGB(
        100,
        body1Style.color!.red,
        body1Style.color!.green,
        body1Style.color!.blue,
      ));

      dateStyles =
          monthStarted && !monthEnded ? body1Style : body1StyleDisabled;
    } else {
      dateStyles = body1Style;
    }
    return dateStyles;
  }

  Widget get expansionButtonRow {
    if (widget.isExpandable) {
      return GestureDetector(
        onTap: toggleExpanded,
        child: Container(
          color:
              widget.bottomBarColor ?? const Color.fromRGBO(200, 200, 200, 0.2),
          height: 40,
          margin: const EdgeInsets.only(top: 8.0),
          padding: const EdgeInsets.all(0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const SizedBox(width: 40.0),
              Text(
                DateFormat(widget.expandableDateFormat, widget.locale)
                    .format(_selectedDate),
                style:
                    widget.bottomBarTextStyle ?? const TextStyle(fontSize: 13),
              ),
              PlatformIconButton(
                onPressed: toggleExpanded,
                iconSize: 25.0,
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                icon: isExpanded
                    ? Icon(
                        Icons.arrow_drop_up,
                        color: widget.bottomBarArrowColor ?? Colors.black,
                      )
                    : Icon(
                        Icons.arrow_drop_down,
                        color: widget.bottomBarArrowColor ?? Colors.black,
                      ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget get eventList {
    // If eventListBuilder is provided, use it to build the list of events to show.
    // Otherwise use the default list of events.
    if (widget.eventListBuilder == null) {
      return Expanded(
        child: _selectedEvents != null && _selectedEvents!.isNotEmpty
            ? ListView.builder(
                padding: const EdgeInsets.all(0.0),
                itemBuilder: (BuildContext context, int index) {
                  final FlutterCalenderEvent event = _selectedEvents![index];
                  final String start =
                      DateFormat('HH:mm').format(event.startTime).toString();
                  final String end =
                      DateFormat('HH:mm').format(event.endTime).toString();
                  return SizedBox(
                    height: widget.eventTileHeight ??
                        MediaQuery.of(context).size.height * 0.075,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (widget.onEventSelected != null) {
                          widget.onEventSelected!(event);
                        }
                      },
                      onLongPress: () {
                        if (widget.onEventLongPressed != null) {
                          widget.onEventLongPressed!(event);
                        }
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Container(color: event.color),
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Expanded(
                            flex: 75,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    event.summary,
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 10.0),
                                  Text(
                                    event.description,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                ],
                              ),
                            ),
                          ),
                          // This Expanded widget gets used to display the start and end time of the
                          // event.
                          Expanded(
                            flex: 30,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              // If the event is all day, then display the word "All day" with no time.
                              child: event.isAllDay || event.isMultiDay
                                  ? allOrMultiDayDayTimeWidget(event)
                                  : singleDayTimeWidget(start, end),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
                itemCount: _selectedEvents!.length,
              )
            : Container(),
      );
    } else {
      // eventListBuilder is not null
      return widget.eventListBuilder!(context, _selectedEvents!);
    }
  }

  Column singleDayTimeWidget(String start, String end) {
    debugPrint('SingleDayEvent');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(start, style: Theme.of(context).textTheme.bodyLarge),
        Text(end, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }

  Column allOrMultiDayDayTimeWidget(FlutterCalenderEvent event) {
    debugPrint('=== Summary: ${event.summary}');
    String start = DateFormat('HH:mm').format(event.startTime).toString();
    String end = DateFormat('HH:mm').format(event.endTime).toString();
    if (event.isAllDay) {
      debugPrint('AllDayEvent - ${event.summary}');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(widget.allDayEventText,
              style: Theme.of(context).textTheme.bodyLarge),
        ],
      );
    }
    if (event.multiDaySegement == MultiDaySegement.first) {
      // The event begins on the selcted day.
      // Just show the start time, no end time.
      debugPrint('MultiDayEvent: start - ${event.summary}');
      end = '';
    } else if (event.multiDaySegement == MultiDaySegement.last) {
      // The event ends on the selcted day.
      // Just show the end time, no start time.
      debugPrint('MultiDayEvent: end - ${event.summary}');
      start = widget.multiDayEndText;
    } else {
      // The event spans multiple days.
      debugPrint('MultiDayEvent: middle - ${event.summary}');
      start = widget.allDayEventText;
      end = '';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(start, style: Theme.of(context).textTheme.bodyLarge),
        Text(end, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    updateEventsMap();

    // If _selectedEvents is not null, then we sort the events by isAllDay propeerty, so that
    // all day events are displayed at the top of the list.
    // Slightly inexxficient, to do this sort each time, the widget builds.
    if (_selectedEvents?.isNotEmpty == true) {
      _selectedEvents!.sort((a, b) {
        if (a.isAllDay == b.isAllDay) return 0;
        if (a.isAllDay) return -1;
        return 1;
      });
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        nameAndIconRow,
        ExpansionCrossFade(
          collapsed: calendarGridView,
          expanded: calendarGridView,
          isExpanded: isExpanded,
        ),
        expansionButtonRow,
        eventList
      ],
    );
  }

  /// The function [resetToToday] is called on tap on the Today button in the top
  /// position of the screen. It re-caclulates the range of dates, so that the
  /// month view or week view changes to a range containing the current day.
  void resetToToday() {
    onJumpToDateSelected(DateTime.now());
  }

  void nextMonth() {
    setState(() {
      _selectedDate = Utils.nextMonth(_selectedDate);
      var firstDateOfNewMonth = Utils.firstDayOfMonth(_selectedDate);
      var lastDateOfNewMonth = Utils.lastDayOfMonth(_selectedDate);
      updateSelectedRange(firstDateOfNewMonth, lastDateOfNewMonth);
      selectedMonthsDays = daysInMonth(_selectedDate);
      var monthFormat =
          DateFormat('MMMM yyyy', widget.locale).format(_selectedDate);
      displayMonth =
          '${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}';
      _selectedEvents = eventsMap?[DateTime(
              _selectedDate.year, _selectedDate.month, _selectedDate.day)] ??
          [];
    });
    launchDateSelectionCallback(_selectedDate);
  }

  void previousMonth() {
    setState(() {
      _selectedDate = Utils.previousMonth(_selectedDate);
      var firstDateOfNewMonth = Utils.firstDayOfMonth(_selectedDate);
      var lastDateOfNewMonth = Utils.lastDayOfMonth(_selectedDate);
      updateSelectedRange(firstDateOfNewMonth, lastDateOfNewMonth);
      selectedMonthsDays = daysInMonth(_selectedDate);
      var monthFormat =
          DateFormat('MMMM yyyy', widget.locale).format(_selectedDate);
      displayMonth =
          '${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}';
      _selectedEvents = eventsMap?[DateTime(
              _selectedDate.year, _selectedDate.month, _selectedDate.day)] ??
          [];
    });
    launchDateSelectionCallback(_selectedDate);
  }

  void nextWeek() {
    setState(() {
      _selectedDate = Utils.nextWeek(_selectedDate);
      var firstDayOfCurrentWeek = firstDayOfWeek(_selectedDate);
      var lastDayOfCurrentWeek = lastDayOfWeek(_selectedDate);
      updateSelectedRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek);
      selectedWeekDays =
          Utils.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
              .toList();
      var monthFormat =
          DateFormat('MMMM yyyy', widget.locale).format(_selectedDate);
      displayMonth =
          '${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}';
      _selectedEvents = eventsMap?[DateTime(
              _selectedDate.year, _selectedDate.month, _selectedDate.day)] ??
          [];
    });
    launchDateSelectionCallback(_selectedDate);
  }

  void previousWeek() {
    setState(() {
      _selectedDate = Utils.previousWeek(_selectedDate);
      var firstDayOfCurrentWeek = firstDayOfWeek(_selectedDate);
      var lastDayOfCurrentWeek = lastDayOfWeek(_selectedDate);
      updateSelectedRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek);
      selectedWeekDays =
          Utils.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
              .toList();
      var monthFormat =
          DateFormat('MMMM yyyy', widget.locale).format(_selectedDate);
      displayMonth =
          '${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}';
      _selectedEvents = eventsMap?[DateTime(
              _selectedDate.year, _selectedDate.month, _selectedDate.day)] ??
          [];
    });
    launchDateSelectionCallback(_selectedDate);
  }

  void updateSelectedRange(DateTime start, DateTime end) {
    Range rangeSelected = Range(start, end);
    if (widget.onRangeSelected != null) {
      widget.onRangeSelected!(rangeSelected);
    }
  }

  void onJumpToDateSelected(DateTime selectedDate) {
    _selectedDate = selectedDate;
    var firstDayOfCurrentWeek = firstDayOfWeek(_selectedDate);
    var lastDayOfCurrentWeek = lastDayOfWeek(_selectedDate);

    setState(() {
      selectedWeekDays =
          Utils.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
              .toList();
      selectedMonthsDays = daysInMonth(_selectedDate);
      var monthFormat =
          DateFormat('MMMM yyyy', widget.locale).format(_selectedDate);
      displayMonth =
          '${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}';
      _selectedEvents = eventsMap?[DateTime(
              _selectedDate.year, _selectedDate.month, _selectedDate.day)] ??
          [];
    });

    launchDateSelectionCallback(_selectedDate);
  }

  void onSwipeUp() {
    if (isExpanded) toggleExpanded();
  }

  void onSwipeDown() {
    if (!isExpanded) toggleExpanded();
  }

  void onSwipeRight() {
    if (isExpanded) {
      previousMonth();
    } else {
      previousWeek();
    }
  }

  void onSwipeLeft() {
    if (isExpanded) {
      nextMonth();
    } else {
      nextWeek();
    }
  }

  void toggleExpanded() {
    if (widget.isExpandable) {
      setState(() => isExpanded = !isExpanded);
      if (widget.onExpandStateChanged != null) {
        widget.onExpandStateChanged!(isExpanded);
      }
    }
  }

  void handleSelectedDateAndUserCallback(DateTime day) {
    debugPrint('daySelected: $day');
    var firstDayOfCurrentWeek = firstDayOfWeek(day);
    var lastDayOfCurrentWeek = lastDayOfWeek(day);
    // Flag to decide if we should trigger "onDateSelected" callback
    // This avoids doule executing the callback when selecting a date in the next month
    bool isCallback = true;
    // Check if the selected day falls into the next month. If this is the case,
    // then we need to additionaly check, if a day in next year was selected.
    if (_selectedDate.month > day.month) {
      // Day in next year selected? Switch to next month.
      if (_selectedDate.year < day.year) {
        nextMonth();
      } else {
        previousMonth();
      }
      // Callback already fired in nextMonth() or previoisMonth(). Dont
      // execute it again.
      isCallback = false;
    }
    // Check if the selected day falls into the last month. If this is the case,
    // then we need to additionaly check, if a day in last year was selected.
    if (_selectedDate.month < day.month) {
      // Day in next last selected? Switch to next month.
      if (_selectedDate.year > day.year) {
        previousMonth();
      } else {
        nextMonth();
      }
      // Callback already fired in nextMonth() or previoisMonth(). Dont
      // execute it again.
      isCallback = false;
    }
    setState(() {
      _selectedDate = day;
      selectedWeekDays =
          Utils.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
              .toList();
      selectedMonthsDays = daysInMonth(day);
      _selectedEvents = eventsMap?[_selectedDate] ?? [];
    });
    // Check, if the callback was already executed before.
    if (isCallback) launchDateSelectionCallback(_selectedDate);
  }

  void launchDateSelectionCallback(DateTime day) {
    if (widget.onDateSelected != null) widget.onDateSelected!(day);

    // Additional conditions: Only if month or year changed, then call the callback.
    // This avoids double executing the callback when selecting a date in the same month.
    if (widget.onMonthChanged != null && day.month != _selectedDate.month ||
        day.year != _selectedDate.year) {
      widget.onMonthChanged!(day);
    }
  }

  firstDayOfWeek(DateTime date) {
    var day = DateTime.utc(
        _selectedDate.year, _selectedDate.month, _selectedDate.day, 12);
    if (widget.startOnMonday == true) {
      day = day.subtract(Duration(days: day.weekday - 1));
    } else {
      // if the selected day is a Sunday, then it is already the first day of week
      day = day.weekday == 7 ? day : day.subtract(Duration(days: day.weekday));
    }
    return day;
  }

  lastDayOfWeek(DateTime date) {
    return firstDayOfWeek(date).add(const Duration(days: 7));
  }

  /// The function [daysInMonth] takes the parameter [month] (which is of type [DateTime])
  /// and calculates then all the days to be displayed in month view based on it. It returns
  /// all that days in a [List<DateTime].
  List<DateTime> daysInMonth(DateTime month) {
    var first = Utils.firstDayOfMonth(month);
    var daysBefore = first.weekday;
    var firstToDisplay = first
        .subtract(Duration(days: daysBefore - (widget.startOnMonday ? 1 : 0)));
    var last = Utils.lastDayOfMonth(month);

    var daysAfter = 7 - last.weekday;

    // If the last day is sunday (7) the entire week must be rendered
    if (daysAfter == 0) daysAfter = 7;
    // Adding an extra day necessary (if week starts on Monday).
    // Otherwise the week with days in next month would always end on Saturdays.
    var lastToDisplay =
        last.add(Duration(days: daysAfter + (widget.startOnMonday ? 1 : 0)));
    return Utils.daysInRange(firstToDisplay, lastToDisplay).toList();
  }
}




