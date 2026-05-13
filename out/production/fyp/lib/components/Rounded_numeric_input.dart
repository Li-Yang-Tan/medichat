import 'package:flutter/material.dart';
import 'package:medichat/Login/constants.dart';
import 'package:medichat/components/input_container.dart';

class RoundedNumInput extends StatelessWidget {
  const RoundedNumInput({
    Key? key,
    required this.controller,
    required this.icon,
    required this.hint,
    required this.suffix
  }) : super(key: key);

  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return InputContainer(
        child: TextField(
          controller: controller,
          cursorColor: kPrimaryColor,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              icon: Icon(icon, color: kPrimaryColor),
              hintText: hint,
              border: InputBorder.none,
              suffixText: suffix,
          ),
        ));
  }
}