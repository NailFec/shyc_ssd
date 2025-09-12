import 'package:flutter/material.dart';

class StudentAvatar extends StatelessWidget {
  final String studentId;
  final String name;
  final double size;

  const StudentAvatar({
    super.key,
    required this.studentId,
    required this.name,
    this.size = 32,
  });

  String _normalizedId(String rawId) {
    final digitsOnly = rawId.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return '000';
    final lastThree = digitsOnly.length <= 3
        ? digitsOnly
        : digitsOnly.substring(digitsOnly.length - 3);
    return lastThree.padLeft(3, '0');
  }

  @override
  Widget build(BuildContext context) {
    final id3 = _normalizedId(studentId);
    final assetPath = 'data/avatars/$id3.webp';

    return ClipOval(
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return CircleAvatar(
            radius: size / 2,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              name.isNotEmpty ? name.characters.first : '?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
                fontSize: size * 0.45,
              ),
            ),
          );
        },
      ),
    );
  }
}


