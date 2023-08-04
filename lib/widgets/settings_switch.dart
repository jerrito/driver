import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

class SettingSwitching extends StatefulWidget {
  final String title;

  const SettingSwitching({Key? key, required this.title}) : super(key: key);

  @override
  State<SettingSwitching> createState() => _SettingSwitchingState();
}

class _SettingSwitchingState extends State<SettingSwitching> {
  bool status=false;
  @override
  Widget build(BuildContext context) {
    return  Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.title),
        FlutterSwitch(
          width: 70.0,
          height: 50.0,
          valueFontSize: 10.0,
          activeColor: Colors.green,
          toggleSize: 30.0,
          value: status,
          borderRadius: 20.0,
          padding: 8.0,
          showOnOff: true,
          onToggle: (val) {
            setState(() {
              status = val;
              if (val == false) {
                // print("Off);
              } else {
                // print("On");
              }
            });
          },
        ),
      ],
    );
  }
}
