import 'package:flutter/material.dart';

class ExamData {
  final String id;
  final String studentId;
  final String name;
  final Map<String, double?> scores;
  final Map<String, int?> ranks;
  final Map<String, String?> grades;
  final String examId;

  ExamData({
    required this.id,
    required this.studentId,
    required this.name,
    required this.scores,
    required this.ranks,
    required this.grades,
    required this.examId,
  });

  factory ExamData.fromCsvRow(List<dynamic> row, List<String> headers, String examId) {
    final Map<String, double?> scores = {};
    final Map<String, int?> ranks = {};
    final Map<String, String?> grades = {};

    for (int i = 0; i < headers.length; i++) {
      final header = headers[i];
      final value = row[i];

      if (header.startsWith('score-')) {
        scores[header] = value == '' ? null : double.tryParse(value.toString());
      } else if (header.startsWith('rank-')) {
        ranks[header] = value == '' ? null : int.tryParse(value.toString());
      } else if (header.startsWith('grade-')) {
        grades[header] = value == '' ? null : value.toString();
      }
    }

    return ExamData(
      id: row[0]?.toString() ?? '',
      studentId: row[1]?.toString() ?? '',
      name: row[2]?.toString() ?? '',
      scores: scores,
      ranks: ranks,
      grades: grades,
      examId: examId,
    );
  }

  double? getScore(String subject) {
    // Try exact match first
    if (scores.containsKey('score-$subject')) {
      return scores['score-$subject'];
    }
    
    // Try with "等级" suffix
    if (scores.containsKey('score-$subject等级')) {
      return scores['score-$subject等级'];
    }
    
    // Try without "等级" suffix if subject ends with "等级"
    if (subject.endsWith('等级')) {
      final baseSubject = subject.substring(0, subject.length - 2);
      if (scores.containsKey('score-$baseSubject')) {
        return scores['score-$baseSubject'];
      }
    }
    
    return null;
  }

  int? getRank(String subject) {
    // Try exact match first
    if (ranks.containsKey('rank-$subject')) {
      return ranks['rank-$subject'];
    }
    
    // Try with "等级" suffix
    if (ranks.containsKey('rank-$subject等级')) {
      return ranks['rank-$subject等级'];
    }
    
    // Try without "等级" suffix if subject ends with "等级"
    if (subject.endsWith('等级')) {
      final baseSubject = subject.substring(0, subject.length - 2);
      if (ranks.containsKey('rank-$baseSubject')) {
        return ranks['rank-$baseSubject'];
      }
    }
    
    return null;
  }

  String? getGrade(String subject) {
    // First check if we have explicit grade data
    if (grades.containsKey('grade-$subject')) {
      return grades['grade-$subject'];
    }
    
    // Try with "等级" suffix
    if (grades.containsKey('grade-$subject等级')) {
      return grades['grade-$subject等级'];
    }
    
    // Try without "等级" suffix if subject ends with "等级"
    if (subject.endsWith('等级')) {
      final baseSubject = subject.substring(0, subject.length - 2);
      if (grades.containsKey('grade-$baseSubject')) {
        return grades['grade-$baseSubject'];
      }
    }
    
    // If no grade data is available, return null
    return null;
  }

  // 根据等地获取颜色
  static Color getGradeColor(String? grade) {
    if (grade == null || grade.isEmpty) return Colors.grey;
    
    final firstChar = grade[0].toUpperCase();
    switch (firstChar) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.lightGreen;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.deepOrange;
      case 'E':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Get total score, no longer prioritizing 六门折算总分 over 总分
  double? get totalScore {
    return getScore('总分');
  }
  
  double? get chineseMathEnglishTotal => getScore('语数英总分');
  int? get totalRank {
    return getRank('总分');
  }
  int? get chineseMathEnglishRank => getRank('语数英总分');
  String? get totalGrade {
    return getGrade('总分');
  }
  String? get chineseMathEnglishGrade => getGrade('语数英总分');
}

class ExamInfo {
  final String id;
  final String name;

  ExamInfo({required this.id, required this.name});
}

class ExamStats {
  final int totalStudents;
  final double averageTotalScore;
  final double maxTotalScore;
  final double minTotalScore;

  ExamStats({
    required this.totalStudents,
    required this.averageTotalScore,
    required this.maxTotalScore,
    required this.minTotalScore,
  });

  factory ExamStats.fromData(List<ExamData> data) {
    if (data.isEmpty) {
      return ExamStats(
        totalStudents: 0,
        averageTotalScore: 0,
        maxTotalScore: 0,
        minTotalScore: 0,
      );
    }

    final totalScores = data
        .map((d) => d.totalScore)
        .where((score) => score != null)
        .cast<double>()
        .toList();

    if (totalScores.isEmpty) {
      return ExamStats(
        totalStudents: data.length,
        averageTotalScore: 0,
        maxTotalScore: 0,
        minTotalScore: 0,
      );
    }

    return ExamStats(
      totalStudents: data.length,
      averageTotalScore: totalScores.reduce((a, b) => a + b) / totalScores.length,
      maxTotalScore: totalScores.reduce((a, b) => a > b ? a : b),
      minTotalScore: totalScores.reduce((a, b) => a < b ? a : b),
    );
  }
} 