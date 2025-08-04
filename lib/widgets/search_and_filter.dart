import 'package:flutter/material.dart';
import '../providers/exam_data_provider.dart';
import '../services/exam_data_service.dart';

class SearchAndFilterSection extends StatelessWidget {
  final ExamDataProvider provider;

  const SearchAndFilterSection({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // 占满可用宽度
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Section
              SearchBar(
                hintText: '搜索学生姓名或学号...',
                leading: const Icon(Icons.search),
                onChanged: (value) => provider.updateSearchTerm(value),
              ),
              
              const SizedBox(height: 16),
              
              // Exam Filter Chips
              Text(
                '选择考试',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterChip(
                    label: '全部考试',
                    selected: provider.selectedExam == 'all',
                    onSelected: (selected) {
                      if (selected) provider.updateSelectedExam('all');
                    },
                  ),
                  ...provider.allExamInfo.map((exam) => _FilterChip(
                    label: exam.name,
                    selected: provider.selectedExam == exam.id,
                    onSelected: (selected) {
                      if (selected) provider.updateSelectedExam(exam.id);
                    },
                  )),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Sort Section with Chips
              Text(
                '排序方式',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...provider.getCurrentExamSortOptions().map((sortOption) {
                    final subject = sortOption.substring(5); // Remove 'rank-' prefix
                    final displayName = _getSortDisplayName(subject);
                    
                    return _FilterChip(
                      label: displayName,
                      selected: provider.sortBy == sortOption,
                      onSelected: (selected) {
                        if (selected) provider.updateSortBy(sortOption);
                      },
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSortDisplayName(String subject) {
    // Handle special cases
    switch (subject) {
      case '六门折算总分':
        return '按六门折算总分排名';
      case '总分':
        return '按总分排名';
      case '语数英总分':
        return '按语数英总分排名';
      default:
        // Remove 等级 suffix for display if present
        final normalizedSubject = ExamDataService.getNormalizedSubjectName(subject);
        return '按$normalizedSubject排名';
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected 
            ? colorScheme.onPrimary 
            : colorScheme.onSurface,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          fontSize: 14,
        ),
      ),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
      selectedColor: colorScheme.primary,
      backgroundColor: colorScheme.surfaceContainerHighest,
      checkmarkColor: colorScheme.onPrimary,
      elevation: selected ? 3 : 0,
      pressElevation: 6,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      avatar: selected ? Icon(
        Icons.check,
        size: 16,
        color: colorScheme.onPrimary,
      ) : null,
    );
  }
} 