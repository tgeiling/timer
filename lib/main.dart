import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neumorphic_ui/neumorphic_ui.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'stats.dart';
import 'achivements.dart';

import 'sharedFunctions.dart';

void main() {
  runApp(MyApp());
}

ThemeData themeData = ThemeData(
  textTheme: TextTheme(
    bodyLarge: GoogleFonts.roboto(),
  ),
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: themeData,
      home: MainScaffold(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScaffold extends StatefulWidget {
  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

var _currentIndex = 0;
List<double> weekValues = [];
double freetimeDailyGoal = 0;
double productiveDailyGoal = 0;
bool brake = false;

class _MainScaffoldState extends State<MainScaffold> {
  PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          MainFrame(),
          Stats(
            weekValues: weekValues,
            freetimeDailyGoal: freetimeDailyGoal,
            productiveDailyGoal: productiveDailyGoal,
          ),
          AchievementsPage(),
          Container(child: Center(child: Text("Comming Soon"))),
        ],
      ),
      bottomNavigationBar: SalomonBottomBar(
        backgroundColor: Colors.grey[100],
        currentIndex: _currentIndex,
        onTap: (i) {
          _pageController.jumpToPage(i);
        },
        items: [
          SalomonBottomBarItem(
            icon: NeumorphicIcon(
              Icons.home,
              size: 40,
              style: NeumorphicStyle(depth: 2, color: Colors.grey.shade400),
            ),
            title: Text("Timer"),
            selectedColor: Colors.grey[600],
          ),
          SalomonBottomBarItem(
            icon: NeumorphicIcon(
              Icons.bar_chart_sharp,
              size: 40,
              style: NeumorphicStyle(depth: 2, color: Colors.grey.shade400),
            ),
            title: Text("Stats"),
            selectedColor: Colors.grey[600],
          ),
          SalomonBottomBarItem(
            icon: NeumorphicIcon(
              Icons.star,
              size: 40,
              style: NeumorphicStyle(depth: 2, color: Colors.grey.shade400),
            ),
            title: Text("Ach."),
            selectedColor: Colors.grey[600],
          ),
          SalomonBottomBarItem(
            icon: NeumorphicIcon(
              Icons.person,
              size: 40,
              style: NeumorphicStyle(depth: 2, color: Colors.grey.shade400),
            ),
            title: Text("Profile"),
            selectedColor: Colors.grey[600],
          ),
        ],
      ),
    );
  }
}

class MainFrame extends StatefulWidget {
  @override
  _MainFrameState createState() => _MainFrameState();
}

class _MainFrameState extends State<MainFrame>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  late Timer _freeTimeInterval;
  late Timer _productiveInterval;

  String _activeMode = "freeTime";
  late int _freeTimeTotalSeconds;
  late int _productiveTimeTotalSeconds;

  @override
  void initState() {
    super.initState();
    _loadSavedValues();
    _resetTimers();
    WidgetsBinding.instance.addObserver(this);
  }

  void _updateTime(int hours, int minutes, int seconds, bool edit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_currentIndex == 0) {
      setState(() {
        if (_activeMode == "freeTime" ||
            (hours == 0 && minutes == 0 && seconds == 0) && !edit) {
          freeTimeHours = hours.toString().padLeft(2, "0");
          freeTimeMinutes = minutes.toString().padLeft(2, "0");
          freeTimeSeconds = seconds.toString().padLeft(2, "0");

          // Save the values to SharedPreferences
          prefs.setString('freeTimeHours', freeTimeHours);
          prefs.setString('freeTimeMinutes', freeTimeMinutes);
          prefs.setString('freeTimeSeconds', freeTimeSeconds);

          _freeTimeTotalSeconds = getTotalSecondsFromTime(
            hours: freeTimeHours,
            minutes: freeTimeMinutes,
            seconds: freeTimeSeconds,
          );

          prefs.setInt('freeTimeTotalSeconds', _freeTimeTotalSeconds);
        }

        if (_activeMode == "productive" ||
            (hours == 0 && minutes == 0 && seconds == 0) && !edit) {
          productiveHours = hours.toString().padLeft(2, "0");
          productiveMinutes = minutes.toString().padLeft(2, "0");
          productiveSeconds = seconds.toString().padLeft(2, "0");

          // Save the values to SharedPreferences
          prefs.setString('productiveHours', productiveHours);
          prefs.setString('productiveMinutes', productiveMinutes);
          prefs.setString('productiveSeconds', productiveSeconds);

          _productiveTimeTotalSeconds = getTotalSecondsFromTime(
            hours: productiveHours,
            minutes: productiveMinutes,
            seconds: productiveSeconds,
          );

          prefs.setInt(
              'productiveTimeTotalSeconds', _productiveTimeTotalSeconds);
        }
      });
    } else {
      if (_activeMode == "freeTime" ||
          (hours == 0 && minutes == 0 && seconds == 0) && !edit) {
        freeTimeHours = hours.toString().padLeft(2, "0");
        freeTimeMinutes = minutes.toString().padLeft(2, "0");
        freeTimeSeconds = seconds.toString().padLeft(2, "0");

        // Save the values to SharedPreferences
        prefs.setString('freeTimeHours', freeTimeHours);
        prefs.setString('freeTimeMinutes', freeTimeMinutes);
        prefs.setString('freeTimeSeconds', freeTimeSeconds);

        _freeTimeTotalSeconds = getTotalSecondsFromTime(
          hours: freeTimeHours,
          minutes: freeTimeMinutes,
          seconds: freeTimeSeconds,
        );

        prefs.setInt('freeTimeTotalSeconds', _freeTimeTotalSeconds);
      }

      if (_activeMode == "productive" ||
          (hours == 0 && minutes == 0 && seconds == 0) && !edit) {
        productiveHours = hours.toString().padLeft(2, "0");
        productiveMinutes = minutes.toString().padLeft(2, "0");
        productiveSeconds = seconds.toString().padLeft(2, "0");

        // Save the values to SharedPreferences
        prefs.setString('productiveHours', productiveHours);
        prefs.setString('productiveMinutes', productiveMinutes);
        prefs.setString('productiveSeconds', productiveSeconds);

        _productiveTimeTotalSeconds = getTotalSecondsFromTime(
          hours: productiveHours,
          minutes: productiveMinutes,
          seconds: productiveSeconds,
        );

        prefs.setInt('productiveTimeTotalSeconds', _productiveTimeTotalSeconds);
      }
    }

    _saveCurrentDayData(1);
  }

  void _loadSavedValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      freeTimeHours = prefs.getString('freeTimeHours') ?? '00';
      freeTimeMinutes = prefs.getString('freeTimeMinutes') ?? '00';
      freeTimeSeconds = prefs.getString('freeTimeSeconds') ?? '00';

      productiveHours = prefs.getString('productiveHours') ?? '00';
      productiveMinutes = prefs.getString('productiveMinutes') ?? '00';
      productiveSeconds = prefs.getString('productiveSeconds') ?? '00';

      _freeTimeTotalSeconds = prefs.getInt('freeTimeTotalSeconds') ?? 0;
      _productiveTimeTotalSeconds =
          prefs.getInt('productiveTimeTotalSeconds') ?? 0;
      freetimeDailyGoal = prefs.getDouble('freetimeDailyGoal') ?? 0;
      productiveDailyGoal = prefs.getDouble('productiveDailyGoal') ?? 0;

      weekValues = weekValues;
    });
    freetimeDailyGoal = await prefs.getDouble('freetimeDailyGoal') ?? 0;
    productiveDailyGoal = await prefs.getDouble('productiveDailyGoal') ?? 0;
    weekValues =
        await calculateWeeklyProgress(productiveDailyGoal, "productive");
    setState(() {});
  }

  int storedFreeTimeSeconds = 0;
  int storedProductiveTimeSeconds = 0;
  int storedTotalFreeTimeSeconds = 0;
  int storedTotalProductiveTimeSeconds = 0;

  void _loadStoredTimeValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    storedFreeTimeSeconds = prefs.getInt("storedFreeTimeSeconds") ?? 0;
    storedProductiveTimeSeconds =
        prefs.getInt("storedProductiveTimeSeconds") ?? 0;
    storedTotalFreeTimeSeconds =
        prefs.getInt("storedTotalFreeTimeSeconds") ?? 0;
    storedTotalProductiveTimeSeconds =
        prefs.getInt("storedTotalProductiveTimeSeconds") ?? 0;

    print("✅ Loaded stored time values at app start:");
    print(
        "Free Time: $storedFreeTimeSeconds, Productive Time: $storedProductiveTimeSeconds");
    print(
        "Total Free Time: $storedTotalFreeTimeSeconds, Total Productive Time: $storedTotalProductiveTimeSeconds");
  }

  void _saveCurrentDayData(int increment) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
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

    String freeTimeKey =
        'currentDayFreeTime' + daysOfWeek[currentDayOfWeek - 1];
    String productiveTimeKey =
        'currentDayProductiveTime' + daysOfWeek[currentDayOfWeek - 1];

    int currentKW = getIsoWeekNumber(DateTime.now());
    int lastSavedKW = prefs.getInt("lastSavedKW") ?? 0;

    // If it's a new week, reset weekly data
    if (currentKW != lastSavedKW) {
      for (String day in daysOfWeek) {
        String freeTimeKey = 'currentDayFreeTime' + day;
        String productiveTimeKey = 'currentDayProductiveTime' + day;

        int freeTimeSeconds = prefs.getInt(freeTimeKey) ?? 0;
        int productiveTimeSeconds = prefs.getInt(productiveTimeKey) ?? 0;

        await prefs.setInt('KW$lastSavedKW$freeTimeKey', freeTimeSeconds);
        await prefs.setInt(
            'KW$lastSavedKW$productiveTimeKey', productiveTimeSeconds);
        await prefs.setInt(freeTimeKey, 0);
        await prefs.setInt(productiveTimeKey, 0);
      }
      await prefs.setInt("lastSavedKW", currentKW);
    }

    DateTime now = DateTime.now();
    String lastResetDateKey = "lastResetDate";
    String? lastResetDateString = await prefs.getString(lastResetDateKey);
    DateTime lastResetDate = lastResetDateString != null
        ? DateTime.parse(lastResetDateString)
        : DateTime.now().subtract(Duration(days: 1)); // Default to yesterday
    DateTime midnightToday = DateTime(now.year, now.month, now.day);

    // Check if it's a new day
    bool isNewDay = now.year > lastResetDate.year ||
        now.month > lastResetDate.month ||
        now.day > lastResetDate.day;

    // Calculate time values first
    int secondsSinceMidnight = now.difference(midnightToday).inSeconds;
    int secondsForToday = min(increment, secondsSinceMidnight);
    int secondsForYesterday =
        increment > secondsSinceMidnight ? increment - secondsSinceMidnight : 0;
    String yesterdayKey =
        daysOfWeek[(currentDayOfWeek + 5) % 7]; // This gives the previous day

    // ✅ Update only the appropriate global variables based on active mode
    if (_activeMode == "freeTime") {
      // If it's a new day and the increment contains time from yesterday,
      // only add today's portion to the daily counter
      if (isNewDay && increment > secondsSinceMidnight) {
        storedFreeTimeSeconds = max(0, secondsForToday);
      } else {
        storedFreeTimeSeconds = max(0, storedFreeTimeSeconds + increment);
      }
      storedTotalFreeTimeSeconds =
          max(0, storedTotalFreeTimeSeconds + increment);
    } else {
      // If it's a new day and the increment contains time from yesterday,
      // only add today's portion to the daily counter
      if (isNewDay && increment > secondsSinceMidnight) {
        storedProductiveTimeSeconds = max(0, secondsForToday);
      } else {
        storedProductiveTimeSeconds =
            max(0, storedProductiveTimeSeconds + increment);
      }
      storedTotalProductiveTimeSeconds =
          max(0, storedTotalProductiveTimeSeconds + increment);
    }

    int maximumProductiveSeconds =
        prefs.getInt("maximumProductiveSeconds") ?? 0;

    // Reset daily counters if it's a new day (before we add the new increment)
    if (isNewDay) {
      // Reset daily counters but keep total counters
      storedFreeTimeSeconds = 0;
      storedProductiveTimeSeconds = 0;
    }

    if (_activeMode == "productive" &&
        storedProductiveTimeSeconds > maximumProductiveSeconds) {
      await prefs.setInt(
          "maximumProductiveSeconds", storedProductiveTimeSeconds);
    }

    // Compare the last reset date to the current date
    if (isNewDay) {
      if (increment > 1) {
        // Handle time that spans across midnight
        if (_activeMode == "freeTime") {
          // For yesterday: Save the portion of time that was spent yesterday
          String yesterdayFreeTimeKey = 'currentDayFreeTime' + yesterdayKey;
          int existingYesterdayTime = prefs.getInt(yesterdayFreeTimeKey) ?? 0;
          await prefs.setInt(yesterdayFreeTimeKey,
              existingYesterdayTime + secondsForYesterday);

          // For today: Only count the time spent after midnight
          await prefs.setInt(freeTimeKey, secondsForToday);
          await prefs.setInt(
              "totalFreeTimeSeconds", storedTotalFreeTimeSeconds);
        } else {
          // For yesterday: Save the portion of time that was spent yesterday
          String yesterdayProductiveTimeKey =
              'currentDayProductiveTime' + yesterdayKey;
          int existingYesterdayTime =
              prefs.getInt(yesterdayProductiveTimeKey) ?? 0;
          await prefs.setInt(yesterdayProductiveTimeKey,
              existingYesterdayTime + secondsForYesterday);

          // For today: Only count the time spent after midnight
          await prefs.setInt(productiveTimeKey, secondsForToday);
          await prefs.setInt(
              "totalProductiveTimeSeconds", storedTotalProductiveTimeSeconds);
        }
      } else {
        // When increment is 1 or less, this is a regular reset scenario
        await prefs.setInt(freeTimeKey, 0);
        await prefs.setInt(productiveTimeKey, 0);
      }
      // Update the last reset date to today
      await prefs.setString(lastResetDateKey, now.toIso8601String());
    } else {
      // ✅ Save only the updated values based on active mode
      if (_activeMode == "freeTime") {
        await prefs.setInt(freeTimeKey, storedFreeTimeSeconds);
        await prefs.setInt("totalFreeTimeSeconds", storedTotalFreeTimeSeconds);
      } else {
        await prefs.setInt(productiveTimeKey, storedProductiveTimeSeconds);
        await prefs.setInt(
            "totalProductiveTimeSeconds", storedTotalProductiveTimeSeconds);
      }
    }

    // Debug print statements to verify values
    print("########## Updated Stored Values ##########");
    print("Stored Free Time: $storedFreeTimeSeconds");
    print("Stored Productive Time: $storedProductiveTimeSeconds");
    print("Stored Total Free Time: $storedTotalFreeTimeSeconds");
    print("Stored Total Productive Time: $storedTotalProductiveTimeSeconds");

    for (String day in daysOfWeek) {
      String tempFreeKey = 'currentDayFreeTime' + day;
      String tempProdKey = 'currentDayProductiveTime' + day;
      int freeSeconds = prefs.getInt(tempFreeKey) ?? 0;
      int prodSeconds = prefs.getInt(tempProdKey) ?? 0;
      print(
          "$day - Free Time: $freeSeconds seconds, Productive Time: $prodSeconds seconds");
    }
  }

  int getTotalSecondsFromTime(
      {required String hours,
      required String minutes,
      required String seconds}) {
    int hoursInSeconds = int.parse(hours) * 3600; // 3600 seconds in an hour
    int minutesInSeconds = int.parse(minutes) * 60; // 60 seconds in a minute
    int secondsAsInt =
        int.parse(seconds); // seconds are already in the correct unit

    return hoursInSeconds + minutesInSeconds + secondsAsInt;
  }

  void _printLabel(String mode) {
    setState(() {
      label = mode;
    });
  }

  void _start() {
    if (_activeMode == "freeTime") {
      if (_freeTimeInterval != null && _freeTimeInterval.isActive) {
        return;
      }
      _freeTimeInterval = Timer.periodic(Duration(seconds: 1), _stopWatch);
    } else if (_activeMode == "productive") {
      if (_productiveInterval != null && _productiveInterval.isActive) {
        return;
      }
      _productiveInterval = Timer.periodic(Duration(seconds: 1), _stopWatch);
    }
    brake = false;
  }

  void _stop() {
    if (_activeMode == "freeTime") {
      _freeTimeInterval.cancel();
    } else if (_activeMode == "productive") {
      _productiveInterval.cancel();
    }
  }

  void _brakeStop() {
    if (_activeMode == "freeTime") {
      _freeTimeInterval.cancel();
    } else if (_activeMode == "productive") {
      _productiveInterval.cancel();
    }
    brake = true;
  }

  void _reset() {
    _freeTimeInterval.cancel();
    _productiveInterval.cancel();
    _freeTimeTotalSeconds = 0;
    _productiveTimeTotalSeconds = 0;
    _updateTime(0, 0, 0, false);
  }

  void _resetTimers() {
    _freeTimeInterval = Timer.periodic(Duration(seconds: 1), _stopWatch);
    _productiveInterval = Timer.periodic(Duration(seconds: 1), _stopWatch);
    _freeTimeInterval.cancel();
    _productiveInterval.cancel();
  }

  void _switchTime() {
    _stop();

    if (_activeMode == "freeTime") {
      setState(() {
        _activeMode = "productive";
      });
    } else if (_activeMode == "productive") {
      setState(() {
        _activeMode = "freeTime";
      });
    }

    _printLabel(_activeMode);
    _start();
  }

  void editTime(bool isFreeTime) async {
    TextEditingController hoursController = TextEditingController();
    TextEditingController minutesController = TextEditingController();
    TextEditingController secondsController = TextEditingController();

    if (_activeMode == "productive" && isFreeTime) {
      _switchTime();
    }
    if (_activeMode == "freeTime" && !isFreeTime) {
      _switchTime();
    }

    // Get current values based on new _activeMode
    int currentSeconds =
        isFreeTime ? _freeTimeTotalSeconds : _productiveTimeTotalSeconds;
    int currentHours = currentSeconds ~/ 3600;
    int currentMinutes = (currentSeconds % 3600) ~/ 60;
    int currentSecs = currentSeconds % 60;

    // Pre-fill text fields with current values
    hoursController.text = currentHours.toString();
    minutesController.text = currentMinutes.toString();
    secondsController.text = currentSecs.toString();

    _stop();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            isFreeTime ? "Edit Free Time" : "Edit Productive Time",
            style: TextStyle(color: Colors.black), // Title in black
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNeumorphicTextField(hoursController, "Hours"),
              SizedBox(height: 10),
              _buildNeumorphicTextField(minutesController, "Minutes"),
              SizedBox(height: 10),
              _buildNeumorphicTextField(secondsController, "Seconds"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.black), // Button text black
              ),
            ),
            TextButton(
              onPressed: () {
                int newHours = int.tryParse(hoursController.text) ?? 0;
                int newMinutes = int.tryParse(minutesController.text) ?? 0;
                int newSeconds = int.tryParse(secondsController.text) ?? 0;

                int newTotalSeconds =
                    (newHours * 3600) + (newMinutes * 60) + newSeconds;

                // Calculate the difference in seconds
                int elapsedTimeInSeconds = newTotalSeconds - currentSeconds;

                // Call _updateTime with the new values
                _updateTime(newHours, newMinutes, newSeconds, true);

                if (_activeMode == "freeTime") {
                  _freeTimeTotalSeconds += elapsedTimeInSeconds;
                } else if (_activeMode == "productive") {
                  _productiveTimeTotalSeconds += elapsedTimeInSeconds;
                }

                // Save the difference in the day's data
                _saveCurrentDayData(elapsedTimeInSeconds);

                Navigator.pop(context);
                _start();
              },
              child: Text(
                "Save",
                style: TextStyle(color: Colors.black), // Button text black
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNeumorphicTextField(
      TextEditingController controller, String label) {
    return Neumorphic(
      style: NeumorphicStyle(
        depth: -4,
        intensity: 0.7,
        surfaceIntensity: 0.2,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        color: Colors.white, // Keep it light for visibility
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        cursorColor: Colors.black, // Ensure black cursor
        style: TextStyle(color: Colors.black), // Input text color
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black), // Label in black
          border: InputBorder.none, // Neumorphic removes default border
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }

  void _stopWatch(Timer timer) {
    late int counter; // Provide an initial value
    if (_activeMode == "freeTime") {
      print(_freeTimeTotalSeconds);
      counter = ++_freeTimeTotalSeconds;
    } else if (_activeMode == "productive") {
      print(_productiveTimeTotalSeconds);
      counter = ++_productiveTimeTotalSeconds;
    }

    int hours = counter ~/ 3600;
    int minutes = (counter ~/ 60) % 60;
    int seconds = counter % 60;

    _updateTime(hours, minutes, seconds, false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (_productiveInterval.isActive ||
        _freeTimeInterval.isActive && state == AppLifecycleState.paused) {
      // Save the current time when the app is paused
      _saveCurrentTime();
      _brakeStop();
    } else if (brake == true && state == AppLifecycleState.resumed) {
      // Calculate the elapsed time and update the timer when the app is resumed
      _updateTimerOnResume();
      _start();
    }
  }

  void _saveCurrentTime() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('lastPauseTime', DateTime.now().millisecondsSinceEpoch);
  }

  void _updateTimerOnResume() async {
    final prefs = await SharedPreferences.getInstance();
    int lastPauseTime =
        prefs.getInt('lastPauseTime') ?? DateTime.now().millisecondsSinceEpoch;
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int elapsedTimeInSeconds = (currentTime - lastPauseTime) ~/ 1000;

    if (_activeMode == "freeTime" && _freeTimeInterval.isActive) {
      _freeTimeTotalSeconds += elapsedTimeInSeconds;
    } else if (_activeMode == "productive" && _productiveInterval.isActive) {
      _productiveTimeTotalSeconds += elapsedTimeInSeconds;
    }

    _saveCurrentDayData(elapsedTimeInSeconds);
  }

  String label = "freeTime";
  String freeTimeHours = "00";
  String freeTimeMinutes = "00";
  String freeTimeSeconds = "00";
  String productiveHours = "00";
  String productiveMinutes = "00";
  String productiveSeconds = "00";

  @override
  Widget build(BuildContext context) {
    // Get the TextScaler from the MediaQuery
    TextScaler textScaler = MediaQuery.of(context).textScaler;

    double baseFontSize = 45;
    double scaledFontSize = textScaler.scale(baseFontSize);
    double maxFontSize = 50;
    double finalFontSize =
        (scaledFontSize > maxFontSize) ? maxFontSize : scaledFontSize;

    super.build(context);
    return Padding(
      padding: EdgeInsets.only(top: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: finalFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500),
          ),
          SizedBox(height: 20),
          _buildTimer(
            "Free Time",
            freeTimeHours,
            freeTimeMinutes,
            freeTimeSeconds,
            true,
          ),
          SizedBox(height: 20),
          _buildTimer(
            "Productive Time",
            productiveHours,
            productiveMinutes,
            productiveSeconds,
            false,
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconButton(Icons.sync, _switchTime),
              _buildIconButton(Icons.play_arrow, _start),
              _buildIconButton(Icons.stop, _stop),
              _buildIconButton(Icons.delete, _reset),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimer(
    String label,
    String hours,
    String minutes,
    String seconds,
    bool isFreeTime,
  ) {
    TextScaler textScaler = MediaQuery.of(context).textScaler;

    double baseFontSize = 50;
    double scaledFontSize = textScaler.scale(baseFontSize);
    double maxFontSize = 55;
    double finalFontSize =
        (scaledFontSize > maxFontSize) ? maxFontSize : scaledFontSize;

    return Column(
      children: [
        SizedBox(height: 10),
        Stack(
          clipBehavior: Clip
              .none, // Allows button to slightly overflow without affecting layout
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(child: _buildTimeSpan(hours, context)),
                Text(
                  ":",
                  style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 55,
                      fontWeight: FontWeight.normal),
                ),
                Flexible(child: _buildTimeSpan(minutes, context)),
                Text(":", style: TextStyle(fontSize: finalFontSize)),
                Flexible(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildTimeSpan(
                          seconds, context), // Keeps original styling
                      Positioned(
                        top: -8, // Adjust slightly for better positioning
                        right:
                            -8, // Align perfectly to top-right of seconds box
                        child: GestureDetector(
                          onTap: () {
                            editTime(isFreeTime);
                          },
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[400],
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 2,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeSpan(String value, BuildContext context) {
    TextScaler textScaler = MediaQuery.of(context).textScaler;

    double baseFontSize = 52;
    double scaledFontSize = textScaler.scale(baseFontSize);
    double maxFontSize = 58;
    double finalFontSize =
        (scaledFontSize > maxFontSize) ? maxFontSize : scaledFontSize;

    return Neumorphic(
      padding: EdgeInsets.all(10),
      style: NeumorphicStyle(
        shape: NeumorphicShape.concave,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        depth: 8,
        intensity: 0.6,
        surfaceIntensity: 0.15,
        lightSource: LightSource.topLeft,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            padding: EdgeInsets.all(4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: finalFontSize,
                  fontFeatures: [FontFeature.tabularFigures()],
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Function() onPressed) {
    if (Icons.sync == icon) {
      return TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Colors.black,
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        ),
        child: NeumorphicIcon(
          icon,
          size: 52,
          style: NeumorphicStyle(
            color: Colors.blue,
            depth: 2,
          ),
        ),
      );
    }

    if (Icons.delete == icon) {
      return TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Colors.black,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        child: NeumorphicIcon(
          icon,
          size: 60,
          style: NeumorphicStyle(
            color: Colors.grey[400],
            depth: 2,
          ),
        ),
      );
    }

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: NeumorphicIcon(
        icon,
        size: 60,
        style: NeumorphicStyle(
          depth: 2,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
