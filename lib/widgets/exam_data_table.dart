import 'package:flutter/material.dart';
import '../models/exam_data.dart';
import '../services/exam_data_service.dart';
import '../providers/exam_data_provider.dart';
import 'package:provider/provider.dart';

class ExamDataTable extends StatefulWidget {
  final List<ExamData> data;

  const ExamDataTable({super.key, required this.data});

  @override
  State<ExamDataTable> createState() => _ExamDataTableState();
}

class _ExamDataTableState extends State<ExamDataTable> {
  static const int _itemsPerPage = 20;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  '没有找到匹配的数据',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final totalPages = (widget.data.length / _itemsPerPage).ceil();
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, widget.data.length);
    final pageData = widget.data.sublist(startIndex, endIndex);

    return Consumer<ExamDataProvider>(
      builder: (context, provider, child) {
        // Get subjects for display in CSV order for the current exam
        final currentSubjects = provider.getCurrentExamSubjectsInOrder();
        
        // Filter out subjects that should not be displayed as individual columns
        final displaySubjects = currentSubjects
            .where((subject) => !['语数英总分', '六门折算总分', '总分'].contains(subject))
            .map((subject) => ExamDataService.getNormalizedSubjectName(subject))
            .toList();

        // Add total score columns at the end
        final totalScoreColumns = <String>[];
        if (currentSubjects.contains('语数英总分')) {
          totalScoreColumns.add('语数英总分');
        }
        if (currentSubjects.contains('六门折算总分')) {
          totalScoreColumns.add('六门折算总分');
        }
        if (currentSubjects.contains('总分')) {
          totalScoreColumns.add('总分');
        }

        return Card(
          elevation: 2,
          child: Column(
            children: [
              // Table Header
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.table_chart,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '考试成绩详情',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '共 ${widget.data.length} 条记录',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Table Content
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    const DataColumn(label: Text('排名')),
                    const DataColumn(label: Text('学号')),
                    const DataColumn(label: Text('姓名')),
                    ...displaySubjects.map((subject) => 
                      DataColumn(label: Text(subject)),
                    ),
                    ...totalScoreColumns.map((subject) => 
                      DataColumn(label: Text(subject)),
                    ),
                  ],
                  rows: pageData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final exam = entry.value;
                    final globalIndex = startIndex + index + 1;
                    
                    return DataRow(
                      cells: [
                        DataCell(Text(globalIndex.toString())),
                        DataCell(Text(exam.studentId)),
                        DataCell(Text(exam.name)),
                        ...displaySubjects.map((subject) => 
                          DataCell(_buildScoreCell(exam, subject)),
                        ),
                        ...totalScoreColumns.map((subject) => 
                          DataCell(_buildScoreCell(exam, subject)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              
              // Pagination
              if (totalPages > 1)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filledTonal(
                        onPressed: _currentPage > 0 ? () {
                          setState(() {
                            _currentPage--;
                          });
                        } : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '第 ${_currentPage + 1} 页，共 $totalPages 页',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: _currentPage < totalPages - 1 ? () {
                          setState(() {
                            _currentPage++;
                          });
                        } : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScoreCell(ExamData exam, String subject) {
    final score = exam.getScore(subject);
    final rank = exam.getRank(subject);
    final grade = exam.getGrade(subject);
    
    if (score == null) {
      return const Text('-');
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 成绩值
        Text(
          score.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        // 等地和排名
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (grade != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: ExamData.getGradeColor(grade),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  grade,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
            if (rank != null)
              Text(
                '第$rank名',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ],
    );
  }
} 