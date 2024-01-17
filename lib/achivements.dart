import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neumorphic_ui/neumorphic_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer/sharedFunctions.dart';
import 'package:timer/stats.dart';

Map<String, String> achievementKeys = {
  'Reach 10 productive hours total': 'achievement_ten_total_hours',
  'Reach 100 productive hours total': 'achievement_hundret_total_hours',
  'Reach 1000 productive hours total': 'achievement_thousand_total_hours',
  'Reach 2 productive hours average': 'achievement_two_hours',
  'Reach 4 productive hours average': 'achievement_four_hours',
  'Reach 6 productive hours average': 'achievement_six_hours',
  'Track everyday of the Week': 'achievement_everyday_week',
  'Reach your productive Goal once': 'achievement_goal_once',
  'Reach your productive goal 10 times': 'achievement_goal_ten_times',
  'Reach your productive goal 100 times': 'achievement_goal_hundred_times',
};

class Achievement {
  String header;
  String title;
  String imageAsset;
  int maximumValue;
  double alreadyDone;
  int decimalPoints;
  DateTime? completionDate;

  Achievement({
    required this.header,
    required this.title,
    required this.imageAsset,
    required this.maximumValue,
    this.alreadyDone = 0.0,
    required this.decimalPoints,
    this.completionDate,
  });

  double get progressPercentage => alreadyDone / maximumValue;
}

class AchievementsPage extends StatefulWidget {
  @override
  _AchievementsPageState createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage>
    with AutomaticKeepAliveClientMixin {
  late List<Achievement> achievements;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    loadAchievements();
    timer = Timer.periodic(
        Duration(seconds: 30), (Timer t) => updateAchievementProgress());
  }

  Future<void> loadAchievements() async {
    achievements = [
      Achievement(
          header: 'Baby Steps',
          title: 'Reach 10 productive hours total',
          imageAsset: 'assets/reach10total.png',
          maximumValue: 10,
          decimalPoints: 2),
      Achievement(
          header: 'Still nothing',
          title: 'Reach 100 productive hours total',
          imageAsset: 'assets/reach100total.png',
          maximumValue: 100,
          decimalPoints: 2),
      Achievement(
          header: 'Warmer',
          title: 'Reach 1000 productive hours total',
          imageAsset: 'assets/reach1000total.png',
          maximumValue: 1000,
          decimalPoints: 2),
      Achievement(
          header: 'Procrastinator',
          title: 'Reach 2 productive hours average',
          imageAsset: 'assets/reach2avg.png',
          maximumValue: 2,
          decimalPoints: 2),
      Achievement(
          header: 'Part-time work',
          title: 'Reach 4 productive hours average',
          imageAsset: 'assets/reach4avg.png',
          maximumValue: 4,
          decimalPoints: 2),
      Achievement(
          header: 'Padawan',
          title: 'Reach 6 productive hours average',
          imageAsset: 'assets/reach6avg.png',
          maximumValue: 6,
          decimalPoints: 2),
      Achievement(
          header: 'Monk',
          title: 'Track everyday of the Week',
          imageAsset: 'assets/reach7TrackedDay.png',
          maximumValue: 7,
          decimalPoints: 0),
      Achievement(
          header: 'First Blood',
          title: 'Reach your productive Goal once',
          imageAsset: 'assets/reach1goal.png',
          maximumValue: 1,
          decimalPoints: 0),
      Achievement(
          header: "App Enjoyer",
          title: 'Reach your productive goal 10 times',
          imageAsset: 'assets/reach10goal.png',
          maximumValue: 10,
          decimalPoints: 0),
      Achievement(
          header: "Phonk Enjoyer",
          title: 'Reach your productive goal 100 times',
          imageAsset: 'assets/reach100goal.png',
          maximumValue: 100,
          decimalPoints: 0),
    ];
    updateAchievementProgress();
    timer = Timer.periodic(
        Duration(seconds: 30), //later 60
        (Timer t) => updateAchievementProgress());
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<void> updateAchievementProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Simulating fetching daily values and goals from SharedPreferences
    double productiveDailyGoal =
        await prefs.getDouble('productiveDailyGoal') ?? 0.0;
    double freetimeDailyGoal =
        await prefs.getDouble('freetimeDailyGoal') ?? 0.0;

    for (Achievement achievement in achievements) {
      String? completionDateString =
          prefs.getString('${achievement.title}_completionDate');
      if (completionDateString != null) {
        DateTime completionDate = DateTime.parse(completionDateString);
        achievement.completionDate = completionDate;
      }
    }

    // You'd fetch and sum this from SharedPreferences for total productive time
    double totalProductiveTime = 0;
    double averageProductiveHours = await calculateAverageProductiveHours();
    double averageFreeTimeHours = await calculateAverageFreeTimeHours();
    double productiveProgress =
        (averageProductiveHours / productiveDailyGoal).clamp(0.0, 1.0);
    double freeTimeProgress =
        (averageFreeTimeHours / freetimeDailyGoal).clamp(0.0, 1.0);

    double todayProductiveHours = await calculateTodayProductiveHours();
    double todayProductiveProgress =
        (todayProductiveHours / productiveDailyGoal).clamp(0.0, 1.0);
    int productiveGoalHitCounter =
        await prefs.getInt("productiveGoalHitCounter") ?? 0;
    int lastUpdateTimestamp = prefs.getInt("productiveGoalLastUpdate") ?? 0;

    // Get current date and last update date
    DateTime currentDate = DateTime.now();
    DateTime lastUpdateDate =
        DateTime.fromMillisecondsSinceEpoch(lastUpdateTimestamp);

    // Check if today's date is different from last update's date and progress is complete
    if (currentDate.day != lastUpdateDate.day && todayProductiveProgress >= 1) {
      // Increment the counter and save the new value
      productiveGoalHitCounter += 1;
      await prefs.setInt("productiveGoalHitCounter", productiveGoalHitCounter);

      // Update the last update timestamp to current time
      await prefs.setInt(
          "productiveGoalLastUpdate", currentDate.millisecondsSinceEpoch);
    }

    double productiveDaysPercentage = await calculateProductiveDaysPercentage();

    for (Achievement achievement in achievements) {
      switch (achievement.title) {
        case 'Reach 10 productive hours total':
          achievement.alreadyDone = totalProductiveHours;
          break;
        case 'Reach 100 productive hours total':
          achievement.alreadyDone = totalProductiveHours;
          break;
        case 'Reach 1000 productive hours total':
          achievement.alreadyDone = totalProductiveHours;
          break;
        case 'Reach 2 productive hours average':
          achievement.alreadyDone = min(2, averageProductiveHours);
          break;
        case 'Reach 4 productive hours average':
          achievement.alreadyDone = min(4, averageProductiveHours);
          break;
        case 'Reach 6 productive hours average':
          achievement.alreadyDone = min(6, averageProductiveHours);
          break;
        case 'Track everyday of the Week':
          achievement.alreadyDone = productiveDaysPercentage;
          break;
        case 'Reach your productive Goal once':
          achievement.alreadyDone = productiveGoalHitCounter / 1;
          break;
        case 'Reach your productive goal 10 times':
          achievement.alreadyDone = productiveGoalHitCounter / 1;
          break;
        case 'Reach your productive goal 100 times':
          achievement.alreadyDone = productiveGoalHitCounter / 1;
          break;
        default:
          break;
      }

      for (Achievement achievement in achievements) {
        if (achievement.progressPercentage >= 1.0 &&
            achievement.completionDate == null) {
          achievement.completionDate = DateTime.now();

          String completionDateString =
              achievement.completionDate!.toIso8601String();
          await prefs.setString(
              '${achievement.title}_completionDate', completionDateString);
        }
      }

      // Save updated progress in SharedPreferences
      String key = achievementKeys[achievement.title] ?? 'default_key';
      await prefs.setDouble(key, achievement.progressPercentage);
    }

    // Refresh UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    int numberOfAchieved =
        achievements.where((a) => a.progressPercentage >= 1.0).length;

    // Get the TextScaler from the MediaQuery
    TextScaler textScaler = MediaQuery.of(context).textScaler;

    double baseFontSize = 34;
    double scaledFontSize = textScaler.scale(baseFontSize);
    double maxFontSize = 38;
    double finalFontSize =
        (scaledFontSize > maxFontSize) ? maxFontSize : scaledFontSize;

    double smallBaseFontSize = 24;
    double smallScaledFontSize = textScaler.scale(smallBaseFontSize);
    double smallMaxFontSize = 30;
    double smallFinalFontSize = (smallScaledFontSize > smallMaxFontSize)
        ? smallMaxFontSize
        : scaledFontSize;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Ensures column takes up only required space
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 90.0, 8.0, 20.0),
              child: Text(
                'Achievements',
                textAlign: TextAlign.center, // Center align the text
                style: TextStyle(
                    fontSize: finalFontSize, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              "$numberOfAchieved/${achievements.length}", // Display achieved/total achievements
              style: TextStyle(
                  fontSize: smallFinalFontSize,
                  color: Colors.grey), // Style the text
              textAlign: TextAlign.center, // Center align the text
            ),
            Expanded(
              child: ListView.builder(
                itemCount: achievements.length,
                itemBuilder: (context, index) {
                  return NeumorphicListItem(achievement: achievements[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class NeumorphicListItem extends StatefulWidget {
  final Achievement achievement;

  NeumorphicListItem({required this.achievement});

  @override
  _NeumorphicListItemState createState() => _NeumorphicListItemState();
}

class _NeumorphicListItemState extends State<NeumorphicListItem>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _animation = CurvedAnimation(
        parent: _animationController, curve: Curves.fastOutSlowIn);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
        depth: _isExpanded ? -4 : -10,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          InkWell(
            onTap: _toggleExpanded,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    widget.achievement.header,
                    style: TextStyle(fontSize: 18),
                  ),
                  Container(
                      width: 40, // Width constraint
                      height: 40, // Height constraint
                      child: Image.asset(
                        widget.achievement.imageAsset,
                        fit: BoxFit
                            .contain, // Ensures the image is contained within the widget's bounds
                      ))
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _animation,
            child: Container(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                children: [
                  Text(
                    widget.achievement.title,
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${widget.achievement.alreadyDone.toStringAsFixed(widget.achievement.decimalPoints)}/${widget.achievement.maximumValue}',
                    style: TextStyle(fontSize: 16),
                  ),
                  if (widget.achievement.completionDate != null)
                    Text(
                      'Completed on: ${DateFormat('dd.MM.yyyy').format(widget.achievement.completionDate!)}',
                      style: TextStyle(fontSize: 16),
                    ),
                  SizedBox(height: 8),
                  NeumorphicProgress(
                    percent: widget.achievement.progressPercentage,
                    height: 20,
                    duration: Duration(seconds: 1),
                    style: ProgressStyle(
                      accent: Colors.blue,
                      depth: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
