import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import '../models/exam_data.dart';

class ExamDataService {
  static final List<ExamInfo> examList = [
    ExamInfo(id: '13', name: '高一上其中'),
    ExamInfo(id: '27', name: '高一上期末'),
    ExamInfo(id: '63', name: '高一下期中'),
    ExamInfo(id: '107', name: '高一下期末'),
    ExamInfo(id: '160', name: '高二上期中'),
    ExamInfo(id: '199', name: '高二上期末'),
    ExamInfo(id: '227', name: '高二下期中'),
    ExamInfo(id: '256', name: '高二下期末'),
  ];

  // Get subjects dynamically from CSV headers
  static List<String> getSubjectsFromHeaders(List<String> headers) {
    final Set<String> subjects = {};
    
    for (final header in headers) {
      if (header.startsWith('score-')) {
        final subject = header.substring(6); // Remove 'score-' prefix
        subjects.add(subject);
      }
    }
    
    return subjects.toList()..sort();
  }

  // Get subjects in the order they appear in CSV headers
  static List<String> getSubjectsInCsvOrder(List<String> headers) {
    final List<String> subjects = [];
    
    for (final header in headers) {
      if (header.startsWith('score-')) {
        final subject = header.substring(6); // Remove 'score-' prefix
        subjects.add(subject);
      }
    }
    
    return subjects;
  }

  // Get normalized subject name (remove 等级 suffix for display)
  static String getNormalizedSubjectName(String subject) {
    if (subject.endsWith('等级')) {
      return subject.substring(0, subject.length - 2);
    }
    return subject;
  }

  // Get all possible subject variations for a given subject
  static List<String> getSubjectVariations(String subject) {
    final List<String> variations = [subject];
    
    // Add 等级 suffix variation
    if (!subject.endsWith('等级')) {
      variations.add('${subject}等级');
    }
    
    // Add base subject if current has 等级 suffix
    if (subject.endsWith('等级')) {
      variations.add(subject.substring(0, subject.length - 2));
    }
    
    return variations;
  }

  static List<String> getSortOptions(List<String> subjects) {
    final List<String> sortOptions = [];
    
    // Add total score options first
    for (final subject in ['六门折算总分', '总分', '语数英总分']) {
      if (subjects.contains(subject)) {
        sortOptions.add('rank-$subject');
      }
    }
    
    // Add individual subjects
    for (final subject in subjects) {
      if (!['六门折算总分', '总分', '语数英总分'].contains(subject)) {
        sortOptions.add('rank-$subject');
      }
    }
    
    return sortOptions;
  }

  Future<Map<String, List<ExamData>>> loadAllExamData() async {
    final Map<String, List<ExamData>> allData = {};

    for (final exam in examList) {
      try {
        final data = await loadExamData(exam.id);
        allData[exam.id] = data;
      } catch (e) {
        print('Error loading exam ${exam.id}: $e');
        allData[exam.id] = [];
      }
    }

    return allData;
  }

  Future<List<ExamData>> loadExamData(String examId) async {
    try {
      final String csvString = await rootBundle.loadString(
        'data/exams/rankingoutput-$examId.csv',
      );

      final List<List<dynamic>> csvTable = const CsvToListConverter().convert(csvString);
      
      if (csvTable.isEmpty) return [];

      final List<String> headers = csvTable[0].cast<String>();
      final List<ExamData> data = [];

      for (int i = 1; i < csvTable.length; i++) {
        final row = csvTable[i];
        if (row.length > 2 && row[2] != null && row[2].toString().isNotEmpty && row[2] != '调试无此人') {
          data.add(ExamData.fromCsvRow(row, headers, examId));
        }
      }

      return data;
    } catch (e) {
      print('Error parsing CSV for exam $examId: $e');
      return [];
    }
  }

  // Load exam data with subject order information
  Future<Map<String, dynamic>> loadExamDataWithOrder(String examId) async {
    try {
      final String csvString = await rootBundle.loadString(
        'data/exams/rankingoutput-$examId.csv',
      );

      final List<List<dynamic>> csvTable = const CsvToListConverter().convert(csvString);
      
      if (csvTable.isEmpty) return {'data': [], 'subjectOrder': []};

      final List<String> headers = csvTable[0].cast<String>();
      final List<ExamData> data = [];
      final List<String> subjectOrder = getSubjectsInCsvOrder(headers);

      for (int i = 1; i < csvTable.length; i++) {
        final row = csvTable[i];
        if (row.length > 2 && row[2] != null && row[2].toString().isNotEmpty && row[2] != '调试无此人') {
          data.add(ExamData.fromCsvRow(row, headers, examId));
        }
      }

      return {
        'data': data,
        'subjectOrder': subjectOrder,
      };
    } catch (e) {
      print('Error parsing CSV for exam $examId: $e');
      return {'data': [], 'subjectOrder': []};
    }
  }

  List<ExamData> filterData({
    required List<ExamData> data,
    required String searchTerm,
    required String selectedExam,
    required String sortBy,
  }) {
    List<ExamData> filteredData = List.from(data);

    // Apply search filter
    if (searchTerm.isNotEmpty) {
      filteredData = filteredData.where((exam) {
        return exam.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
               exam.studentId.contains(searchTerm);
      }).toList();
    }

    // Apply exam filter
    if (selectedExam != 'all') {
      filteredData = filteredData.where((exam) => exam.examId == selectedExam).toList();
    }

    // Apply sorting
    if (sortBy.isNotEmpty) {
      filteredData.sort((a, b) {
        final aValue = a.ranks[sortBy];
        final bValue = b.ranks[sortBy];

        if (aValue == null && bValue == null) return 0;
        if (aValue == null) return 1;
        if (bValue == null) return -1;

        return aValue.compareTo(bValue);
      });
    }

    return filteredData;
  }
} 