

class StudentData {
  final String studentId;
  final String name;
  final List<StudentExamRecord> examRecords;

  StudentData({
    required this.studentId,
    required this.name,
    required this.examRecords,
  });

  // 获取学生在所有考试中的排名数据（用于折线图）
  List<StudentRankPoint> getRankHistory() {
    final List<StudentRankPoint> rankHistory = [];
    
    for (final record in examRecords) {
      final totalScore = record.totalScore;
      final totalRank = record.totalRank;
      
      if (totalScore != null && totalRank != null) {
        rankHistory.add(StudentRankPoint(
          examId: record.examId,
          examName: record.examName,
          score: totalScore,
          rank: totalRank,
          date: record.date,
        ));
      }
    }
    
    // 按日期排序（从早到晚）
    rankHistory.sort((a, b) => a.date.compareTo(b.date));
    return rankHistory;
  }

  // 获取考试记录（按时间倒序，最新的在前）
  List<StudentExamRecord> getExamRecordsSorted() {
    final sorted = List<StudentExamRecord>.from(examRecords);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }
}

class StudentExamRecord {
  final String examId;
  final String examName;
  final DateTime date;
  final Map<String, double?> scores;
  final Map<String, int?> ranks;
  final Map<String, String?> grades;
  final List<String> subjectOrder; // 保持科目的原始顺序

  StudentExamRecord({
    required this.examId,
    required this.examName,
    required this.date,
    required this.scores,
    required this.ranks,
    required this.grades,
    required this.subjectOrder,
  });

  // 获取总分（优先六门折算总分，否则总分）
  double? get totalScore {
    return scores['六门折算总分'] ?? scores['总分'];
  }

  // 获取总分排名
  int? get totalRank {
    return ranks['六门折算总分'] ?? ranks['总分'];
  }

  // 获取总分档次
  String? get totalGrade {
    return grades['六门折算总分'] ?? grades['总分'];
  }

  // 获取指定科目的成绩
  double? getScore(String subject) {
    return scores[subject];
  }

  // 获取指定科目的排名
  int? getRank(String subject) {
    return ranks[subject];
  }

  // 获取指定科目的档次
  String? getGrade(String subject) {
    return grades[subject];
  }

  // 获取所有科目（按原始顺序）
  List<String> getSubjects() {
    return subjectOrder.where((subject) => scores[subject] != null).toList();
  }
}

class StudentRankPoint {
  final String examId;
  final String examName;
  final double score;
  final int rank;
  final DateTime date;

  StudentRankPoint({
    required this.examId,
    required this.examName,
    required this.score,
    required this.rank,
    required this.date,
  });
} 