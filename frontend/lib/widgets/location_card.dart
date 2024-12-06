import 'package:flutter/material.dart';

class LocationCard extends StatelessWidget {
  final String locationName; // 장소 이름
  final VoidCallback onTap; // 클릭 시 호출할 함수

  const LocationCard({
    Key? key,
    required this.locationName,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.redAccent, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            locationName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
