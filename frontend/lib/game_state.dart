import 'package:flutter/foundation.dart';

class GameState extends ChangeNotifier {
  String? userRole;
  String? userJob;
  String? criminal;
  String? causeOfDeath;

  void setRole(String role) {
    userRole = role;
    notifyListeners();
  }

  void setJob(String job) {
    userJob = job;
    notifyListeners();
  }

  void setCriminal(String criminalRole) {
    criminal = criminalRole;
    notifyListeners();
  }

  void setCauseOfDeath(String cause) {
    causeOfDeath = cause;
    notifyListeners();
  }
}
