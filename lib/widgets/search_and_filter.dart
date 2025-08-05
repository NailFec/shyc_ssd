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
              SearchAnchor(
                builder: (BuildContext context, SearchController controller) {
                  return SearchBar(
                    controller: controller,
                    hintText: '搜索学生姓名或学号...',
                    leading: const Icon(Icons.search),
                    onTap: () {
                      controller.openView();
                    },
                    onChanged: (value) {
                      provider.updateSearchTerm(value);
                    },
                    trailing: <Widget>[
                      if (provider.searchTerm.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            controller.clear();
                            provider.updateSearchTerm('');
                          },
                        ),
                    ],
                    elevation: WidgetStateProperty.resolveWith<double>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.focused)) {
                          return 6.0;
                        }
                        return 1.0;
                      },
                    ),
                    backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                        final colorScheme = Theme.of(context).colorScheme;
                        if (states.contains(WidgetState.focused)) {
                          return colorScheme.surface;
                        }
                        return colorScheme.surfaceContainerHigh;
                      },
                    ),
                    shadowColor: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                        return Theme.of(context).colorScheme.shadow;
                      },
                    ),
                    surfaceTintColor: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                        return Theme.of(context).colorScheme.surfaceTint;
                      },
                    ),
                    overlayColor: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                        final colorScheme = Theme.of(context).colorScheme;
                        if (states.contains(WidgetState.pressed)) {
                          return colorScheme.onSurface.withValues(alpha: 0.1);
                        }
                        if (states.contains(WidgetState.hovered)) {
                          return colorScheme.onSurface.withValues(alpha: 0.08);
                        }
                        return null;
                      },
                    ),
                    side: WidgetStateProperty.resolveWith<BorderSide?>(
                      (Set<WidgetState> states) {
                        return BorderSide.none;
                      },
                    ),
                    shape: WidgetStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.0),
                      ),
                    ),
                    padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    textStyle: WidgetStateProperty.all<TextStyle?>(
                      Theme.of(context).textTheme.bodyLarge,
                    ),
                    hintStyle: WidgetStateProperty.all<TextStyle?>(
                      Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                },
                suggestionsBuilder: (BuildContext context, SearchController controller) {
                  // Return search suggestions based on current exam data
                  if (controller.text.isEmpty) {
                    return <Widget>[];
                  }
                  
                  final suggestions = provider.filteredData
                      .where((student) => 
                          student.name.toLowerCase().contains(controller.text.toLowerCase()) ||
                          student.studentId.toLowerCase().contains(controller.text.toLowerCase()))
                      .map((student) => '${student.name} (${student.studentId})')
                      .toList();
                  
                  return suggestions.map((suggestion) => ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(suggestion),
                    onTap: () {
                      controller.closeView(suggestion);
                      provider.updateSearchTerm(suggestion.split(' ')[0]); // Use just the name
                    },
                  )).toList();
                },
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
        return '六门折算总分';
      case '总分':
        return '总分';
      case '语数英总分':
        return '语数英总分';
      default:
        // Remove 等级 suffix for display if present
        final normalizedSubject = ExamDataService.getNormalizedSubjectName(subject);
        return normalizedSubject;
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