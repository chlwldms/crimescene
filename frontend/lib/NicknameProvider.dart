import 'package:flutter/foundation.dart';

class NicknameProvider extends ChangeNotifier {
  String _nickname = '';

  String get nickname => _nickname;

  void setNickname(String newNickname) {
    _nickname = newNickname;
    notifyListeners(); // 상태 변경 알림
  }
}
