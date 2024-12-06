import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/chat_popup.dart';
import '../gameServerService.dart'; // 수정된 임포트 경로 반영
import '../NicknameProvider.dart'; // NicknameProvider 임포트
import 'result_screen.dart';
import 'data.dart';

class VoteScreen extends StatefulWidget {
  final bool isTimerExpired;

  const VoteScreen({Key? key, required this.isTimerExpired}) : super(key: key);

  @override
  _VoteScreenState createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  String? selectedSuspect;
  late GameServerService _serverService;
  String? _voteResult; // 투표 결과 저장
  String? _tieResult; // 동률 결과 저장

  @override
  void initState() {
    super.initState();
    _serverService = Provider.of<GameServerService>(context, listen: false);

    // 서버의 NOTIFY 메시지 처리
    _serverService.notifyStream.listen((notifyMessage) {
      if (notifyMessage.notifyType == "VOTECOMPLETE") {
        setState(() {
          _voteResult = notifyMessage.notifyBody; // 투표 결과 반영
        });
        _navigateToResultScreen();
      } else if (notifyMessage.notifyType == "VOTETIE") {
        setState(() {
          _tieResult = notifyMessage.notifyBody; // 동률 결과 반영
        });
        _navigateToResultScreen();
      }
    }, onError: (error) {
      print("Error in notify stream: $error");
    });
  }

  void _submitVote() async {
    final nickname = Provider.of<NicknameProvider>(context, listen: false).nickname;

    if (selectedSuspect != null) {
      try {
        // 서버로 투표 요청 전송
        await _serverService.sendRequest(RequestMessage(
          requestType: "VOTE",
          sender: nickname.isNotEmpty ? nickname : "Unknown",
          requestBody: selectedSuspect!,
        ));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${selectedSuspect!} 에게 투표했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        print("Failed to send vote request: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('투표 요청에 실패했습니다. 다시 시도해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('투표할 용의자를 선택해주세요.'),
          backgroundColor: Colors.grey,
        ),
      );
    }
  }

  void _navigateToResultScreen() {
    // 결과 화면으로 이동
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          selectedSuspect: selectedSuspect ?? "None",
          voteResult: _voteResult,
          tieResult: _tieResult,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // 뒤로 가기 방지
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            '투표하기',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              iconSize: 36,
              icon: const Icon(Icons.chat, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const ChatPopup(),
                );
              },
            ),
          ],
        ),
        body: Container(
          color: Colors.black,
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: GameData.suspects.map((suspect) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: ListTile(
                        title: Text(
                          suspect,
                          style: TextStyle(
                            color: suspect == selectedSuspect
                                ? Colors.red
                                : Colors.white,
                            fontWeight: suspect == selectedSuspect
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        leading: Radio<String>(
                          value: suspect,
                          groupValue: selectedSuspect,
                          activeColor: Colors.redAccent,
                          onChanged: (value) {
                            setState(() {
                              selectedSuspect = value;
                            });
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: _submitVote,
                  child: const Text('투표 완료'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
