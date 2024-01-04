import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      double progress = (hoursForDay / dailyGoal).clamp(0.0, 1.0);
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

Future<bool> checkIfAllDaysHaveProductiveTime() async {
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

  for (String day in daysOfWeek) {
    int totalSeconds = prefs.getInt('currentDayProductiveTime' + day) ?? 0;
    if (totalSeconds <= 0) {
      // If any day has 0 seconds, not all days have productive time
      return false;
    }
  }
  // If the loop completes, all days had some productive time
  return true;
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
