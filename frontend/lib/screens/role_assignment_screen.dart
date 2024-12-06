import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_main_screen.dart';
import '../game_state.dart';

class RoleAssignmentScreen extends StatelessWidget {
  const RoleAssignmentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('당신의 역할', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '당신은 ${gameState.userRole ?? "알 수 없음"} 입니다.',
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
              const SizedBox(height: 20),
              if (gameState.userRole == '탐정')
                const Text(
                  '탐정은 알리바이가 필요 없습니다.',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                )
              else if (gameState.userJob != null)
                Text(
                  '알리바이: ${gameState.userJob}',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                )
              else
                const Text(
                  '알리바이를 불러오는 중...',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const GameMainScreen()),
                  );
                },
                child: const Text(
                  '게임 시작',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
