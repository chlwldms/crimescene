import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math'; // 랜덤 숫자 생성용
import 'package:provider/provider.dart'; // 프로바이더 사용
import '../gameServerService.dart';
import 'game_main_screen.dart';
import 'vote_screen.dart';

class LocationDetailsScreen extends StatefulWidget {
  final String location;
  final int searchRound;

  const LocationDetailsScreen({Key? key, required this.location, required this.searchRound}) : super(key: key);

  @override
  _LocationDetailsScreenState createState() => _LocationDetailsScreenState();
}

class _LocationDetailsScreenState extends State<LocationDetailsScreen> {
  int cluesFoundInCurrentRound = 0;
  Timer? searchTimer;
  int secondsRemaining = 60;
  Map<int, String?> cluesAssigned = {};
  static const int maxCluesPerRound = 4;

  @override
  void initState() {
    super.initState();
    _startSearchTimer();
  }

  @override
  void dispose() {
    searchTimer?.cancel();
    super.dispose();
  }

  void _startSearchTimer() {
    searchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        _endSearch("제한 시간이 종료되었습니다.");
      }
    });
  }

  void _endSearch(String message) {
    searchTimer?.cancel();

    if (widget.searchRound == 1) {
      setState(() {
        cluesFoundInCurrentRound = 0;
        secondsRemaining = 60;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const GameMainScreen(),
          settings: RouteSettings(arguments: true),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => VoteScreen(isTimerExpired: false)),
      );
    }
  }

  String _getLocationImage() {
    switch (widget.location) {
      case "김이현의 작업실":
        return 'lib/assets/studio.png';
      case "황윤서의 거실":
        return 'lib/assets/living_room.png';
      case "신예슬의 연구실":
        return 'lib/assets/lab.png';
      case "김윤복의 사무실":
        return 'lib/assets/office.png';
      case "한규상의 집":
        return 'lib/assets/house.png';
      default:
        return 'lib/assets/default.jpg';
    }
  }

  List<Widget> _buildFixedPositionButtons() {
    switch (widget.location) {
      case "김이현의 작업실":
        return [
          Positioned(
            top: 50,
            left: 650,
            child: _buildClueButton(1, "shelf", "shelf"),
          ),
          Positioned(
            bottom: 70,
            left: 150,
            child: _buildClueButton(2, "floor", "floor"),
          ),
          Positioned(
            bottom: 100,
            right: 550,
            child: _buildClueButton(3, "trash can", "trash_can"),
          ),
          Positioned(
            right: 350,
            bottom: 50,
            child: _buildClueButton(4, "desk", "desk"),
          ),
          Positioned(
            right: 500,
            top: 200,
            child: _buildClueButton(5, "tab", "tab"),
          ),
        ];
      case "황윤서의 거실":
        return [
          Positioned(
            top: 50,
            left: 650,
            child: _buildClueButton(1, "shelf", "shelf"),
          ),
          Positioned(
            bottom: 20,
            right: 500,
            child: _buildClueButton(2, "floor", "floor"),
          ),
          Positioned(
            bottom: 100,
            right: 25,
            child: _buildClueButton(3, "trash can", "trash_can"),
          ),
          Positioned(
            right: 550,
            bottom: 250,
            child: _buildClueButton(4, "desk", "desk"),
          ),
          Positioned(
            left: 500,
            bottom: 20,
            child: _buildClueButton(5, "tab", "tab"),
          ),
        ];
      case "신예슬의 연구실":
        return [
          Positioned(
            top: 70,
            right: 50,
            child: _buildClueButton(1, "shelf", "shelf"),
          ),
          Positioned(
            top: 150,
            left: 150,
            child: _buildClueButton(2, "floor", "floor"),
          ),
          Positioned(
            bottom: 5,
            left: 290,
            child: _buildClueButton(3, "trash can", "trash_can"),
          ),
          Positioned(
            right: 100,
            bottom: 20,
            child: _buildClueButton(4, "desk", "desk"),
          ),
          Positioned(
            right: 550,
            bottom: 250,
            child: _buildClueButton(5, "tab", "tab"),
          ),
        ];
      case "김윤복의 사무실":
        return [
          Positioned(
            top: 60,
            left: 300,
            child: _buildClueButton(1, "shelf", "shelf"),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: _buildClueButton(2, "floor", "floor"),
          ),
          Positioned(
            bottom: 300,
            left: 250,
            child: _buildClueButton(3, "trash can", "trash_can"),
          ),
          Positioned(
            right: 600,
            bottom: 20,
            child: _buildClueButton(4, "desk", "desk"),
          ),
          Positioned(
            right: 600,
            bottom: 250,
            child: _buildClueButton(5, "tab", "tab"),
          ),
        ];
      case "한규상의 집":
        return [
          Positioned(
            top: 80,
            left: 50,
            child: _buildClueButton(1, "shelf", "shelf"),
          ),
          Positioned(
            bottom: 150,
            left: 150,
            child: _buildClueButton(2, "floor", "floor"),
          ),
          Positioned(
            bottom: 40,
            left: 300,
            child: _buildClueButton(3, "trash can", "trash_can"),
          ),
          Positioned(
            left: 600,
            bottom: 260,
            child: _buildClueButton(4, "desk", "desk"),
          ),
          Positioned(
            right: 100,
            bottom: 300,
            child: _buildClueButton(5, "tab", "tab"),
          ),
        ];
      default:
        return [
          Positioned(
            top: 100,
            left: 50,
            child: _buildClueButton(1, "shelf", "shelf"),
          ),
          Positioned(
            top: 100,
            right: 50,
            child: _buildClueButton(2, "floor", "floor"),
          ),
          Positioned(
            bottom: 150,
            left: 50,
            child: _buildClueButton(3, "trash can", "trash_can"),
          ),
          Positioned(
            bottom: 150,
            right: 50,
            child: _buildClueButton(4, "desk", "desk"),
          ),
          Positioned(
            bottom: 300,
            left: 100,
            child: _buildClueButton(5, "tab", "tab"),
          ),
        ];
    }
  }

  Widget _buildClueButton(int buttonIndex, String label, String clueGroup) {
    return GestureDetector(
      onTap: () async {
        if (cluesFoundInCurrentRound < maxCluesPerRound) {
          String? clue;

          final random = Random();
          int clueNumber = random.nextInt(8) + 1; // 1~8 랜덤 생성

          try {
            final serverService = context.read<GameServerService>();
            await serverService.fetchEvidence(widget.location.split('의')[0], clueGroup, clueNumber);

            // 서버 응답 수신
            final response = await serverService.responseStream.firstWhere(
                  (msg) => msg.responseType == 'EVIDENCE',
            );
            clue = response.responseBody;
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('서버 통신 오류: $e'), backgroundColor: Colors.red),
            );
            return;
          }

          if (clue != null) {
            cluesFoundInCurrentRound++;
            if (cluesFoundInCurrentRound == maxCluesPerRound) {
              _endSearch('1차 수색이 종료되었습니다.');
            }

            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.black,
                title: const Text(
                  "발견된 단서",
                  style: TextStyle(color: Colors.white),
                ),
                content: Text(
                  clue ?? '단서를 발견할 수 없습니다.', // null일 경우 기본 메시지 제공
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("확인", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('이 그룹에 더 이상 단서가 없습니다.'),
                backgroundColor: Colors.grey,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('1차 수색이 종료되었습니다.'),
              backgroundColor: Colors.grey,
            ),
          );
        }
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: Colors.redAccent, width: 1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.location} (라운드: ${widget.searchRound})"),
      ),
      body: Stack(
        children: [
          Container(
            width: screenSize.width,
            height: screenSize.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(_getLocationImage()),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "남은 시간: $secondsRemaining초",
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          ..._buildFixedPositionButtons(),
        ],
      ),
    );
  }
}
