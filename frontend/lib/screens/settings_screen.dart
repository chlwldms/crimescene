// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '설정',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.black,
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.volume_up, color: Colors.white),
              title: const Text('소리 설정', 
                style: TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
              onTap: () {
                // 소리 설정 관련 로직
              },
            ),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.white),
              title: const Text('언어 설정', 
                style: TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
              onTap: () {
                // 언어 설정 관련 로직
              },
            ),
          ],
        ),
      ),
    );
  }
}