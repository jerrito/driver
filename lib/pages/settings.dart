import 'package:flutter/material.dart';
import 'package:driver/widgets/settings_switch.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool status = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Settings")),
        body: Container(
            child: const Column(
          children: [
            Text("Push Notifications"),
            SizedBox(height: 20),
            SettingSwitching(title: "Allow Push Notifications"),
            SizedBox(height: 10),
            SettingSwitching(title: "Order Updates"),
            SizedBox(height: 10),
            SettingSwitching(title: "New Arrivals"),
            SizedBox(height: 10),
            SettingSwitching(title: "Promotions"),
          ],
        )));
  }
}
