import 'package:flutter/material.dart';
import 'package:medichat/Login/constants.dart';

class RoundedButton extends StatefulWidget {
  const RoundedButton({
    Key? key,
    required this.title,
    required this.onPressed,
  }) : super(key: key);

  final String title;
  final VoidCallback onPressed;

  @override
  _RoundedButtonState createState() => _RoundedButtonState();
}

class _RoundedButtonState extends State<RoundedButton> {
  Color _buttonColor = Colors.green.shade100; // Initial color

  void _onTap() {
    setState(() {
      _buttonColor = _buttonColor.darken(0.2); // Darker shade when pressed
    });
    widget.onPressed(); // Call the onPressed callback
    Future.delayed(Duration(milliseconds: 150), () {
      setState(() {
        _buttonColor = Colors.green.shade100; // Reset color after a brief delay
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return InkWell(
      onTap: _onTap, // Use the custom _onTap method
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: size.width * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: _buttonColor, // Updated to use the state variable
        ),
        padding: EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.center,
        child: Text(
          widget.title,
          style: TextStyle(
            color: Color.fromARGB(255, 98, 130, 93),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

// Extension to darken the color
extension ColorExtension on Color {
  Color darken(double amount) {
    assert(amount >= 0 && amount <= 1);
    int red = (this.red * (1 - amount)).toInt();
    int green = (this.green * (1 - amount)).toInt();
    int blue = (this.blue * (1 - amount)).toInt();
    return Color.fromRGBO(red, green, blue, 1);
  }
}
