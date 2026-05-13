import 'package:flutter/material.dart';
import 'package:medichat/Login/constants.dart';
import 'package:medichat/components/input_container.dart';

class RoundedInput extends StatelessWidget {
  const RoundedInput({
    Key? key,
    required this.controller,
    required this.icon,
    required this.hint
  }) : super(key: key);

  final TextEditingController controller;
  final IconData icon;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return InputContainer(
      child: TextField(
        controller: controller,
        cursorColor: Color.fromARGB(255, 211, 241, 223),
        decoration: InputDecoration(
          icon: Icon(icon, color: kPrimaryColor),
          hintText: hint,
          border: InputBorder.none
        ),
      ));
  }
}