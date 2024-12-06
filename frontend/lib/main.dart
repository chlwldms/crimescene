import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'gameServerService.dart';
import 'NicknameProvider.dart';
import 'game_state.dart';
import 'screens/nickname_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GameServerService()),
        ChangeNotifierProvider(create: (context) => NicknameProvider()),
        ChangeNotifierProvider(create: (context) => GameState()),
      ],
      child: const CrimeSceneApp(),
    ),
  );
}

class CrimeSceneApp extends StatelessWidget {
  const CrimeSceneApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crime Scene',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.redAccent,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const NicknameScreen(),
        '/home': (context) {
          final nickname = Provider.of<NicknameProvider>(context).nickname;
          return HomeScreen(nickname: nickname);
        },
      },
    );
  }
}
