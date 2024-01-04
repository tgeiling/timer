import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:neumorphic_ui/neumorphic_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
double productiveProgress = 0.0;
double freeTimeProgress = 0.0;

List<double> lastKnownWeekValues = List.generate(7, (index) => 0.0);

List<String> daysOfWeek = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'So'];
List<double> weekValues = [];

Future<double> getAverageProductiveHours() async {
  // Your implementation to calculate and return the average productive hours
  // This is a placeholder implementation.
  // Replace it with your actual logic to calculate the average
  double average = await calculateAverageProductiveHours();
  return average;
}

Future<double> getAverageFreeTimeHours() async {
  // Your implementation to calculate and return the average productive hours
  // This is a placeholder implementation.
  // Replace it with your actual logic to calculate the average
  double average = await calculateAverageFreeTimeHours();
  return average;
}

class _StatsState extends State<Stats> with AutomaticKeepAliveClientMixin {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    loadSharedPreferences();
    timer = Timer.periodic(
        Duration(seconds: 5), (Timer t) => loadSharedPreferences());
  }

  Future<void> loadSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double loadedProductiveDailyGoal =
        await prefs.getDouble('productiveDailyGoal') ??
            widget.productiveDailyGoal;
    double loadedFreetimeDailyGoal =
        await prefs.getDouble('freetimeDailyGoal') ?? widget.freetimeDailyGoal;

    double loadedAverageProductiveHours =
        await calculateAverageProductiveHours();
    double loadedAverageFreeTimeHours = await calculateAverageFreeTimeHours();
    productiveDailyGoal = loadedProductiveDailyGoal;
    freetimeDailyGoal = loadedFreetimeDailyGoal;

    double loadedProductiveProgress =
        (loadedAverageProductiveHours / productiveDailyGoal).clamp(0.0, 1.0);
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
        child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWeeklyProgress(),
          SizedBox(height: 20),
          //#########
          Transform.translate(
              offset: Offset(0, -70),
              child: Neumorphic(
                  padding: EdgeInsets.all(12),
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.concave,
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                    depth: 8,
                    lightSource: LightSource.topLeft,
                  ),
                  child: Column(children: [
                    //productive
                    Transform.translate(
                      offset: Offset(-68, -2),
                      child: hoursText(
                          averageHours: averageProductiveHours,
                          wantedHours: productiveDailyGoal,
                          label: "productive"),
                    ),
                    _averageTimeIcons("productive", 250, -48),
                    SizedBox(
                      height: 0,
                    ),
                    Transform.translate(
                        offset: Offset(0, -20),
                        child: NeumorphicProgress(
                          percent: productiveProgress,
                          height: 20,
                          duration: Duration(seconds: 1),
                          style: ProgressStyle(
                            accent: Colors.blue,
                            depth: 8,
                          ),
                        )),
                    //Freetime
                    Transform.translate(
                      offset: Offset(-75, 16),
                      child: hoursText(
                          averageHours: averageFreeTimeHours,
                          wantedHours: freetimeDailyGoal,
                          label: "free time"),
                    ),
                    _averageTimeIcons("freetime", 250, -24),
                    SizedBox(
                      height: 0,
                    ),
                    NeumorphicProgress(
                      percent: freeTimeProgress,
                      height: 20,
                      duration: Duration(seconds: 1),
                      style: ProgressStyle(
                        accent: Colors.blue,
                        depth: 8,
                      ),
                    ),
                  ]))),
        ],
      ),
    ));
  }

  Widget _buildWeeklyProgress() {
    weekValues = widget.weekValues;

    return StreamBuilder<List<double>>(
        stream:
            calculateWeeklyProgressStream(productiveDailyGoal, "productive"),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              children: [
                Transform.translate(
                  offset: Offset(-35, 60),
                  child: Text(
                    'Weekly productive progress',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700]),
                  ),
                ),
                SizedBox(height: 50),
                Transform.translate(
                    offset: Offset(0, -120),
                    child: Transform.rotate(
                      angle: -90 * (pi / 180),
                      child: Column(
                        children: List.generate(7, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Transform.rotate(
                                    angle: 90 * (pi / 180),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        width: 30,
                                        child: Text(daysOfWeek[index]),
                                      ),
                                    )),
                                Container(
                                  width: 160,
                                  child: NeumorphicProgress(
                                    percent: lastKnownWeekValues[index],
                                    height: 20,
                                    duration: Duration(seconds: 1),
                                    style: ProgressStyle(
                                      accent: Colors.blue,
                                      depth: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    )),
              ],
            );
          }

          if (!snapshot.hasData) {
            return Text("No data available"); // Show an error or empty state
          }

          List<double> weekValues = snapshot.data!;

          lastKnownWeekValues = weekValues;

          return Column(
            children: [
              Transform.translate(
                offset: Offset(-35, 60),
                child: Text(
                  'Weekly productive progress',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700]),
                ),
              ),
              SizedBox(height: 50),
              Transform.translate(
                  offset: Offset(0, -120),
                  child: Transform.rotate(
                    angle: -90 * (pi / 180),
                    child: Column(
                      children: List.generate(7, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Transform.rotate(
                                  angle: 90 * (pi / 180),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: 30,
                                      child: Text(daysOfWeek[index]),
                                    ),
                                  )),
                              Container(
                                width: 160,
                                child: NeumorphicProgress(
                                  percent: weekValues[index],
                                  height: 20,
                                  duration: Duration(seconds: 1),
                                  style: ProgressStyle(
                                    accent: Colors.blue,
                                    depth: 8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  )),
            ],
          );
        });
  }

  void handleButtonTap(String wichTime, String direction,
      {bool isHolding = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double productiveDailyGoal = prefs.getDouble('productiveDailyGoal') ?? 0.0;
    double freetimeDailyGoal = prefs.getDouble('freetimeDailyGoal') ?? 0.0;

    if (productiveDailyGoal == null || productiveDailyGoal < 0.0) {
      prefs.setDouble('productiveDailyGoal', 0.0);
    }
    if (freetimeDailyGoal == null || freetimeDailyGoal < 0.0) {
      prefs.setDouble('freetimeDailyGoal', 0.0);
    }

    double stepIncrement = isHolding ? 1.0 : 0.1;

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

  Widget _averageTimeIcons(String timeType, double left, double top) {
    return Transform.translate(
        offset: Offset(left, top),
        child: Row(
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
                  style: NeumorphicStyle(depth: 2, color: Colors.blue[500]),
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
                  style: NeumorphicStyle(depth: 2, color: Colors.blue[500]),
                )),
          ],
        ));
  }

  Widget _buildGitCalendar() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
        ),
        itemCount: 30, // You can change the number of tiles as needed
        itemBuilder: (context, index) {
          // Randomly choose the color for demonstration
          Color tileColor =
              Random().nextInt(2) == 0 ? Colors.grey : Colors.green;

          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: SizedBox(
              width: 16,
              height: 16,
              child: Neumorphic(
                padding: EdgeInsets.all(8),
                style: NeumorphicStyle(
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
                  depth: 8,
                  color: tileColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  @override
  bool get wantKeepAlive => true;
}

class hoursText extends StatefulWidget {
  final double averageHours;
  final double wantedHours;
  final String label;

  hoursText({
    required this.averageHours,
    required this.wantedHours,
    required this.label,
  });

  @override
  _hoursTextState createState() => _hoursTextState();
}

class _hoursTextState extends State<hoursText>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() async {
    Timer.periodic(Duration(seconds: 10), (_) async {
      double loadedAverageProductiveHours =
          await calculateAverageProductiveHours();
      double loadedAverageFreeTimeHours = await calculateAverageFreeTimeHours();
      print(averageProductiveHours);
      print(averageFreeTimeHours);
      setState(() {
        averageProductiveHours = loadedAverageProductiveHours;
        averageFreeTimeHours = loadedAverageFreeTimeHours;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Average ' + widget.label + ' hours\n',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        Transform.translate(
          offset: Offset(-0, -10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${widget.averageHours.toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '           Daily goal: ${widget.wantedHours.toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  @override
  bool get wantKeepAlive => true;
}
