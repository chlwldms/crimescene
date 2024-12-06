import 'package:flutter/material.dart';
import 'dart:async';
import 'notebook_screen.dart';
import 'search_screen.dart';
import 'vote_screen.dart';
import '../widgets/chat_popup.dart';
import 'settings_screen.dart';

class GameMainScreen extends StatefulWidget {
  const GameMainScreen({Key? key}) : super(key: key);

  @override
  State<GameMainScreen> createState() => _GameMainScreenState();
}

class _GameMainScreenState extends State<GameMainScreen> {
  late Timer _timer;
  int _remainingTime = 600; // 기본 게임 시간 (10분)
  static bool isSearchButtonDisabled = false; // 수색 버튼 비활성화 여부 (전역적으로 관리)

  @override
  void initState() {
    super.initState();
    _startTimer();
    _startFirstSearch();

    // 메인 화면으로 돌아올 때 수색 완료 여부를 확인하고 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is bool && args == true) {
        // 수색이 완료되었다면
        setState(() {
          isSearchButtonDisabled = true;
        });
        _startSecondSearch();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel();
        _navigateToVoteScreen();
      }
    });
  }

  void _navigateToVoteScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => VoteScreen(isTimerExpired: true), // 타이머 종료 상태 전달
      ),
    );
  }

  void _startFirstSearch() {
    Timer(const Duration(seconds: 30), () {
      if (mounted) {
        // 1차 수색 화면으로 자동 전환
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => SearchScreen(isSecondRound: false)),
        );
      }
    });
  }

  void _startSecondSearch() {
    Timer(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          isSearchButtonDisabled = false;
        });

        // 2차 수색으로 전환
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => SearchScreen(isSecondRound: true)),
        );
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_remainingTime == 0) {
          return false; // 타이머 종료 후 뒤로 가기 방지
        }
        return true; // 그 외의 경우에는 뒤로 가기 허용
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '범죄 현장',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          actions: [
            IconButton(
              iconSize: 36,
              icon: const Icon(Icons.chat, color: Colors.white),
              onPressed: () {
                // 채팅창 팝업 호출
                showDialog(
                  context: context,
                  builder: (context) => const ChatPopup(), // ChatPopup 통합
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  _formatTime(_remainingTime),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        body: Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: _buttonStyle(),
                  icon: const Icon(Icons.book, size: 30, color: Colors.white),
                  label: const Text('수첩 열기'),
                  onPressed: () {
                    if (_remainingTime > 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotebookScreen()),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30), // 왼쪽 여백 추가
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // 왼쪽 정렬
            children: [
              FloatingActionButton(
                heroTag: 'settings',
                backgroundColor: Colors.red,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsScreen()),
                  );
                },
                child:
                const Icon(Icons.settings, size: 40, color: Colors.white),
              ),
              const SizedBox(width: 16),
              FloatingActionButton(
                heroTag: 'notebook',
                backgroundColor: Colors.red,
                onPressed: () {
                  if (_remainingTime > 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NotebookScreen()),
                    );
                  }
                },
                child: const Icon(Icons.book, size: 40, color: Colors.white),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}
