import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medichat/Add/Preset.dart';
import 'package:medichat/Edit/Edit_Nutrients.dart';
import 'package:medichat/Login/constants.dart';
import 'package:medichat/components/Rounded_numeric_input.dart';
import 'package:medichat/components/connection.dart';
import 'package:medichat/components/input_container.dart';
import 'package:medichat/components/rounded_button.dart';
import 'package:medichat/components/rounded_input.dart';
import 'package:medichat/global_nav_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddPresetScreen extends StatefulWidget {
  @override
  State<AddPresetScreen> createState() => _SetAddMealScreenState();
}

class _SetAddMealScreenState extends State<AddPresetScreen> {
  final String? uid = ConnectionService.getUID();
  bool _isAnalyzing = false;
  bool _isCompleted = false;

  String? selectedMeal;
  TextEditingController date = TextEditingController();
  TextEditingController food = TextEditingController();
  TextEditingController descr = TextEditingController();
  TextEditingController calorie = TextEditingController();

  String mealTitle = "";
  String descrE = "";
  double calorieE = 0;
  String oldRecord = "";
  double carb = 0;
  double protein = 0;
  double fat = 0;
  double sfat = 0;
  double fiber = 0;
  double sugar = 0;
  double sodium = 0;
  double cholesterol = 0;

  MethodChannel platform = MethodChannel('AddPreset');

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
    if (arguments.isNotEmpty) {
      mealTitle = arguments['mealTitle'];
      descrE = arguments['description'];
      calorieE = arguments['calorie'];
    }

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
          "Add Meal Record",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildMealRadioButton('Breakfast'),
                        _buildMealRadioButton('Lunch'),
                        _buildMealRadioButton('Dinner'),
                      ],
                    ),
                    SizedBox(height: 20),
                    RoundedInput(
                      controller: food,
                      icon: Icons.set_meal_outlined,
                      hint: "Enter Food:",
                    ),
                    RoundedInput(
                      controller: descr,
                      icon: Icons.description,
                      hint: "Enter Description of food:",
                    ),
                    RoundedNumInput(
                      controller: calorie,
                      icon: Icons.local_fire_department_outlined,
                      hint: "Enter Calorie:",
                      suffix: "kcal",
                    ),
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditNutrientsScreen(),
                            settings: RouteSettings(
                              arguments: {
                                'carb': carb,
                                'protein': protein,
                                'fat': fat,
                                'saturated_fat': sfat,
                                'fiber': fiber,
                                'sugar': sugar,
                                'sodium': sodium,
                                'cholesterol': cholesterol,
                              },
                            ),
                          ),
                        );

                        if (result != null) {
                          setState(() {
                            carb = result['carb'];
                            protein = result['protein'];
                            fat = result['fat'];
                            sfat = result['sfat'];
                            fiber = result['fiber'];
                            sugar = result['sugar'];
                            sodium = result['sodium'];
                            cholesterol = result['cholesterol'];
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: InputContainer(
                          child: Row(
                            children: [
                              Icon(Icons.food_bank_outlined, color: kPrimaryColor),
                              SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  cursorColor: kPrimaryColor,
                                  decoration: InputDecoration(
                                    hintText: "Nutrients",
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              Icon(Icons.keyboard_arrow_right, color: kPrimaryColor),
                            ],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        _analyzeImage();
                      },
                      child: AbsorbPointer(
                        child: InputContainer(
                          child: Row(
                            children: [
                              Icon(Icons.upload, color: kPrimaryColor),
                              SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  cursorColor: kPrimaryColor,
                                  decoration: InputDecoration(
                                    hintText: "Analyze Image",
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              _isAnalyzing
                                  ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: kPrimaryColor, strokeWidth: 2),
                              )
                                  : _isCompleted
                                  ? Icon(Icons.check_circle, color: kPrimaryColor)
                                  : Icon(Icons.not_interested_outlined, color: kPrimaryColor),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: RoundedButton(
                          title: "Add",
                          onPressed: () {
                            if (selectedMeal == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Please select a meal!")),
                              );
                              return;
                            }

                            if (food.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Food cannot be empty!")),
                              );
                              return;
                            }

                            if (descr.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Description cannot be empty!")),
                              );
                              return;
                            }

                            if (calorie.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Calorie amount cannot be empty!")),
                              );
                              return;
                            }

                            double? parsedWater = double.tryParse(calorie.text);
                            if (parsedWater == null || parsedWater <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Please enter a valid calorie amount.")),
                              );
                              return;
                            }

                            _AddPresetMeal(); // Proceed if all inputs are valid
                          }
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealRadioButton(String meal) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMeal = meal;
        });
      },
      child: Container(
        width: 100,
        height: 50,
        decoration: BoxDecoration(
          color: selectedMeal == meal ? Color.fromARGB(255, 133, 169, 143) : Colors.green.shade50,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Color.fromARGB(255, 211, 241, 223), width: 1),
        ),
        child: Center(
          child: Text(
            meal,
            style: TextStyle(
              color: selectedMeal == meal ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _AddPresetMeal() async {
    try {
      final String result = await platform.invokeMethod('AddPreset', {
        "userId": uid,
        "meal": selectedMeal,
        "date": date.text,
        "food": food.text,
        "descr": descr.text,
        "calorie": double.parse(calorie.text),
        "carb": carb,
        "protein": protein,
        "fat": fat,
        "sfat": sfat,
        "fiber": fiber,
        "sugar": sugar,
        "sodium": sodium,
        "cholesterol": cholesterol
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Preset Meal Added Successfully"),
          duration: Duration(seconds: 1), // Set the duration to 1 second
        ),
      );

      await Future.delayed(Duration(seconds: 1));
      Navigator.pop(context);  // To pop the current screen before pushing the new screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PresetScreen()),
      );
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${e.message}")));
    }
  }


  Future<void> _analyzeImage() async {
    setState(() {
      _isAnalyzing = true;
      _isCompleted = false;
    });

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      print("No image selected.");
      setState(() {
        _isAnalyzing = false;
      });
      return;
    }

    String result;
    double tempCarb = 0;
    double tempCalorie = 0;
    double tempProtein = 0;
    double tempFat = 0;
    double tempSfat = 0;
    double tempFiber = 0;
    double tempSugar = 0;
    double tempSodium = 0;
    double tempCholesterol = 0;

    const MethodChannel _channel = MethodChannel('Image');

    try {
      final String response = await _channel.invokeMethod('AnalyzeImage', {
        'imagePath': image.path,  // Pass local file path instead of URL
      });

      result = response.isNotEmpty ? response : 'No valid response received.';

      List<String> responseLines = result.split("\n");
      for (String line in responseLines) {
        if (line.contains("Carbs")||line.contains("Carbohydrates")) {
          tempCarb = _extractValue(line);
        } if (line.contains("Calorie")||line.contains("Calories")) {
          tempCalorie = _extractValue(line);
        } if (line.contains("Saturated Fat")) {
          tempSfat = _extractValue(line);
        } else if (line.contains("Protein")) {
          tempProtein = _extractValue(line);
        } else if (line.contains("Fat")) {
          tempFat = _extractValue(line);
        } else if (line.contains("Fiber")) {
          tempFiber = _extractValue(line);
        } else if (line.contains("Sugar")) {
          tempSugar = _extractValue(line);
        } else if (line.contains("Sodium")) {
          tempSodium = _extractValue(line);
        } else if (line.contains("Cholesterol")) {
          tempCholesterol = _extractValue(line);
        }
      }

    } on PlatformException catch (e) {
      result = 'Failed to analyze image: ${e.message}';
      print(result);
    }

    if (!mounted) return;

    setState(() {
      calorie.text = tempCalorie.toString();
      carb = tempCarb;
      protein = tempProtein;
      fat = tempFat;
      sfat = tempSfat;
      fiber = tempFiber;
      sugar = tempSugar;
      sodium = tempSodium;
      cholesterol = tempCholesterol;
      _isAnalyzing = false;
      _isCompleted = true;
      print(result);
    });
  }

// Helper method to extract numeric value from the string
  double _extractValue(String line) {
    final match = RegExp(r"([\d.]+)").firstMatch(line);
    if (match != null) {
      double extractedValue = double.tryParse(match.group(0)!) ?? 0;
      return extractedValue;
    }
    print("No match found for: $line");
    return 0;
  }
}
