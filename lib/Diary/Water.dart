import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medichat/Edit/Edit_Water.dart';
import 'package:medichat/components/connection.dart';

class WaterScreen extends StatefulWidget {
  @override
  State<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends State<WaterScreen> with SingleTickerProviderStateMixin {
  final String? uid = ConnectionService.getUID();
  String dateD = "";
  String timeD = "";
  List<Map<String, dynamic>> waterList = [];
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
    dateD = arguments['date'] ?? "";
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
          "Water Record",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
      ),
      body: buildWaterSection("Water", waterList),
    );
  }

  Future<void> _getListViewData() async {
    if (uid == null || dateD.isEmpty) return;
    final water = await ListViewService.fetchWaterData(uid!, dateD);

    if (water != null) {
      setState(() {
        waterList = water;
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Unable to fetch water data")),
      );
    }
  }

  Widget buildWaterSection(String title, List<Map<String, dynamic>> record) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        record.isEmpty
            ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text("No water record for this date.", style: TextStyle(color: Colors.grey[600])),
        )
            : Expanded(
          child: ListView.builder(
            itemCount: record.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  String date = dateD;
                  double amount = record[index]['amount'];
                  String time = record[index]['time'];

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditWaterScreen(),
                      settings: RouteSettings(
                        arguments: {
                          'date': date,
                          'time': time,
                          'amount': amount,
                        },
                      ),
                    ),
                  );
                },
                onLongPress: () {
                  timeD = record[index]['time'];
                  showDeleteDialog(context, timeD, index);
                },
                child: item(record[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget item(Map<String, dynamic> waterData) {
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
                  dateD,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                SizedBox(height: 4),
                Text(
                  waterData["time"] ?? "No time available",
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
                "${waterData["amount"] ?? 0} ml",
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

  Future<void> _delete(String time, int index) async {
    if (uid == null) return;
    MethodChannel platform = MethodChannel('Delete');
    try {
      await platform.invokeMethod('Delete', {
        "userId": uid,
        "date": dateD,
        "title": time,
        "indicator": "Water",
      });

      setState(() {
        waterList.removeAt(index);
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

  static Future<List<Map<String, dynamic>>?> fetchWaterData(String userId, String date) async {
    try {
      final result = await _channel.invokeMethod('fetchWaterData', {
        'userId': userId,
        'date': date,
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
