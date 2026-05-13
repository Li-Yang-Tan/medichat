import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medichat/Add/Add.dart';
import 'package:medichat/Diary/Water.dart';
import 'package:medichat/Diary/Weight.dart';
import 'package:medichat/Diary/components/app_resources.dart';
import 'package:medichat/Edit/Edit_Meal.dart';
import 'package:medichat/Edit/Edit_Workout.dart';
import 'package:medichat/components/connection.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class DiaryScreen extends StatefulWidget {
  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> with SingleTickerProviderStateMixin {
  final String? uid = ConnectionService.getUID();

  DateTime today = DateTime.now();
  DateFormat sdf = DateFormat('yyyy-MM-dd');

  bool isLoading = true;

  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<Color> gradientColors = [
    AppColors.contentColorBlue,
    AppColors.contentColorGreen,
  ];

  double screenHeight = 0;
  double screenWidth = 0;

  bool startAnimation = false;

  List<Map<String, dynamic>> breakfastList = [];
  List<Map<String, dynamic>> lunchList = [];
  List<Map<String, dynamic>> dinnerList = [];
  List<Map<String, dynamic>> workoutList = [];

  int? targetWater;
  int? totalWater;

  int? targetCalorie;
  int? totalCalorie;

  double targetWeight = 0;

  final List<FlSpot> spots = [];
  final List<DateTime> dates = [];
  late Future<ChartData> _chartDataFuture;

  bool isnAdd = true;
  late Animation<double> containerSize;
  AnimationController? animationController;
  Duration animationDuration = Duration(milliseconds: 270);

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(vsync: this, duration: animationDuration);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        startAnimation = true;
        ConnectionService.checkSession(context);
      });
    });

    _chartDataFuture = _fetchChartData();
    _getWaterData();
    _getCalorieData();
    _getListViewData();
  }

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    Size size = MediaQuery.of(context).size;

    double defaultRegisterSize = size.height - (size.height * 0.6); // Fully expanded container height

    // Set up the animation for expanding and collapsing the container
    containerSize = Tween<double>(begin: 0, end: defaultRegisterSize)
        .animate(CurvedAnimation(parent: animationController!, curve: Curves.linear));

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isnAdd) {
            // Forward animation: Expand the container
            animationController!.forward();
          } else {
            // Reverse animation: Collapse the container
            animationController!.reverse();
          }

          setState(() {
            isnAdd = !isnAdd;
          });
        },
        backgroundColor: Color.fromARGB(255, 194, 255, 199),
        child: Icon(
          isnAdd ? Icons.add : Icons.close,
        ),
      ),
      backgroundColor: Color.fromARGB(255, 251, 246, 233),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 133, 169, 143),
        title: Row(
          children: [
            // First part: Icon
            Expanded(
              flex: 1,  // Takes up 1/5 of the space
              child: IconButton(
                icon: Icon(
                  Icons.arrow_circle_left_outlined,
                  size: 50,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    today = today.subtract(Duration(days: 1));
                  });
                  _getWaterData();
                  _getCalorieData();
                  _getListViewData();
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                sdf.format(today),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_circle_right_outlined,
                  size: 50,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    today = today.add(Duration(days: 1));
                  });
                  _getWaterData();
                  _getCalorieData();
                  _getListViewData();
                },
              ),
            ),
          ],
        ),
        centerTitle: false, // This ensures the title doesn't automatically center
      ),
      body: Stack(
          children: [
          buildDiaryContainer(),

          AnimatedBuilder(
            animation: animationController!,
            builder: (context, child) {
              return Stack(
                children: [
                  buildAddContainer(), // Animated expansion of the container
                    AddForm(
                      isLogin: isnAdd,
                      animationDuration: Duration(milliseconds: 200),
                      size: size,
                      defaultAddSize: defaultRegisterSize,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  //get water data from firebase
  Future<void> _getWaterData() async {
    final data = await WaterService.fetchWaterData(uid!, sdf.format(today));

    if (data == null) {
      setState(() {
        targetWater = 0;
        totalWater = 0;
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Unable to fetch water data")),
      );
    } else {
      // Assuming `data` contains target and consumed water information
      setState(() {
        targetWater = data['target'];  // Example
        totalWater = data['consumed'];  // Example
        isLoading = false;
      });
    }
  }

  //get calorie data from firebase
  Future<void> _getCalorieData() async {
    final data = await CalorieService.fetchCalorieData(uid!, sdf.format(today));

    if (data == null) {
      setState(() {
        targetCalorie = 0;
        totalCalorie = 0;
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Unable to fetch water data")),
      );
    } else {
      // Assuming `data` contains target and consumed water information
      setState(() {
        targetCalorie = data['target'];  // Example
        totalCalorie = data['consumed'];  // Example
        isLoading = false;
      });
    }
  }

  Future<void> _getListViewData() async {
    final breakfast = await ListViewService.fetchMealData(uid!, sdf.format(today), "Breakfast");
    final lunch = await ListViewService.fetchMealData(uid!, sdf.format(today), "Lunch");
    final dinner = await ListViewService.fetchMealData(uid!, sdf.format(today), "Dinner");
    final workout = await ListViewService.fetchWorkoutData(uid!, sdf.format(today));


    setState(() {
      // Ensure the meal data is treated as a list, even if it's a single entry
      breakfastList = breakfast ?? [];
      lunchList = lunch ?? [];
      dinnerList = dinner ?? [];
      workoutList = workout ?? [];
      isLoading = false;
    });

    if (breakfast == null && lunch == null && dinner == null && workout == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Unable to fetch meal data")),
      );
    }
  }

  Future<ChartData> _fetchChartData() async {
    const MethodChannel _channel = MethodChannel('Weight');
    // Fetch data from the native side.
    final Map<dynamic, dynamic> data =
    await _channel.invokeMethod('fetchWeightData', {
      'userId': uid,
    });

    final Map<dynamic, dynamic> target =
    await _channel.invokeMethod('fetchTargetWeight', {
      'userId': uid,
    });

    // Parse the data into lists.
    final List<String> dateStrings = List<String>.from(data['dates']);
    final List<double> weights = List<double>.from(data['weights']);
    targetWeight = target['weight'];

    // Build the lists for the chart.
    final List<FlSpot> spots = [];
    final List<DateTime> dates = [];

    // We use the index as the x value.
    for (int i = 0; i < weights.length; i++) {
      spots.add(FlSpot(i.toDouble(), weights[i]));
      // Parse the date string into a DateTime.
      dates.add(DateTime.parse(dateStrings[i]));
    }

    return ChartData(spots: spots, dates: dates);
  }

  Widget buildAddContainer() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        height: containerSize.value,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(100),
              topRight: Radius.circular(100),
            ),
            color: Color.fromARGB(255, 133, 169, 143),
        ),
      ),
    );
  }

  Widget buildDiaryContainer() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
              child: Row(
                children: [
                  Text(
                    'Weight',
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(width: 15),
                  Baseline(
                    baseline: 20, // Adjust the baseline offset as needed
                    baselineType: TextBaseline.alphabetic,
                    child: Text(
                      'Target: $targetWeight kg',
                      style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 17,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ],
              )
          ),

          Stack(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeightScreen(), // Navigate to the WaterScreen
                    ),
                  );
                },
                child: AspectRatio(
                  aspectRatio: 1.70,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 15,
                      left: 0,
                      top: 0,
                      bottom: 0,
                    ),
                    child: FutureBuilder<ChartData>(
                      future: _chartDataFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final chartData = snapshot.data!;
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: LineChart(
                            mainData(chartData.spots, chartData.dates, targetWeight),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            height: 230,
            child: PageView.builder(
              controller: _pageController,
              itemCount: 2,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                String label;
                double progress;

                // Define the label and progress based on the index
                switch (index) {
                  case 0:
                    label = "Water";
                    progress = (totalWater ?? 0) / (targetWater ?? 1);
                    break;
                  case 1:
                    label = "Calories";
                    progress = (totalCalorie ?? 0) / (targetCalorie ?? 1);
                    break;
                  default:
                    label = "Unknown";
                    progress = 0.0;
                }

                return _buildProgressIndicator(label, progress);
              },
            ),
          ),

          SizedBox(
            height: 15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                2,
                    (index) => AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  width: _currentPage == index ? 12 : 8,
                  height: _currentPage == index ? 12 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          buildMealSection("Breakfast", breakfastList),
          buildMealSection("Lunch", lunchList),
          buildMealSection("Dinner", dinnerList),
          buildWorkoutSection("Workout", workoutList),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(String label, double percent) {
    String unit;
    int amount, target;

    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    // Set values based on the label.
    if (label == "Calories") {
      unit = "kcal";
      amount = totalCalorie!;
      target = targetCalorie!;
    } else {
      unit = "ml";
      amount = totalWater!;
      target = targetWater!;
    }

    // Ensure percent doesn't exceed 100%
    percent = percent.clamp(0.0, 1.0);

    // Set the progress bar color based on the label.
    final Color progressColor;
    if (label == "Calories") {
      progressColor = Color.fromARGB(255, 243, 156, 18); // Use your preferred color for Calories.
    } else if (label == "Water") {
      progressColor = Color.fromARGB(255, 52, 152, 219); // Use your preferred color for Water.
    } else {
      progressColor = Color.fromARGB(255, 93, 185, 150); // Fallback color.
    }

    return GestureDetector(
      onTap: () {
        if (label == "Water") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WaterScreen(),
              settings: RouteSettings(
                arguments: {
                  'date': sdf.format(today),
                },
              ),
            ),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              // Left side: Progress bar (CircularPercentIndicator)
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label,
                        style:
                        TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                    SizedBox(height: 14),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: percent),
                      duration: Duration(seconds: 1),
                      builder: (context, value, child) {
                        return CircularPercentIndicator(
                          radius: 60,
                          lineWidth: 8,
                          percent: value,
                          center: Text(
                            "${(value * 100).toInt()}%",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24),
                          ),
                          progressColor: progressColor, // Use dynamic color here.
                          backgroundColor: Colors.green.shade50,
                          circularStrokeCap: CircularStrokeCap.round,
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 35),
                    Text("Current Amount ($unit):",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("$amount $unit",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 15),
                    Text("Target Amount ($unit):",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("$target $unit",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double calculateXInterval(int length) {
    // Calculate the interval for 7 labels (including min and max), which means 6 intervals
    if (length >= 30) {
      return (length / 5).floorToDouble(); // 6 intervals for 7 labels (including min and max)
    }

    // For fewer records, show a reasonable number of labels
    if (length <= 5) return 1;
    if (length <= 10) return 1;
    if (length <= 20) return 2;
    return 3;  // For between 20 and 30 records, show 7 labels (including min and max)
  }

  double calculateYInterval(double minY, double maxY) {
    double range = maxY - minY;

    // Calculate the interval for 6 labels (including min and max)
    double interval = (range / 5).floorToDouble();

    // Ensure no interval smaller than 1
    if (interval < 1) {
      return 1;
    }

    return interval;
  }

  LineChartData mainData(List<FlSpot> spots, List<DateTime> dates, double targetY) {
    // Set x-axis range based on the number of records.
    final double minX = 0.0;
    final double maxX = (spots.length - 1).toDouble();

    // Compute y-axis bounds dynamically with padding
    final double minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 10;
    final double maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 10;

    // Calculate intervals for both axes
    double xInterval = calculateXInterval(spots.length);
    double yInterval = calculateYInterval(minY, maxY);

    return LineChartData(
      gridData: FlGridData(show: false), // Removes grid lines
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: xInterval,  // Use adjusted X interval
            getTitlesWidget: (value, meta) => bottomTitleWidgets(value, meta, dates, minX, maxX),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 42,
            interval: yInterval,  // Use adjusted Y interval
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 210, 180, 140),
              Color.fromARGB(255, 244, 164, 96),
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
        ),
      ],
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          HorizontalLine(
            y: targetY,
            color: Color.fromARGB(255, 99, 140, 109), // Line color
            strokeWidth: 2, // Line thickness
            dashArray: [8, 4], // Optional: creates a dashed line
          ),
        ],
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta, List<DateTime> dates, double minX, double maxX) {
    const TextStyle style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );

    final int index = value.toInt();
    String text = '';

    // Include the min and max labels in the evenly distributed interval
    if (index >= 0 && index < dates.length) {
      text = DateFormat('MM/dd').format(dates[index]);
    }

    return Transform.translate(
      offset: const Offset(0, 10), // Adjust positioning if needed
      child: Text(text, style: style, textAlign: TextAlign.center),
    );
  }

  Widget buildMealSection(String title, List<Map<String, dynamic>> meals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Text(
            title,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        meals.isEmpty
            ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text("No meals recorded", style: TextStyle(color: Colors.grey[600])),
        )
            : ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(), // Prevents scroll conflicts
          itemCount: meals.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                String mealTitle = meals[index]['mealTitle'];
                double calorie = meals[index]['calory'];
                String description = meals[index]['description'];

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditMealScreen(),
                    settings: RouteSettings(
                      arguments: {
                        'date': sdf.format(today),
                        'title': title,
                        'mealTitle': mealTitle,
                        'description': description,
                        'calorie': calorie,
                      },
                    ),
                  ),
                );
              },
              onLongPress: () {
                showDeleteDialog(context, title, meals[index]['mealTitle'], index);
              },
              child: item(meals[index]),
            );
          },
        ),
      ],
    );
  }

  Widget buildWorkoutSection(String title, List<Map<String, dynamic>> meals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Text(
            title,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        meals.isEmpty
            ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text("No Workout recorded", style: TextStyle(color: Colors.grey[600])),
        )
            : ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(), // Prevents scroll conflicts
          itemCount: meals.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                String exerciseTitle = meals[index]['mealTitle'];
                double calorie = meals[index]['calory'];
                String duration = meals[index]['description'];

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditWorkoutScreen(),
                    settings: RouteSettings(
                      arguments: {
                        'date': sdf.format(today),
                        'title': title,
                        'exerciseTitle': exerciseTitle,
                        'duration': duration,
                        'calorie': calorie,
                      },
                    ),
                  ),
                );
              },
              onLongPress: () {
                // Handle long press here
                showDeleteDialog(context, title, meals[index]['mealTitle'], index);
              },
              child: item(meals[index]),
            );
          },
        ),
      ],
    );
  }

  Widget item(Map<String, dynamic> mealData) {
    return Container(
      height: 75,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  mealData["mealTitle"] ?? "Unknown Meal",  // Corrected the key to "mealTitle"
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                SizedBox(height: 4),
                Text(
                  mealData["description"] ?? "No description available",  // Corrected the key to "description"
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "${mealData["calory"] ?? 0} kcal",  // Corrected the key to "calory"
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showDeleteDialog(BuildContext context, String list, String title, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Rounded corners
          ),
          title: Text('Confirmation'),
          content: Text('Are you sure you want to delete this record?'),
          actions: <Widget>[
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            // Confirm Button
            TextButton(
              onPressed: () {
                _delete(list, title, index);
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _delete(String indicator, String title, int index) async {
    MethodChannel platform = MethodChannel('Delete');
    try {
      final String result = await platform.invokeMethod('Delete', {
        "userId": uid,
        "date": sdf.format(today),
        "indicator": indicator,
        "title": title,
      });

      Navigator.pop(context);
      await Future.delayed(Duration(milliseconds: 500));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Record Deleted Successfully"),
          duration: Duration(seconds: 1), // Set the duration to 1 second
        ),
      );

      setState(() {
        // Remove the item from the correct list
        switch (indicator) {
          case "Breakfast":
            breakfastList.removeAt(index);
            break;
          case "Lunch":
            lunchList.removeAt(index);
            break;
          case "Dinner":
            dinnerList.removeAt(index);
            break;
          case "Workout":
            workoutList.removeAt(index);
            break;
        }
      });

    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${e.message}")));
    }
  }
}

class WaterService {
  static const MethodChannel _channel = MethodChannel('Water');

  // Fetch water consumption data from native Android code
  static Future<Map<String, dynamic>?> fetchWaterData(String userId, String date) async {
    try {
      final result = await _channel.invokeMethod('fetchWaterData', {
        'userId': userId,
        'date': date,
      });

      // Ensure the result is a Map and cast it properly
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      } else {
        print("Unexpected result type: ${result.runtimeType}");
        return null;
      }
    } on PlatformException catch (e) {
      print("Error fetching water data: ${e.message}");
      return null;
    }
  }
}

class CalorieService {
  static const MethodChannel _channel = MethodChannel('Calorie');

  // Method to fetch calorie data
  static Future<Map<String, dynamic>?> fetchCalorieData(String userId, String date) async {
    try {
      final result = await _channel.invokeMethod('fetchCalorieData', {
        'userId': userId,
        'date': date,
      });

      // Ensure the result is a Map and cast it properly
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      } else {
        print("Unexpected result type: ${result.runtimeType}");
        return null;
      }
    } on PlatformException catch (e) {
      print("Error fetching water data: ${e.message}");
      return null;
    }
  }
}

class ListViewService {
  static const MethodChannel _channel = MethodChannel('ListView');

  // Method to fetch meal data
  static Future<List<Map<String, dynamic>>?> fetchMealData(String userId, String date, String meal) async {
    try {
      final result = await _channel.invokeMethod('fetchMealData', {
        'userId': userId,
        'date': date,
        'meal': meal,
      });

      // Ensure the result is a List and cast it properly
      if (result is List) {
        return result.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        print("Unexpected result type: \${result.runtimeType}");
        return null;
      }
    } on PlatformException {
      print("Error fetching meal data: \${e.message}");
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>?> fetchWorkoutData(String userId, String date) async {
    try {
      final result = await _channel.invokeMethod('fetchWorkoutData', {
        'userId': userId,
        'date': date,
      });

      // Ensure the result is a List and cast it properly
      if (result is List) {
        return result.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        print("Unexpected result type: \${result.runtimeType}");
        return null;
      }
    } on PlatformException {
      print("Error fetching meal data: \${e.message}");
      return null;
    }
  }
}

class ChartData {
  final List<FlSpot> spots;
  final List<DateTime> dates;

  ChartData({required this.spots, required this.dates});
}



