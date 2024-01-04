import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:neumorphic_ui/neumorphic_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer/sharedFunctions.dart';

Map<String, String> achievementKeys = {
  'Reach 2 productive hours average': 'achievement_two_hours',
  'Reach 4 productive hours average': 'achievement_four_hours',
  'Reach 6 productive hours average': 'achievement_six_hours',
  'Track everyday of the Week': 'achievement_everyday_week',
  'Reach your productive Goal once': 'achievement_goal_once',
  'Reach your productive goal 10 times': 'achievement_goal_ten_times',
  'Reach your productive goal 100 times': 'achievement_goal_hundred_times',
};

class Achievement {
  String title;
  IconData icon;
  int maximumValue;
  double alreadyDone;
  int decimalPoints;

  Achievement({
    required this.title,
    this.icon = Icons.emoji_events,
    required this.maximumValue,
    this.alreadyDone = 0.0,
    required this.decimalPoints,
  });

  double get progressPercentage => alreadyDone / maximumValue;
}

class AchievementsPage extends StatefulWidget {
  @override
  _AchievementsPageState createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  late List<Achievement> achievements;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    // Initialize achievements here or fetch them from a database or SharedPreferences
    achievements = [
      Achievement(
          title: 'Reach 2 productive hours average',
          icon: Icons.check_circle_outline,
          maximumValue: 2,
          decimalPoints: 2),
      Achievement(
          title: 'Reach 4 productive hours average',
          icon: Icons.emoji_events,
          maximumValue: 4,
          decimalPoints: 2),
      Achievement(
          title: 'Reach 6 productive hours average',
          icon: Icons.monetization_on,
          maximumValue: 6,
          decimalPoints: 2),
      Achievement(
          title: 'Track everyday of the Week',
          icon: Icons.directions_walk,
          maximumValue: 7,
          decimalPoints: 0),
      Achievement(
          title: 'Reach your productive Goal once',
          icon: Icons.directions_run,
          maximumValue: 1,
          decimalPoints: 0),
      Achievement(
          title: 'Reach your productive goal 10 times',
          icon: Icons.book,
          maximumValue: 10,
          decimalPoints: 0),
      Achievement(
          title: 'Reach your productive goal 100 times',
          icon: Icons.nature,
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

    for (Achievement achievement in achievements) {
      switch (achievement.title) {
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
          achievement.alreadyDone =
              await checkIfAllDaysHaveProductiveTime() ? 1.0 : 0.0;
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

      // Save updated progress in SharedPreferences
      String key = achievementKeys[achievement.title] ?? 'default_key';
      await prefs.setDouble(key, achievement.progressPercentage);
    }

    // Refresh UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 70.0, 8.0, 20.0),
              child: Text(
                'Achievements',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
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
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    );
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
                    widget.achievement.title,
                    style: TextStyle(fontSize: 18),
                  ),
                  Icon(widget.achievement.icon, color: Colors.grey[700]),
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
                    '${widget.achievement.alreadyDone.toStringAsFixed(widget.achievement.decimalPoints)}/${widget.achievement.maximumValue}',
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
