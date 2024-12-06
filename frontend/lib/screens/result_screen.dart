import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider 사용
import 'data.dart';
import '../game_state.dart'; // GameState 가져오기

class ResultScreen extends StatelessWidget {
  final String selectedSuspect; // 사용자가 투표한 용의자
  final String? voteResult; // 서버에서 받은 최다 득표 결과
  final String? tieResult; // 서버에서 받은 동률 결과 (옵션)

  const ResultScreen({
    Key? key,
    required this.selectedSuspect,
    this.voteResult,
    this.tieResult,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // GameState에서 실제 범인 정보 가져오기
    final gameState = Provider.of<GameState>(context, listen: false);
    final String? actualCriminal = gameState.criminal;

    // 최다 득표 결과 파싱
    final String? culprit = voteResult?.split('/')[0]; // "김윤복/3" -> "김윤복"
    final int? votes = int.tryParse(voteResult?.split('/')[1] ?? "0"); // "김윤복/3" -> 3

    // 동률 결과 파싱
    List<String>? tiedSuspects;
    int? tieVotes;
    if (tieResult != null) {
      final parts = tieResult!.split('/'); // "3/김윤복/한규상/신예슬/1"
      if (parts.length > 2) {
        tiedSuspects = parts.sublist(1, parts.length - 1); // ["김윤복", "한규상", "신예슬"]
        tieVotes = int.tryParse(parts.last); // "1"
      }
    }

    // 실제 범인으로 서버에서 받아온 actualCriminal을 사용
    final String actualCulprit = actualCriminal ?? (culprit ?? (tiedSuspects?.join(', ') ?? "미정"));
    final bool isCorrect = selectedSuspect == actualCriminal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('결과 화면'),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '실제 범인:',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                actualCulprit,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '투표로 지목된 사람:',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              if (tiedSuspects != null) ...[
                Text(
                  tiedSuspects.join(', '), // 동률 용의자 표시
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '받은 표 수: $tieVotes표',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ] else ...[
                Text(
                  culprit ?? '지목된 사람이 없습니다.',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                if (votes != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    '받은 표 수: $votes표',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 40),
              Text(
                isCorrect ? '범인 찾기 성공!' : '범인 찾기 실패!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  GameData.resetGameData(); // 게임 데이터 초기화
                  Navigator.pop(context);
                },
                child: const Text(
                  '다시 시작',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
