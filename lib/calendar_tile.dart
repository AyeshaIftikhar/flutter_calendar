import 'package:flutter/material.dart';
import './date_utils.dart';
import 'flutter_calendar_event.dart';
import "package:intl/intl.dart";


class FlutterCalenderTile extends StatelessWidget {
  final VoidCallback? onDateSelected;
  final DateTime? date;
  final String? dayOfWeek;
  final bool isDayOfWeek;
  final bool isSelected;
  final bool inMonth;
  final List<FlutterCalenderEvent>? events;
  final TextStyle? dayOfWeekStyle;
  final TextStyle? dateStyles;
  final Widget? child;
  final Color? defaultDayColor;
  final Color? defaultOutOfMonthDayColor;
  final Color? selectedColor;
  final Color? selectedTodayColor;
  final Color? todayColor;
  final Color? eventColor;
  final Color? eventDoneColor;
  // final String? image;

  const FlutterCalenderTile({
    super.key,
    this.onDateSelected,
    this.date,
    this.child,
    this.dateStyles,
    this.dayOfWeek,
    this.dayOfWeekStyle,
    this.isDayOfWeek = false,
    this.isSelected = false,
    this.inMonth = true,
    this.events,
    this.defaultDayColor,
    this.defaultOutOfMonthDayColor,
    this.selectedColor,
    this.selectedTodayColor,
    this.todayColor,
    this.eventColor,
    this.eventDoneColor,
  //  this.image,
  });

  /// This function [renderDateOrDayOfWeek] renders the week view or the month view. It is
  /// responsible for displaying a calendar tile. This can be a day (i.e. "Mon", "Tue" ...) in
  /// the header row or a date tile for each day of a week or a month. The property [isDayOfWeek]
  /// of the [FlutterCalenderTile] decides, if the rendered item should be a day or a date tile.
  Widget renderDateOrDayOfWeek(BuildContext context) {
    // We decide, if this calendar tile should display a day name in the header row. If this is the
    // case, we return a widget, that contains a text widget with style property [dayOfWeekStyle]
    if (isDayOfWeek) {
      return GestureDetector(
        child: Container(
          alignment: Alignment.center,
          child: Text(
            dayOfWeek ?? '',
            style: dayOfWeekStyle,
          ),
        ),
      );
    } else {
      // Here the date tiles get rendered. Initially eventCount is set to 0.
      // Every date tile can show up to three dots representing an event.
      int eventCount = 0;
      return GestureDetector(
        onTap: onDateSelected, // react on tapping
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: events != null ? 34 : 40,
                width: 40,

                // If this tile is the selected date, draw a colored circle on it. The circle is filled with
                // the color passed with the selectedColor parameter or red color.
                decoration: isSelected && date != null
                    ? BoxDecoration(
                        // shape: BoxShape.circle,
                        borderRadius: BorderRadius.circular(5),
                        color: selectedColor != null
                            ? Utils.isSameDay(date!, DateTime.now())
                                ? selectedTodayColor ?? Colors.red
                                : selectedColor
                            : Theme.of(context).primaryColor,
                        // image: events != null
                        //     ? DecorationImage(image: AssetImage(image))
                        //     : null,
                      )
                    : const BoxDecoration(),
                // : BoxDecoration(
                //     image: events != null
                //         ? DecorationImage(image: AssetImage(image))
                //         : null,
                //   ), // no decoration when not selected
                alignment: Alignment.center,
                child: Text(
                  date != null ? DateFormat("d").format(date!) : '',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                    color: isSelected && date != null
                        ? Colors.white
                        : Utils.isSameDay(date!, DateTime.now())
                            ? todayColor
                            : inMonth
                                ? defaultDayColor ?? Colors.black
                                : (defaultOutOfMonthDayColor ?? Colors.grey),
                  ),
                  // Grey color for previous or next months dates
                ),
              ),
              // Dots for the events
              events != null && events!.isNotEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: events!.map(
                        (event) {
                          eventCount++;
                          // Show a maximum of 3 dots.
                          if (eventCount > 3) return Container();
                          return Container(
                            margin: const EdgeInsets.only(
                                left: 2.0, right: 2.0, top: 1.0),
                            width: 5.0,
                            height: 5.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              // If event is done (isDone == true) set the color of the dots to
                              // the eventDoneColor (if given) otherwise use the primary color of
                              // the theme
                              // If the event is not done yet, we use the given eventColor or the
                              // color property of the NeatCleanCalendarEvent. If both aren't set, then
                              // the accent color of the theme get used.
                              color: (() {
                                return eventColor ??
                                    event.color ??
                                    Theme.of(context).colorScheme.secondary;
                              }()),
                            ),
                          );
                        },
                      ).toList())
                  : Container(),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // If a child widget was passed as parameter, this widget gets used to
    // be rendered to display weekday or date
    if (child != null) {
      return GestureDetector(
        onTap: onDateSelected,
        child: child,
      );
    }
    return Container(
      child: renderDateOrDayOfWeek(context),
    );
  }
}
