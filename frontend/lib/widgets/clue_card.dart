import 'package:flutter/material.dart';

class ClueCard extends StatelessWidget {
  final String clueText; // 단서 내용
  final VoidCallback onTap; // 클릭 시 호출할 함수

  const ClueCard({
    Key? key,
    required this.clueText,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.redAccent, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.redAccent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                clueText,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
