import 'package:flutter/foundation.dart';
import '../models/student_data.dart';
import '../services/student_data_service.dart';

class StudentDataProvider with ChangeNotifier {
  final StudentDataService _service = StudentDataService();
  
  List<StudentData> _allStudents = [];
  List<StudentData> _filteredStudents = [];
  StudentData? _selectedStudent;
  
  String _searchTerm = '';
  
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<StudentData> get allStudents => _allStudents;
  List<StudentData> get filteredStudents => _filteredStudents;
  StudentData? get selectedStudent => _selectedStudent;
  String get searchTerm => _searchTerm;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 加载所有学生数据
  Future<void> loadData() async {
    _setLoading(true);
    _error = null;
    
    try {
      _allStudents = await _service.loadAllStudentData();
      _applyFilters();
      _setLoading(false);
    } catch (e) {
      _error = 'Failed to load student data: $e';
      _setLoading(false);
    }
  }

  // 更新搜索词
  void updateSearchTerm(String term) {
    _searchTerm = term;
    _selectedStudent = null; // 清除选中的学生
    _applyFilters();
  }

  // 选择学生
  void selectStudent(StudentData student) {
    _selectedStudent = student;
    notifyListeners();
  }

  // 清除选中的学生
  void clearSelectedStudent() {
    _selectedStudent = null;
    notifyListeners();
  }

  // 应用过滤器
  void _applyFilters() {
    _filteredStudents = _service.searchStudents(_allStudents, _searchTerm);
    notifyListeners();
  }

  // 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 根据学生ID获取学生
  StudentData? getStudentById(String studentId) {
    return _service.getStudentById(_allStudents, studentId);
  }
} 