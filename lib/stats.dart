import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:neumorphic_ui/neumorphic_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fl_chart/fl_chart.dart';

import 'sharedFunctions.dart';

class Stats extends StatefulWidget {
  final List<double> weekValues;
  final double freetimeDailyGoal;
  final double productiveDailyGoal;

  Stats(
      {Key? key,
      required this.weekValues,
      required this.freetimeDailyGoal,
      required this.productiveDailyGoal})
      : super(key: key);

  @override
  _StatsState createState() => _StatsState();
}

double productiveDailyGoal = 0.0;
double freetimeDailyGoal = 0.0;
double averageProductiveHours = 0.0;
double averageFreeTimeHours = 0.0;
double totalProductiveHours = 0.0;
double totalFreeTimeHours = 0.0;
double maximumProductiveHours = 0.0;
double productiveProgress = 0.0;
double freeTimeProgress = 0.0;

List<double> lastKnownWeekValues = List.generate(7, (index) => 0.0);

List<String> daysOfWeek = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'So'];
List<double> weekValues = [];
List<String> savedKWs = [];

class _StatsState extends State<Stats> with AutomaticKeepAliveClientMixin {
  Timer? timer;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadSharedPreferences();
    timer = Timer.periodic(
        Duration(seconds: 5), (Timer t) => loadSharedPreferences());
  }

  Future<void> loadSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    savedKWs = await getSavedKWWeeks();

    //dailygoal
    double loadedProductiveDailyGoal =
        await prefs.getDouble('productiveDailyGoal') ??
            widget.productiveDailyGoal;
    double loadedFreetimeDailyGoal =
        await prefs.getDouble('freetimeDailyGoal') ?? widget.freetimeDailyGoal;

    //average hours
    double loadedAverageProductiveHours =
        await calculateAverageProductiveHours();
    double loadedAverageFreeTimeHours = await calculateAverageFreeTimeHours();

    //total hours
    double loadedTotalProductiveHours =
        await calculateTotalProductiveTimeHours();
    double loadedTotalFreeTimeHours = await calculateTotalFreeTimeHours();

    //total hours
    double loadedMaximumProductiveHours =
        await calculateMaximumProductiveTimeHours();

    double todayProductiveHours = await calculateTodayProductiveHours();

    productiveDailyGoal = loadedProductiveDailyGoal;
    freetimeDailyGoal = loadedFreetimeDailyGoal;
    totalProductiveHours = loadedTotalProductiveHours;
    totalFreeTimeHours = loadedTotalFreeTimeHours;
    maximumProductiveHours = loadedMaximumProductiveHours;

    double loadedProductiveProgress =
        (todayProductiveHours / productiveDailyGoal).clamp(0.0, 1.0);
    double loadedFreeTimeProgress =
        (loadedAverageFreeTimeHours / freetimeDailyGoal).clamp(0.0, 1.0);
    productiveProgress = loadedProductiveProgress;
    freeTimeProgress = loadedFreeTimeProgress;

    setState(() {
      productiveDailyGoal = loadedProductiveDailyGoal;
      freetimeDailyGoal = loadedFreetimeDailyGoal;
      averageProductiveHours = loadedAverageProductiveHours;
      averageFreeTimeHours = loadedAverageFreeTimeHours;
      productiveProgress = loadedProductiveProgress;
      freeTimeProgress = loadedFreeTimeProgress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60),
              SummaryCard(),
              SizedBox(height: 30),
              GoalCard(
                label: 'Productive Daily Goal',
                goalValue: productiveDailyGoal,
                progressValue: productiveProgress,
                timeIcons: _averageTimeIcons(
                  "productive",
                ),
              ),
              SizedBox(height: 30),
              GoalCard(
                label: 'Free Time Daily Goal',
                goalValue: freetimeDailyGoal,
                progressValue: freeTimeProgress,
                timeIcons: _averageTimeIcons(
                  "freetime",
                ),
              ),
              BarChartSample1(),
              SizedBox(height: 40),
            ],
          ),
        ));
  }

  Widget SummaryCard() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey, // Replace with the desired background color
        borderRadius: BorderRadius.circular(20), // Adjust for desired rounding
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSummaryItem(
                title: 'Total',
                value:
                    "${totalProductiveHours.toInt()}h ${((totalProductiveHours - totalProductiveHours.toInt()) * 60).toInt() % 60}m"),
            VerticalDivider(color: Colors.white54, thickness: 1, width: 30),
            _buildSummaryItem(
                title: 'Avg',
                value:
                    "${averageProductiveHours.toInt()}h ${((averageProductiveHours - averageProductiveHours.toInt()) * 60).toInt() % 60}m"),
            VerticalDivider(color: Colors.white54, thickness: 1, width: 30),
            _buildSummaryItem(
                title: 'Max',
                value:
                    "${maximumProductiveHours.toInt()}h ${((maximumProductiveHours - maximumProductiveHours.toInt()) * 60).toInt() % 60}m"),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({required String title, required String value}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  int touchedIndex = -1;
  final Color barBackgroundColor = Colors.white.withOpacity(0.3);
  final Color barColor = Colors.grey.shade500;
  final Color touchedBarColor = Colors.blue.shade400;
  bool isPastShown = false;
  String selectedKW = "";
  List<double> dummyWeekValues = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];

  Widget BarChartSample1() {
    if (isPastShown) {
      return FutureBuilder<List<double>>(
          future: calculateWeeklyProgressKW(
              productiveDailyGoal, "productive", int.parse(selectedKW)),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          Text(
                            'Weekly %',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10),
                          styledDropdownButton()
                        ],
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        'Productive hours KW' + selectedKW,
                        style: TextStyle(
                          color: Colors.grey.withOpacity(0.5),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 38,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: BarChart(
                            mainBarData(dummyWeekValues),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                    ],
                  ),
                ),
              );
            }

            List<double> weekValuesKW = snapshot.data!;

            return AspectRatio(
              aspectRatio: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Text(
                          'Weekly %',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 10),
                        styledDropdownButton()
                      ],
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      'Productive hours KW' + selectedKW,
                      style: TextStyle(
                        color: Colors.grey.withOpacity(0.5),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 38,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: BarChart(
                          mainBarData(weekValuesKW),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                  ],
                ),
              ),
            );
          });
    }

    return StreamBuilder<List<double>>(
        stream: calculateWeeklyProgressStream(productiveDailyGoal,
            "productive"), // Make sure this is your actual stream
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return AspectRatio(
              aspectRatio: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Text(
                          'Weekly %',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 10),
                        styledDropdownButton()
                      ],
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      'Productive hours KW' + getCurrentCalendarWeek(),
                      style: TextStyle(
                        color: Colors.grey.withOpacity(0.5),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 38,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: BarChart(
                          mainBarData(dummyWeekValues),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                  ],
                ),
              ),
            );
          }

          List<double> weekValues = snapshot.data!;
          return AspectRatio(
            aspectRatio: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      Text(
                        'Weekly %',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10),
                      styledDropdownButton()
                    ],
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    'Productive hours KW' + getCurrentCalendarWeek(),
                    style: TextStyle(
                      color: Colors.grey.withOpacity(0.5),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 38,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: BarChart(
                        mainBarData(weekValues),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                ],
              ),
            ),
          );
        });
  }

  BarChartData mainBarData(List<double> weekValues) {
    return BarChartData(
      maxY: 1,
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final percentage = (rod.toY * 100).toStringAsFixed(1) + '%';
            return BarTooltipItem(
              percentage,
              TextStyle(color: Colors.white),
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(weekValues),
    );
  }

  List<BarChartGroupData> showingGroups(List<double> weekValues) =>
      List.generate(7, (i) {
        return makeGroupData(i, weekValues.elementAt(i),
            isTouched: i == touchedIndex, barColor: barColor);
      });

  double ensureMinimumNonZero(double value, double minNonZero) {
    // If the value is not exactly 0 and less than the minimum non-zero, set it to minNonZero
    if (value != 0 && value < minNonZero) {
      return minNonZero;
    }
    // Otherwise, return the original value rounded to 1 decimal place
    return value;
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color? barColor,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: isTouched ? touchedBarColor : barColor ?? barColor,
          width: width,
          borderSide: isTouched
              ? BorderSide(color: touchedBarColor.withOpacity(0.8))
              : BorderSide.none,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 1,
            color: barBackgroundColor,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('M', style: style);
        break;
      case 1:
        text = const Text('T', style: style);
        break;
      case 2:
        text = const Text('W', style: style);
        break;
      case 3:
        text = const Text('T', style: style);
        break;
      case 4:
        text = const Text('F', style: style);
        break;
      case 5:
        text = const Text('S', style: style);
        break;
      case 6:
        text = const Text('S', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }

  Widget styledDropdownButton() {
    return DropdownButton<String>(
      value: selectedKW.isEmpty ? "Today" : "KW $selectedKW",
      icon: const Icon(Icons.arrow_downward, color: Colors.grey), // Icon color
      style: TextStyle(
        color: Colors.grey[700], // Text color
        fontWeight: FontWeight.bold,
      ),
      dropdownColor: Colors.white.withOpacity(0.8), // Dropdown background color
      underline: Container(
        height: 2,
        color: Colors.grey[400],
      ),
      onChanged: (String? newValue) {
        double previousOffset = scrollController.offset;
        if (newValue == "Today") {
          isPastShown = false;
          selectedKW = "";
        } else {
          isPastShown = true;
          selectedKW = newValue!.replaceFirst("KW ", "");
        }
        setState(() {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (scrollController.hasClients) {
              scrollController.jumpTo(previousOffset);
            }
          });
        });
      },
      items: ["Today", ...savedKWs.map((wk) => "KW $wk")]
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25), // Fully rounded corners
              color: Colors.white.withOpacity(0.5), // Translucent white
              border: Border.all(
                color: Colors.white
                    .withOpacity(0.2), // Light border for glass effect
                width: 1.5,
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[700], // Text color inside dropdown
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void handleButtonTap(String wichTime, String direction,
      {isHolding = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double productiveDailyGoal = prefs.getDouble('productiveDailyGoal') ?? 0.0;
    double freetimeDailyGoal = prefs.getDouble('freetimeDailyGoal') ?? 0.0;

    if (productiveDailyGoal == null || productiveDailyGoal < 0.0) {
      prefs.setDouble('productiveDailyGoal', 0.0);
    }
    if (freetimeDailyGoal == null || freetimeDailyGoal < 0.0) {
      prefs.setDouble('freetimeDailyGoal', 0.0);
    }

    double stepIncrement = isHolding ? 1.0 : 0.0833333;

    if (wichTime == "freetime") {
      if (direction == "plus") {
        freetimeDailyGoal += stepIncrement;
        if (freetimeDailyGoal > 13.0) {
          freetimeDailyGoal = 13.0;
        }
      } else {
        freetimeDailyGoal = _decrementValue(freetimeDailyGoal, stepIncrement);
      }
    } else {
      if (direction == "plus") {
        productiveDailyGoal += stepIncrement;
        if (productiveDailyGoal > 13.0) {
          productiveDailyGoal = 13.0;
        }
      } else {
        productiveDailyGoal =
            _decrementValue(productiveDailyGoal, stepIncrement);
      }
    }

    prefs.setDouble('productiveDailyGoal', productiveDailyGoal);
    prefs.setDouble('freetimeDailyGoal', freetimeDailyGoal);

    print('Button pressed! Some value from SharedPreferences:');
    print('productiveDailyGoal: $productiveDailyGoal');
    print('freetimeDailyGoal: $freetimeDailyGoal');

    loadSharedPreferences();
    setState(() {});
  }

  double _decrementValue(double value, double stepIncrement) {
    if (value > 0.0) {
      value -= stepIncrement;
      if (value < 0.0) {
        value = 0.0;
      }
    }
    return value;
  }

  Timer? _timer;

  Widget _averageTimeIcons(String timeType) {
    return Row(
      children: [
        GestureDetector(
            onTap: () => handleButtonTap(timeType, "minus"),
            onLongPress: () {
              _timer = Timer.periodic(Duration(milliseconds: 320), (timer) {
                handleButtonTap(timeType, "minus", isHolding: true);
              });
            },
            onLongPressUp: () {
              _timer!.cancel();
            },
            child: NeumorphicIcon(
              Icons.remove,
              size: 36,
              style: NeumorphicStyle(depth: 2, color: Colors.blue[300]),
            )),
        SizedBox(
          width: 20,
        ),
        GestureDetector(
            onTap: () => handleButtonTap(timeType, "plus"),
            onLongPress: () {
              _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
                handleButtonTap(timeType, "plus", isHolding: true);
              });
            },
            onLongPressUp: () {
              _timer!.cancel();
            },
            child: NeumorphicIcon(
              Icons.add,
              size: 36,
              style: NeumorphicStyle(depth: 2, color: Colors.blue[300]),
            )),
      ],
    );
  }

  @override
  @override
  bool get wantKeepAlive => true;
}

class SummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blueAccent, // Replace with the desired background color
        borderRadius: BorderRadius.circular(20), // Adjust for desired rounding
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSummaryItem(title: 'Total', value: '65h 13m'),
            VerticalDivider(color: Colors.white54, thickness: 1, width: 30),
            _buildSummaryItem(title: 'Avg', value: '6h 21m'),
            VerticalDivider(color: Colors.white54, thickness: 1, width: 30),
            _buildSummaryItem(title: 'Max', value: '8h 13m'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({required String title, required String value}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class GoalCard extends StatelessWidget {
  final String label;
  final double goalValue; // Maximum value for the progress bar
  final double progressValue; // Current progress
  final Widget timeIcons;

  const GoalCard({
    Key? key,
    required this.label,
    required this.goalValue,
    required this.progressValue,
    required this.timeIcons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate the width based on the screen width
    double cardWidth =
        MediaQuery.of(context).size.width * 0.9; // 90% of screen width

    return Center(
      // Center the card
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            width: cardWidth, // Use the calculated width
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey.shade900.withOpacity(0.2),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        formatHoursToNearestFive(goalValue),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    timeIcons,
                  ],
                ),
                SizedBox(height: 12),
                NeumorphicProgress(
                  percent: progressValue,
                  height: 20,
                  duration: Duration(seconds: 1),
                  style: ProgressStyle(
                    accent: Colors.blue.shade200,
                    depth: 8,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ImageUpgradeWidget extends StatefulWidget {
  @override
  _ImageUpgradeWidgetState createState() => _ImageUpgradeWidgetState();
}

class _ImageUpgradeWidgetState extends State<ImageUpgradeWidget> {
  // Initially, the first image is shown
  String currentImage = 'assets/campfire1.png';

  void _upgradeImage() {
    // On calling this function, we switch to the second image
    setState(() {
      currentImage = 'assets/campfire2.png';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize:
            MainAxisSize.min, // To keep the column size to fit its children
        children: <Widget>[
          Container(
            width: 300, // Fixed width as per your image width
            height: 290, // Fixed height as per your image height
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(currentImage),
                fit: BoxFit
                    .contain, // This ensures the image fits within the container without changing aspect ratio
              ),
            ),
          ),
          SizedBox(
              height:
                  20), // Provide some spacing between the image and the button
          ElevatedButton(
            onPressed: _upgradeImage,
            child: Text('Upgrade'),
          ),
        ],
      ),
    );
  }
}
