import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medichat/Add/Add_Preset.dart';
import 'package:medichat/components/connection.dart';
import 'package:medichat/global_nav_bar.dart';
import 'package:intl/intl.dart';

class PresetScreen extends StatefulWidget {
  @override
  State<PresetScreen> createState() => _PresetScreenState();
}

class _PresetScreenState extends State<PresetScreen> {
  final String? uid = ConnectionService.getUID();
  List<Map<String, dynamic>> presetList = [];
  bool isLoading = true;

  DateTime today = DateTime.now();
  DateFormat sdf = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _getPresetData();
  }

  /// Fetch the preset data using a method channel.
  Future<void> _getPresetData() async {
    if (uid == null) return;
    final preset = await PresetService.fetchPresetData(uid!);
    if (preset != null) {
      setState(() {
        presetList = preset;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Unable to fetch preset data")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 251, 246, 233),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 251, 246, 233),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 40),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => GlobalNavBar()),
                (route) => false, // This removes all previous routes
          ),
        ),
        title: const Text(
          "Preset Records",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 35, color: Colors.black87,),
            onPressed: () {
              // Navigate to your add preset screen or perform the add action
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddPresetScreen()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : presetList.isEmpty
          ? const Center(child: Text("No preset records found."))
          : ListView.builder(
        itemCount: presetList.length,
        itemBuilder: (context, index) {
          final preset = presetList[index];
          return GestureDetector(
            onTap: () {
              _AddMeal(preset);
            },
            onLongPress: (){
              showDeleteDialog(context, preset['mealName'], index);
            },
            child: _buildPresetItem(preset),
          );
        },
      ),
    );
  }

  Widget _buildPresetItem(Map<String, dynamic> preset) {
    return Container(
      // Increased height to comfortably show three text lines.
      height: 110,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Expanded section for the text details.
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meal name
                Text(
                  preset['mealName'] ?? 'No Meal Name',
                  style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Meal: ${preset['Meal'] ?? 'N/A'}",
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                // Description
                Text(
                  preset['Description'] ?? '',
                  style: TextStyle(fontSize: 17, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                // Meal type (e.g., Breakfast, Lunch, Dinner)
              ],
            ),
          ),
          // Expanded section for the calorie info.
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                preset['Calorie'] != null ? "${preset['Calorie']} cal" : "",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _AddMeal(Map<String, dynamic> preset) async {
    MethodChannel platform = MethodChannel('AddMeal');
    try {
      final String result = await platform.invokeMethod('AddMeal', {
        "userId": uid,
        "meal": preset['Meal'] ?? '',
        "date": sdf.format(today),
        "food": preset['mealName'] ?? '',
        "descr": preset['Description'] ?? '',
        "calorie": (preset['Calorie'] ?? 0).toDouble(),
        "carb": (preset['Nutrients']?['Carbohydrates'] ?? 0).toDouble(),
        "protein": (preset['Nutrients']?['Protein'] ?? 0).toDouble(),
        "fat": (preset['Nutrients']?['Fat'] ?? 0).toDouble(),
        "sfat": (preset['Nutrients']?['Saturated Fat'] ?? 0).toDouble(),
        "fiber": (preset['Nutrients']?['Fiber'] ?? 0).toDouble(),
        "sugar": (preset['Nutrients']?['Sugar'] ?? 0).toDouble(),
        "sodium": (preset['Nutrients']?['Sodium'] ?? 0).toDouble(),
        "cholesterol": (preset['Nutrients']?['Cholesterol'] ?? 0).toDouble()
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Record Added Successfully"),
          duration: Duration(seconds: 1),
        ),
      );
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${e.message}")));
    }
  }

  void showDeleteDialog(BuildContext context, String title, int index) {
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
                _delete(title, index);
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _delete(String title, int index) async {
    MethodChannel platform = MethodChannel('Delete');
    try {
      final String result = await platform.invokeMethod('Delete', {
        "userId": uid,
        "date": "date",
        "indicator": "Preset",
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
        presetList.removeAt(index);
      });

    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${e.message}")));
    }
  }
}

class PresetService {
  static const MethodChannel _channel = MethodChannel('ListView');

  static Future<List<Map<String, dynamic>>?> fetchPresetData(String userId) async {
    try {
      final result = await _channel.invokeMethod('fetchPresetData', {
        'userId': userId,
      });
      if (result is List) {
        return result.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return null;
    } on PlatformException catch (e) {
      print("Error fetching preset data: ${e.message}");
      return null;
    }
  }
}
