import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medichat/Edit/Edit_Water.dart';
import 'package:medichat/Edit/Edit_Weight.dart';
import 'package:medichat/components/connection.dart';

class WeightScreen extends StatefulWidget {
  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> with SingleTickerProviderStateMixin {
  final String? uid = ConnectionService.getUID();
  List<Map<String, dynamic>> weightList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getListViewData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 251, 246, 233),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 251, 246, 233),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.chevron_left),
          iconSize: 40,
        ),
        title: Text(
          "Weight Record",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
      ),
      body: buildWeightSection("Weight", weightList),
    );
  }

  Future<void> _getListViewData() async {
    if (uid == null) return;
    final weight = await ListViewService.fetchWeightData(uid!);

    if (weight != null) {
      setState(() {
        weightList = weight;
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Unable to fetch weight data")),
      );
    }
  }

  Widget buildWeightSection(String title, List<Map<String, dynamic>> record) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        record.isEmpty
            ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text("No weight record for this date.", style: TextStyle(color: Colors.grey[600])),
        )
            : Expanded(
          child: ListView.builder(
            itemCount: record.length,
            itemBuilder: (context, index) {
              // Reverse the list by accessing the element from the end
              var reversedIndex = record.length - 1 - index;
              return GestureDetector(
                onTap: () {
                  String date = record[reversedIndex]['date'];
                  double weight = record[reversedIndex]['weight'];

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditWeightScreen(),
                      settings: RouteSettings(
                        arguments: {
                          'date': date,
                          'weight': weight,
                        },
                      ),
                    ),
                  );
                },
                onLongPress: () {
                  String date = record[reversedIndex]['date'];
                  showDeleteDialog(context, date, reversedIndex);
                },
                child: item(record[reversedIndex]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget item(Map<String, dynamic> weightData) {
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
                  weightData["date"] ?? "No date available",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "${weightData["weight"] ?? 0} kg",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showDeleteDialog(BuildContext context, String list, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Confirmation'),
          content: Text('Are you sure you want to delete this record?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _delete(list, index);
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _delete(String date, int index) async {
    if (uid == null) return;
    MethodChannel platform = MethodChannel('Delete');
    try {
      await platform.invokeMethod('Delete', {
        "userId": uid,
        "date": date,
        "indicator": "Weight",
      });

      setState(() {
        weightList.removeAt(index);
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Record Deleted Successfully"), duration: Duration(seconds: 1)),
      );
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.message}")),
      );
    }
  }
}

class ListViewService {
  static const MethodChannel _channel = MethodChannel('ListView');

  static Future<List<Map<String, dynamic>>?> fetchWeightData(String userId) async {
    try {
      final result = await _channel.invokeMethod('fetchWeightData', {
        'userId': userId,
      });
      if (result is List) {
        return result.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return null;
    } on PlatformException catch (e) {
      print("Error fetching water data: ${e.message}");
      return null;
    }
  }
}
