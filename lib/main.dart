import 'dart:async';
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
    bodyText1: GoogleFonts.roboto(),
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

  void _updateTime(int hours, int minutes, int seconds) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_currentIndex == 0) {
      setState(() {
        if (_activeMode == "freeTime" ||
            (hours == 0 && minutes == 0 && seconds == 0)) {
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
            (hours == 0 && minutes == 0 && seconds == 0)) {
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
          (hours == 0 && minutes == 0 && seconds == 0)) {
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
          (hours == 0 && minutes == 0 && seconds == 0)) {
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

    // If it's a new week, save the last week's data
    if (currentKW != lastSavedKW) {
      for (String day in daysOfWeek) {
        String freeTimeKey = 'currentDayFreeTime' + day;
        String productiveTimeKey = 'currentDayProductiveTime' + day;

        int freeTimeSeconds = prefs.getInt(freeTimeKey) ?? 0;
        int productiveTimeSeconds = prefs.getInt(productiveTimeKey) ?? 0;

        print('KW$lastSavedKW$freeTimeKey');
        print(freeTimeSeconds);
        print('KW$lastSavedKW$productiveTimeKey');
        print(productiveTimeSeconds);

        // Save last week's data with a KW mark
        await prefs.setInt('KW$lastSavedKW$freeTimeKey', freeTimeSeconds);
        await prefs.setInt(
            'KW$lastSavedKW$productiveTimeKey', productiveTimeSeconds);
        await prefs.setInt(freeTimeKey, 0);
        await prefs.setInt(productiveTimeKey, 0);
      }

      // Save the new KW mark
      await prefs.setInt("lastSavedKW", currentKW);
    }

    // Fetch the current total seconds and increment by 1 for each type
    int currentFreeTimeSeconds = (prefs.getInt(freeTimeKey) ?? 0) + increment;
    int currentProductiveTimeSeconds =
        (prefs.getInt(productiveTimeKey) ?? 0) + increment;
    int totalFreeTimeSeconds =
        (prefs.getInt("totalFreeTimeSeconds") ?? 0) + increment;
    int totalProductiveTimeSeconds =
        (prefs.getInt("totalProductiveTimeSeconds") ?? 0) + increment;

    int maximumProductiveSeconds =
        prefs.getInt("maximumProductiveSeconds") ?? 0;

    DateTime now = DateTime.now();
    String lastResetDateKey = "lastResetDate";
    String? lastResetDateString = await prefs.getString(lastResetDateKey);
    DateTime lastResetDate = lastResetDateString != null
        ? DateTime.parse(lastResetDateString)
        : DateTime.now().subtract(Duration(days: 1)); // Default to yesterday

    DateTime midnightYesterday = DateTime(now.year, now.month, now.day);
    int secondsSinceMidnight = now.difference(midnightYesterday).inSeconds;

    int secondsForToday = secondsSinceMidnight;
    int secondsForYesterday = increment - secondsSinceMidnight;
    String yesterdayKey = daysOfWeek[(currentDayOfWeek + 5) % 7];

    // Compare the last reset date to the current date
    if (now.year > lastResetDate.year ||
        now.month > lastResetDate.month ||
        now.day > lastResetDate.day) {
      if (increment > 1) {
        if (_activeMode == "freeTime") {
          await prefs.setInt(yesterdayKey, secondsForYesterday);
          await prefs.setInt(freeTimeKey, secondsForToday);
          await prefs.setInt("totalFreeTimeSeconds", totalFreeTimeSeconds);
        } else {
          await prefs.setInt(productiveTimeKey, currentProductiveTimeSeconds);
          await prefs.setInt(
              "totalProductiveTimeSeconds", totalProductiveTimeSeconds);
        }
      } else {
        await prefs.setInt(freeTimeKey, 0);
        await prefs.setInt(productiveTimeKey, 0);
      }
      // Update the last reset date to today
      await prefs.setString(lastResetDateKey, now.toIso8601String());
      if (totalProductiveTimeSeconds > maximumProductiveSeconds) {
        await prefs.setInt(
            "maximumProductiveSeconds", totalProductiveTimeSeconds);
      }
    } else {
      // Save the updated seconds back to SharedPreferences
      if (_activeMode == "freeTime") {
        await prefs.setInt(freeTimeKey, currentFreeTimeSeconds);
        await prefs.setInt("totalFreeTimeSeconds", totalFreeTimeSeconds);
      } else {
        await prefs.setInt(productiveTimeKey, currentProductiveTimeSeconds);
        await prefs.setInt(
            "totalProductiveTimeSeconds", totalProductiveTimeSeconds);
      }
    }

    // Temporary print for debugging - shows the seconds value for every weekday
    print("########## Total Seconds for Each Day ##########");
    print("Total Seconds productive: $totalProductiveTimeSeconds");
    print("Total Seconds productive: $totalFreeTimeSeconds");
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
    _updateTime(0, 0, 0);
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

    _updateTime(hours, minutes, seconds);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (_productiveInterval.isActive && state == AppLifecycleState.paused) {
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
    super.build(context);
    return Padding(
      padding: EdgeInsets.only(top: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500),
          ),
          SizedBox(height: 20),
          _buildTimer(
            "Free Time",
            freeTimeHours,
            freeTimeMinutes,
            freeTimeSeconds,
          ),
          SizedBox(height: 20),
          _buildTimer(
            "Productive Time",
            productiveHours,
            productiveMinutes,
            productiveSeconds,
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
  ) {
    return Column(
      children: [
        SizedBox(height: 10),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeSpan(hours, context),
              Text(
                ":",
                style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 55,
                    fontWeight: FontWeight.normal),
              ),
              _buildTimeSpan(minutes, context),
              Text(":", style: TextStyle(fontSize: 55)),
              _buildTimeSpan(seconds, context),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildTimeSpan(String value, BuildContext context) {
    // Get the TextScaler from the MediaQuery
    TextScaler textScaler = MediaQuery.of(context).textScaler;

    // Use TextScaler to scale the font size
    double scaledFontSize = textScaler.scale(55);

    return Neumorphic(
      padding: EdgeInsets.all(10),
      style: NeumorphicStyle(
        shape: NeumorphicShape.concave,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        depth: 8,
        lightSource: LightSource.topLeft,
      ),
      child: Container(
        width: 75,
        child: Center(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: scaledFontSize,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Function() onPressed) {
    if (Icons.sync == icon) {
      return TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          primary: Colors.black,
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
          primary: Colors.black,
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
        primary: Colors.black,
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
