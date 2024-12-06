import 'package:flutter/material.dart';
import 'data.dart';

class NotebookScreen extends StatelessWidget {
  const NotebookScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final collectedClues = GameData.collectedClues; // 플레이어가 수집한 단서
    final role = GameData.currentRole; // 현재 역할
    final alibi = GameData.currentAlibi; // 현재 알리바이

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          '수첩',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // 현재 역할 출력
            if (role != null)
              ListTile(
                title: Text(
                  "역할: $role",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            // 현재 알리바이 출력
            if (alibi != null)
              ListTile(
                title: Text(
                  "알리바이: $alibi",
                  style: const TextStyle(color: Colors.white),
                ),
              ),

            const Divider(color: Colors.red, thickness: 2),

            // 수집된 단서 표시
            if (collectedClues.isNotEmpty)
              ...collectedClues.map((clue) => ListTile(
                title: Text(
                  clue,
                  style: const TextStyle(color: Colors.white),
                ),
              ))
            else
              const Center(
                child: Text(
                  "아직 수집된 단서가 없습니다.",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
