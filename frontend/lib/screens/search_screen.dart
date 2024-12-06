import 'package:flutter/material.dart';
import 'location_details_screen.dart'; // LocationDetailsScreen이 정의된 파일을 import

class SearchScreen extends StatelessWidget {
  final bool isSecondRound;

  SearchScreen({Key? key, required this.isSecondRound}) : super(key: key);

  final List<String> locations = [
    "김이현의 작업실",
    "황윤서의 거실",
    "신예슬의 연구실",
    "김윤복의 사무실",
    "한규상의 집",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('수색 장소 선택'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: locations.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LocationDetailsScreen(
                    location: locations[index],
                    searchRound: isSecondRound ? 2 : 1, // 1차 또는 2차 수색
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.redAccent, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  locations[index],
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
