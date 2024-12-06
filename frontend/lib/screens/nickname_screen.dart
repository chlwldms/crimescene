import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../gameServerService.dart';
import '../NicknameProvider.dart';
import 'home_screen.dart';

class NicknameScreen extends StatefulWidget {
  const NicknameScreen({Key? key}) : super(key: key);

  @override
  _NicknameScreenState createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {
  final TextEditingController _nicknameController = TextEditingController();

  void _saveNickname() async {
    if (_nicknameController.text.isNotEmpty) {
      final gameServerService = Provider.of<GameServerService>(context, listen: false);
      final nicknameProvider = Provider.of<NicknameProvider>(context, listen: false);

      try {
        // 서버 연결
        await gameServerService.connect();

        // 닉네임 설정
        nicknameProvider.setNickname(_nicknameController.text);
        await gameServerService.setName(_nicknameController.text);

        // HomeScreen으로 이동
        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버 연결 실패: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임을 입력해주세요!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '닉네임을 입력하세요',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '닉네임 입력',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveNickname,
                child: const Text('저장하고 시작하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
