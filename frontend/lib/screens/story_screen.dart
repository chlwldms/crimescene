import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'role_assignment_screen.dart';
import '../gameServerService.dart';
import '../game_state.dart';
import '../NicknameProvider.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({Key? key}) : super(key: key);

  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final PageController _pageController = PageController();
  final List<Map<String, String>> _storyContent = [
    {
      'image': 'lib/assets/story1.png',
      'text': 'Your first part of the story goes here...',
    },
    {
      'image': 'lib/assets/story2.png',
      'text': 'Your second part of the story goes here...',
    },
    {
      'image': 'lib/assets/story3.png',
      'text': 'Your third part of the story goes here...',
    },
    {
      'image': 'lib/assets/story4.png',
      'text': 'Your final part of the story goes here...',
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupResponseListeners();
    _requestRoleAndJob();
  }

  void _setupResponseListeners() {
    final gameServerService = Provider.of<GameServerService>(context, listen: false);
    final gameState = Provider.of<GameState>(context, listen: false);

    gameServerService.responseStream.listen((response) {
      // Process response messages
      if (response.responseType == 'YOURROLE') {
        gameState.setRole(response.responseBody!);
        print('Role received: ${gameState.userRole}');
      } else if (response.responseType == 'YOURJOB') {
        gameState.setJob(response.responseBody!);
        print('Job received: ${gameState.userJob}');
        _requestCriminalAndCause(); // Request next info
      } else if (response.responseType == 'CRIMINAL') {
        gameState.setCriminal(response.responseBody!);
        print('Criminal received: ${gameState.criminal}');
      } else if (response.responseType == 'CAUSEOFDEATH') {
        gameState.setCauseOfDeath(response.responseBody!);
        print('Cause of Death received: ${gameState.causeOfDeath}');
      }
    }, onError: (error) {
      print('Error in response stream: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process response: $error')),
      );
    });
  }

  Future<void> _requestRoleAndJob() async {
    final gameServerService = Provider.of<GameServerService>(context, listen: false);
    final nickname = Provider.of<NicknameProvider>(context, listen: false).nickname;

    try {
      // Request Role
      await gameServerService.sendRequest(RequestMessage(
        requestType: 'GETROLE',
        sender: nickname,
      ));
      // Request Job
      await gameServerService.sendRequest(RequestMessage(
        requestType: 'GETJOB',
        sender: nickname,
      ));
    } catch (e) {
      print('Failed to request role and job: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch role and job: $e')),
      );
    }
  }

  Future<void> _requestCriminalAndCause() async {
    final gameServerService = Provider.of<GameServerService>(context, listen: false);
    final nickname = Provider.of<NicknameProvider>(context, listen: false).nickname;

    try {
      // Request Criminal
      await gameServerService.sendRequest(RequestMessage(
        requestType: 'GETCRIMINAL',
        sender: nickname,
      ));
      // Request Cause of Death
      await gameServerService.sendRequest(RequestMessage(
        requestType: 'GETCAUSEOFDEATH',
        sender: nickname,
      ));
    } catch (e) {
      print('Failed to request criminal and cause of death: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch additional info: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: _storyContent.length,
        itemBuilder: (context, index) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                _storyContent[index]['image']!,
                fit: BoxFit.cover,
              ),
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _storyContent[index]['text']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: screenSize.height * 0.05,
                right: screenSize.width * 0.05,
                child: index < _storyContent.length - 1
                    ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                )
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RoleAssignmentScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Start',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
