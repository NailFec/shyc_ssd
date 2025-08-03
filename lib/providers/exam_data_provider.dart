import 'package:flutter/foundation.dart';
import '../models/exam_data.dart';
import '../services/exam_data_service.dart';

class ExamDataProvider with ChangeNotifier {
  final ExamDataService _service = ExamDataService();
  
  Map<String, List<ExamData>> _allData = {};
  Map<String, List<String>> _subjectOrders = {}; // 保存每个考试的科目顺序
  List<ExamData> _filteredData = [];
  ExamStats? _stats;
  
  String _searchTerm = '';
  String _selectedExam = 'all';
  String _sortBy = 'rank-总分';
  
  bool _isLoading = false;
  String? _error;
  
  // Dynamic subjects and sort options
  List<String> _subjects = [];
  List<String> _sortOptions = [];

  // Getters
  Map<String, List<ExamData>> get allData => _allData;
  Map<String, List<String>> get subjectOrders => _subjectOrders;
  List<ExamData> get filteredData => _filteredData;
  ExamStats? get stats => _stats;
  String get searchTerm => _searchTerm;
  String get selectedExam => _selectedExam;
  String get sortBy => _sortBy;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get subjects => _subjects;
  List<String> get sortOptions => _sortOptions;

  // Initialize data
  Future<void> loadData() async {
    _setLoading(true);
    _error = null;
    
    try {
      _allData = {};
      _subjectOrders = {};
      
      for (final exam in ExamDataService.examList) {
        try {
          final result = await _service.loadExamDataWithOrder(exam.id);
          _allData[exam.id] = result['data'] as List<ExamData>;
          _subjectOrders[exam.id] = result['subjectOrder'] as List<String>;
        } catch (e) {
          debugPrint('Error loading exam ${exam.id}: $e');
          _allData[exam.id] = [];
          _subjectOrders[exam.id] = [];
        }
      }
      
      _updateSubjectsAndSortOptions();
      _applyFilters();
      _setLoading(false);
    } catch (e) {
      _error = 'Failed to load data: $e';
      _setLoading(false);
    }
  }

  // Update subjects and sort options based on loaded data
  void _updateSubjectsAndSortOptions() {
    final Set<String> allSubjects = {};
    
    // Collect all subjects from all exam data
    for (final examData in _allData.values) {
      for (final exam in examData) {
        for (final scoreKey in exam.scores.keys) {
          if (scoreKey.startsWith('score-')) {
            final subject = scoreKey.substring(6); // Remove 'score-' prefix
            allSubjects.add(subject);
          }
        }
      }
    }
    
    _subjects = allSubjects.toList()..sort();
    _sortOptions = ExamDataService.getSortOptions(_subjects);
    
    // Update default sort by if current one is not available
    if (!_sortOptions.contains(_sortBy)) {
      _sortBy = _sortOptions.isNotEmpty ? _sortOptions.first : '';
    }
  }

  // Update search term
  void updateSearchTerm(String term) {
    _searchTerm = term;
    _applyFilters();
  }

  // Update selected exam
  void updateSelectedExam(String examId) {
    _selectedExam = examId;
    
    // Update sort by if current one is not available in the new exam
    final currentSortOptions = getCurrentExamSortOptions();
    if (!currentSortOptions.contains(_sortBy)) {
      _sortBy = currentSortOptions.isNotEmpty ? currentSortOptions.first : '';
    }
    
    _applyFilters();
  }

  // Update sort by
  void updateSortBy(String sortBy) {
    _sortBy = sortBy;
    _applyFilters();
  }

  // Apply all filters
  void _applyFilters() {
    List<ExamData> allExamData = [];
    
    if (_selectedExam == 'all') {
      for (final examData in _allData.values) {
        allExamData.addAll(examData);
      }
    } else {
      allExamData = _allData[_selectedExam] ?? [];
    }

    _filteredData = _service.filterData(
      data: allExamData,
      searchTerm: _searchTerm,
      selectedExam: _selectedExam,
      sortBy: _sortBy,
    );

    _stats = ExamStats.fromData(_filteredData);
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Get exam info by ID
  ExamInfo? getExamInfo(String examId) {
    try {
      return ExamDataService.examList.firstWhere((exam) => exam.id == examId);
    } catch (e) {
      return null;
    }
  }

  // Get all exam info
  List<ExamInfo> get allExamInfo => ExamDataService.examList;

  // Get subjects for the currently selected exam
  List<String> getCurrentExamSubjects() {
    if (_selectedExam == 'all') {
      // For "all" exams, return all subjects
      return _subjects;
    }
    
    // For specific exam, get subjects from that exam's data
    final examData = _allData[_selectedExam] ?? [];
    final Set<String> examSubjects = {};
    
    for (final exam in examData) {
      for (final scoreKey in exam.scores.keys) {
        if (scoreKey.startsWith('score-')) {
          final subject = scoreKey.substring(6); // Remove 'score-' prefix
          examSubjects.add(subject);
        }
      }
    }
    
    return examSubjects.toList()..sort();
  }

  // Get subjects for the currently selected exam in CSV order
  List<String> getCurrentExamSubjectsInOrder() {
    if (_selectedExam == 'all') {
      // For "all" exams, return all subjects sorted
      return _subjects;
    }
    
    // For specific exam, return subjects in CSV order
    return _subjectOrders[_selectedExam] ?? [];
  }

  // Get sort options for the currently selected exam
  List<String> getCurrentExamSortOptions() {
    final currentSubjects = getCurrentExamSubjects();
    return ExamDataService.getSortOptions(currentSubjects);
  }
} 