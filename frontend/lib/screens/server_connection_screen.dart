import 'package:flutter/material.dart';
import 'dart:io'; // 인터넷 연결 확인을 위한 import

class ServerConnectionScreen extends StatefulWidget {
  const ServerConnectionScreen({Key? key}) : super(key: key);

  @override
  _ServerConnectionScreenState createState() => _ServerConnectionScreenState();
}

class _ServerConnectionScreenState extends State<ServerConnectionScreen> {
  bool? _isConnected; // 서버 연결 상태를 저장하는 변수

  @override
  void initState() {
    super.initState();
    _checkServerConnection(); // 초기 화면 로드 시 서버 연결 확인
  }

  /// 서버 연결 확인 메서드
  Future<void> _checkServerConnection() async {
    try {
      // 서버 주소(example.com)를 변경하여 실제 서버로 설정하세요
      final result = await InternetAddress.lookup('localhost');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          _isConnected = true; // 연결 성공
        });
      } else {
        setState(() {
          _isConnected = false; // 연결 실패
        });
      }
    } catch (e) {
      setState(() {
        _isConnected = false; // 오류 발생 시 연결 실패로 간주
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('서버 연결 확인'), // 화면 제목
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black, // 화면 배경색 설정
        child: Center(
          child: _isConnected == null
              ? const CircularProgressIndicator() // 연결 상태 확인 중 로딩 인디케이터 표시
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 연결 상태에 따른 아이콘 표시
              Icon(
                _isConnected == true ? Icons.check_circle : Icons.error,
                color: _isConnected == true ? Colors.green : Colors.red,
                size: 100,
              ),
              const SizedBox(height: 20),
              // 연결 상태에 따른 메시지 표시
              Text(
                _isConnected == true
                    ? '서버와 성공적으로 연결되었습니다!'
                    : '서버 연결에 실패했습니다.',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // 다시 시도 버튼
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: _checkServerConnection, // 서버 연결 상태 다시 확인
                child: const Text(
                  '다시 시도',
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
