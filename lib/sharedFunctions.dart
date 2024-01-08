import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

Future<List<double>> calculateWeeklyProgress(
    double dailyGoal, String mode) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  List<double> weeklyProgress = [];
  for (String day in daysOfWeek) {
    String key = 'currentDay' +
        (mode == "productive" ? "ProductiveTime" : "FreeTime") +
        day;
    int totalSeconds = prefs.getInt(key) ?? 0;
    double hoursForDay = totalSeconds / 3600.0; // Convert seconds to hours
    double progress = (hoursForDay / dailyGoal).clamp(0.0, 1.0);

    // Debugging logs
    print(
        "Day: $day, Hours: $hoursForDay, Goal: $dailyGoal, Progress: $progress");

    weeklyProgress.add(progress);
  }
  return weeklyProgress;
}

Future<List<double>> calculateWeeklyProgressKW(
    double dailyGoal, String mode, int kw) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  List<double> weeklyProgress = [];
  for (String day in daysOfWeek) {
    // Adjust the key to include the specified KW
    String key = 'KW$kw' +
        'currentDay' +
        (mode == "productive" ? "ProductiveTime" : "FreeTime") +
        day;
    int totalSeconds = prefs.getInt(key) ?? 0;
    double hoursForDay = totalSeconds / 3600.0; // Convert seconds to hours
    double progress = (hoursForDay / dailyGoal).clamp(0.0, 1.0);

    // Debugging logs
    print(
        "KW: $kw, Day: $day, Hours: $hoursForDay, Goal: $dailyGoal, Progress: $progress");

    weeklyProgress.add(progress);
  }
  return weeklyProgress;
}

Stream<List<double>> calculateWeeklyProgressStream(
    double dailyGoal, String mode) async* {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  while (true) {
    List<double> weeklyProgress = [];

    for (String day in daysOfWeek) {
      String key = 'currentDay' +
          (mode == "productive" ? "ProductiveTime" : "FreeTime") +
          day;
      int totalSeconds = prefs.getInt(key) ?? 0;
      double hoursForDay = totalSeconds / 3600;
      double progress =
          dailyGoal == 0.0 ? 0.0 : (hoursForDay / dailyGoal).clamp(0.0, 1.0);
      weeklyProgress.add(progress);
    }

    yield weeklyProgress;

    await Future.delayed(
        Duration(seconds: 30)); // Adjust the duration as needed
  }
}

Future<double> calculateAverageProductiveHours() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  double totalHours = 0.0;
  int daysWithRecordedTime = 0;
  List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  for (String day in daysOfWeek) {
    int totalSeconds = prefs.getInt('currentDayProductiveTime' + day) ?? 0;
    if (totalSeconds > 0) {
      daysWithRecordedTime++;
      totalHours += totalSeconds / 3600; // Convert seconds to hours
    }
  }

  // Calculate the average based on days with recorded time
  return daysWithRecordedTime > 0 ? totalHours / daysWithRecordedTime : 0.0;
}

Future<double> calculateAverageFreeTimeHours() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  double totalHours = 0.0;
  int daysWithRecordedTime = 0;
  List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  for (String day in daysOfWeek) {
    int totalSeconds = prefs.getInt('currentDayFreeTime' + day) ?? 0;
    if (totalSeconds > 0) {
      daysWithRecordedTime++;
      totalHours += totalSeconds / 3600; // Convert seconds to hours
    }
  }

  return daysWithRecordedTime > 0 ? totalHours / daysWithRecordedTime : 0.0;
}

Future<double> calculateProductiveDaysPercentage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  int daysWithProductiveTime = 0;

  for (String day in daysOfWeek) {
    int totalSeconds = prefs.getInt('currentDayProductiveTime' + day) ?? 0;
    if (totalSeconds > 0) {
      daysWithProductiveTime++; // Increment count if the day had productive time
    }
  }

  // Calculate the percentage of days with productive time
  return daysWithProductiveTime.toDouble();
}

Future<double> calculateTodayProductiveHours() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Get the current day of the week
  int currentDayOfWeek = DateTime.now().weekday; // 1 = Monday, 7 = Sunday
  List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  String today = daysOfWeek[currentDayOfWeek - 1];

  // Fetch the total seconds recorded for today's productive time
  int totalSecondsToday = prefs.getInt('currentDayProductiveTime' + today) ?? 0;

  // Convert total seconds to hours
  double hoursToday = totalSecondsToday / 3600.0;

  return hoursToday;
}

Future<double> calculateTotalFreeTimeHours() async {
  final prefs = await SharedPreferences.getInstance();
  int totalFreeTimeSeconds = prefs.getInt('totalFreeTimeSeconds') ?? 0;
  return totalFreeTimeSeconds / 3600; // Convert seconds to hours
}

Future<double> calculateTotalProductiveTimeHours() async {
  final prefs = await SharedPreferences.getInstance();
  int totalProductiveTimeSeconds =
      prefs.getInt('totalProductiveTimeSeconds') ?? 0;
  return totalProductiveTimeSeconds / 3600; // Convert seconds to hours
}

Future<double> calculateMaximumProductiveTimeHours() async {
  final prefs = await SharedPreferences.getInstance();
  int maximumProductiveSeconds = prefs.getInt('maximumProductiveSeconds') ?? 0;
  return maximumProductiveSeconds / 3600;
}

String getCurrentCalendarWeek() {
  var now = DateTime.now();
  DateTime firstDayOfYear = DateTime(now.year, 1, 1);
  var weekOfYear =
      ((now.difference(firstDayOfYear).inDays - now.weekday + 10) / 7).floor();
  return '$weekOfYear';
}

String formatHoursToNearestFive(double totalHours) {
  int totalMinutes = (totalHours * 60).round(); // Convert to total minutes
  int roundedMinutes = (totalMinutes / 5).round() * 5; // Round to nearest 5

  int hours = roundedMinutes ~/ 60; // Calculate hours
  int minutes = roundedMinutes % 60; // Calculate remaining minutes

  return "${hours}h ${minutes}m"; // Return formatted string
}

int getIsoWeekNumber(DateTime date) {
  int dayOfYear = int.parse(DateFormat("D").format(date));
  int woy = ((dayOfYear - date.weekday + 10) / 7).floor();
  if (date.weekday == 7 && date.day < 4) {
    woy -= 1;
  }
  return woy;
}

Future<List<String>> getSavedKWWeeks() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> savedWeeks = [];
  List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  String mode =
      "ProductiveTime"; // Assume you're checking for "ProductiveTime" or "FreeTime"

  // Check up to 53 weeks as most years have 52 or 53 weeks
  for (int week = 1; week <= 53; week++) {
    bool weekHasData = false;

    // Check each day of the week for the current KW
    for (String day in daysOfWeek) {
      String key = 'KW$week' + 'currentDay' + mode + day;
      if (prefs.getInt(key) != null) {
        weekHasData = true;
        break; // No need to check further if one day has data
      }
    }

    if (weekHasData) {
      savedWeeks.add(week.toString());
    }
  }

  return savedWeeks;
}
