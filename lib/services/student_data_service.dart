import 'package:flutter/foundation.dart';
import '../models/exam_data.dart';
import '../models/student_data.dart';
import 'exam_data_service.dart';

class StudentDataService {
  final ExamDataService _examDataService = ExamDataService();

  // 加载所有学生数据
  Future<List<StudentData>> loadAllStudentData() async {
    final Map<String, StudentData> studentsMap = {};
    
    // 遍历所有考试
    for (final exam in ExamDataService.examList) {
      try {
        final result = await _examDataService.loadExamDataWithOrder(exam.id);
        final examData = result['data'] as List<ExamData>;
        
        // 为每个学生添加这次考试的数据
        for (final data in examData) {
          final studentId = data.studentId;
          
          // 检查学生是否参加了这场考试（有有效的成绩数据）
          if (!_hasValidExamData(data)) {
            continue; // 跳过没有参加考试的学生
          }
          
          if (!studentsMap.containsKey(studentId)) {
            studentsMap[studentId] = StudentData(
              studentId: studentId,
              name: data.name,
              examRecords: [],
            );
          }
          
          // 创建考试记录
          final examRecord = _createExamRecord(data, exam);
          studentsMap[studentId]!.examRecords.add(examRecord);
        }
      } catch (e) {
        debugPrint('Error loading exam ${exam.id}: $e');
      }
    }
    
    return studentsMap.values.toList();
  }

  // 从ExamData创建StudentExamRecord
  StudentExamRecord _createExamRecord(ExamData examData, ExamInfo examInfo) {
    final Map<String, double?> scores = {};
    final Map<String, int?> ranks = {};
    final Map<String, String?> grades = {};
    final List<String> subjectOrder = [];

    // 转换成绩数据并保持顺序
    for (final entry in examData.scores.entries) {
      final subject = entry.key.substring(6); // 移除 'score-' 前缀
      scores[subject] = entry.value;
      if (!subjectOrder.contains(subject)) {
        subjectOrder.add(subject);
      }
    }

    // 转换排名数据
    for (final entry in examData.ranks.entries) {
      final subject = entry.key.substring(5); // 移除 'rank-' 前缀
      ranks[subject] = entry.value;
      if (!subjectOrder.contains(subject)) {
        subjectOrder.add(subject);
      }
    }

    // 转换档次数据
    for (final entry in examData.grades.entries) {
      final subject = entry.key.substring(6); // 移除 'grade-' 前缀
      grades[subject] = entry.value;
      if (!subjectOrder.contains(subject)) {
        subjectOrder.add(subject);
      }
    }

    return StudentExamRecord(
      examId: examInfo.id,
      examName: examInfo.name,
      date: _getExamDate(examInfo.id),
      scores: scores,
      ranks: ranks,
      grades: grades,
      subjectOrder: subjectOrder,
    );
  }

  // 检查学生是否有有效的考试数据
  bool _hasValidExamData(ExamData examData) {
    // 优先检查总分（六门折算总分或总分）
    final totalScore = examData.scores['score-六门折算总分'] ?? examData.scores['score-总分'];
    if (totalScore != null && totalScore > 0) {
      return true; // 有有效总分，说明参加了考试
    }
    
    // 检查主要科目是否有有效成绩（至少有一个主要科目有成绩）
    final mainSubjects = ['语文', '数学', '英语', '物理', '化学', '生物'];
    for (final subject in mainSubjects) {
      final score = examData.scores['score-$subject'];
      if (score != null && score > 0) {
        return true; // 有主要科目成绩，说明参加了考试
      }
    }
    
    // 检查是否有任何有效的排名数据（总分排名）
    final totalRank = examData.ranks['rank-六门折算总分'] ?? examData.ranks['rank-总分'];
    if (totalRank != null && totalRank > 0) {
      return true; // 有有效总分排名，说明参加了考试
    }
    
    // 检查是否有任何有效的档次数据（总分档次）
    final totalGrade = examData.grades['grade-六门折算总分'] ?? examData.grades['grade-总分'];
    if (totalGrade != null && totalGrade.isNotEmpty && totalGrade != '--') {
      return true; // 有有效总分档次，说明参加了考试
    }
    
    return false; // 没有任何有效数据，说明没有参加考试
  }

  // 根据考试ID获取考试日期（这里需要根据实际情况调整）
  DateTime _getExamDate(String examId) {
    // 根据info.txt文件中的考试顺序设置日期
    final dateMap = {
      '13': DateTime(2023, 9, 1),   // 高一上其中
      '27': DateTime(2023, 10, 1),  // 高一上期末
      '63': DateTime(2023, 11, 1),  // 高一下期中
      '107': DateTime(2023, 12, 1), // 高一下期末
      '160': DateTime(2024, 1, 1),  // 高二上期中
      '199': DateTime(2024, 2, 1),  // 高二上期末
      '227': DateTime(2024, 3, 1),  // 高二下期中
      '256': DateTime(2024, 4, 1),  // 高二下期末
      '272': DateTime(2024, 5, 1),  // 高三上月考一
      '282': DateTime(2024, 6, 1),  // 高三上期中
      '295': DateTime(2024, 7, 1),  // 高三上一模
    };
    
    return dateMap[examId] ?? DateTime.now();
  }

  // 搜索学生
  List<StudentData> searchStudents(List<StudentData> students, String searchTerm) {
    if (searchTerm.isEmpty) {
      return students;
    }
    
    final lowerSearchTerm = searchTerm.toLowerCase();
    return students.where((student) {
      return student.name.toLowerCase().contains(lowerSearchTerm) ||
             student.studentId.toLowerCase().contains(lowerSearchTerm);
    }).toList();
  }

  // 根据学生ID获取学生数据
  StudentData? getStudentById(List<StudentData> students, String studentId) {
    try {
      return students.firstWhere((student) => student.studentId == studentId);
    } catch (e) {
      return null;
    }
  }
} 