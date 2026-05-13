import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medichat/components/Rounded_numeric_input.dart';
import 'package:medichat/components/connection.dart';
import 'package:medichat/components/rounded_button.dart';

class AddNutrientsScreen extends StatefulWidget {
  @override
  State<AddNutrientsScreen> createState() => _SetAddNutrientsScreenState();
}

class _SetAddNutrientsScreenState extends State<AddNutrientsScreen> {
  final String? uid = ConnectionService.getUID();

  final TextEditingController carbD = TextEditingController();
  final TextEditingController proteinD = TextEditingController();
  final TextEditingController fatD = TextEditingController();
  final TextEditingController sfatD = TextEditingController();
  final TextEditingController fiberD = TextEditingController();
  final TextEditingController sugarD = TextEditingController();
  final TextEditingController sodiumD = TextEditingController();
  final TextEditingController cholesterolD = TextEditingController();

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
          "Add Nutrients Record",
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
                    RoundedNumInput(
                      controller: carbD,
                      icon: Icons.rice_bowl_outlined,
                      hint: "Enter Amount of Carbohydrate:",
                      suffix: "g",
                    ),
                    RoundedNumInput(
                      controller: proteinD,
                      icon: Icons.fitness_center_outlined,
                      hint: "Enter Amount of Protein:",
                      suffix: "g",
                    ),
                    RoundedNumInput(
                      controller: fatD,
                      icon: Icons.opacity_outlined,
                      hint: "Enter Amount of Fat:",
                      suffix: "g",
                    ),
                    RoundedNumInput(
                      controller: sfatD,
                      icon: Icons.water_drop_outlined,
                      hint: "Enter Amount of Saturated Fat:",
                      suffix: "g",
                    ),
                    RoundedNumInput(
                      controller: fiberD,
                      icon: Icons.grass_outlined,
                      hint: "Enter Amount of Fiber:",
                      suffix: "g",
                    ),
                    RoundedNumInput(
                      controller: sugarD,
                      icon: Icons.cake_outlined,
                      hint: "Enter Amount of Sugar:",
                      suffix: "g",
                    ),
                    RoundedNumInput(
                      controller: sodiumD,
                      icon: Icons.access_time_rounded,
                      hint: "Enter Amount of Sodium:",
                      suffix: "mg",
                    ),
                    RoundedNumInput(
                      controller: cholesterolD,
                      icon: Icons.favorite_outlined,
                      hint: "Enter Amount of Cholesterol:",
                      suffix: "mg",
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: RoundedButton(
                          title: "Add",
                          onPressed: () {
                            double? parsedCarb = double.tryParse(carbD.text);
                            if (parsedCarb! < 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Please enter a valid carbohydrate amount.")),
                              );
                              return;
                            }

                            double? parsedProtein = double.tryParse(proteinD.text);
                            if (parsedProtein! < 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Please enter a valid protein amount.")),
                              );
                              return;
                            }

                            double? parsedFat = double.tryParse(fatD.text);
                            if (parsedFat! < 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Please enter a valid fat amount.")),
                              );
                              return;
                            }

                            double? parsedSfat = double.tryParse(sfatD.text);
                            if (parsedSfat! < 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Please enter a valid saturated fat amount.")),
                              );
                              return;
                            }

                            double? parsedFiber = double.tryParse(fiberD.text);
                            if (parsedFiber! < 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Please enter a valid fiber amount.")),
                              );
                              return;
                            }

                            double? parsedSugar = double.tryParse(sugarD.text);
                            if (parsedSugar! < 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Please enter a valid sugar amount.")),
                              );
                              return;
                            }

                            double? parsedSodium = double.tryParse(sodiumD.text);
                            if (parsedSodium! < 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Please enter a valid sodium amount.")),
                              );
                              return;
                            }

                            double? parsedCholesterol = double.tryParse(cholesterolD.text);
                            if (parsedCholesterol! < 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Please enter a valid cholesterol amount.")),
                              );
                              return;
                            }

                            // Proceed if all inputs are valid
                            double carbValue = double.tryParse(carbD.text) ?? 0;
                            double proteinValue = double.tryParse(proteinD.text) ?? 0;
                            double fatValue = double.tryParse(fatD.text) ?? 0;
                            double sfatValue = double.tryParse(sfatD.text) ?? 0;
                            double fiberValue = double.tryParse(fiberD.text) ?? 0;
                            double sugarValue = double.tryParse(sugarD.text) ?? 0;
                            double sodiumValue = double.tryParse(sodiumD.text) ?? 0;
                            double cholesterolValue = double.tryParse(cholesterolD.text) ?? 0;

                            print("Carb: $carbValue");
                            print("Protein: $proteinValue");
                            print("Fat: $fatValue");
                            print("Saturated Fat: $sfatValue");
                            print("Fiber: $fiberValue");
                            print("Sugar: $sugarValue");
                            print("Sodium: $sodiumValue");
                            print("Cholesterol: $cholesterolValue");

                            Navigator.pop(context, {
                              'carb': carbValue,
                              'protein': proteinValue,
                              'fat': fatValue,
                              'sfat': sfatValue,
                              'fiber': fiberValue,
                              'sugar': sugarValue,
                              'sodium': sodiumValue,
                              'cholesterol': cholesterolValue,
                            });
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


}
