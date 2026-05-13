import 'package:flutter/material.dart';
import 'package:medichat/Login/constants.dart';
import 'package:medichat/components/input_container.dart';

class RoundedPasswordInput extends StatelessWidget {
  const RoundedPasswordInput({
    Key? key,
    required this.controller,
    required this.hint
  }) : super(key: key);

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return InputContainer(
      child: TextField(
        controller: controller,
        cursorColor: kPrimaryColor,
        obscureText: true,
        decoration: InputDecoration(
          icon: Icon(Icons.lock, color: kPrimaryColor),
          hintText: hint,
          border: InputBorder.none
        ),
      ));
  }
}