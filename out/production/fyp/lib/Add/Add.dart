import 'package:flutter/material.dart';
import 'package:medichat/Add/Add_Meal.dart';
import 'package:medichat/Add/Add_Water.dart';
import 'package:medichat/Add/Add_Weight.dart';
import 'package:medichat/Add/Add_Workout.dart';
import 'package:medichat/Add/Preset.dart';
import 'package:medichat/Add/components/number_page.dart';

class AddForm extends StatelessWidget {
  const AddForm({
    Key? key,
    required this.isLogin,
    required this.animationDuration,
    required this.size,
    required this.defaultAddSize,
  }) : super(key: key);

  final bool isLogin;
  final Duration animationDuration;
  final Size size;
  final double defaultAddSize;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isLogin ? 0.0 : 1.0,
      duration: animationDuration * 5,
      child: Visibility(
        visible: !isLogin,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: size.width,
            height: defaultAddSize,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 30),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildRoundedContainer("Add Weight", () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => AddWeightScreen()));
                        }),
                        _buildRoundedContainer("Add Water", () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => AddWaterScreen()));
                        }),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildRoundedContainer("Add Meal", () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => AddMealScreen()));
                        }),
                        _buildRoundedContainer("Add Workout", () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => AddWorkoutScreen()));
                        }),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildExtraRoundedContainer("Preset Meal", () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => PresetScreen()));
                        }),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoundedContainer(String text, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 140,
        height: 100,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 186, 216, 182),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildExtraRoundedContainer(String text, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 250,
        height: 55,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 186, 216, 182),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}