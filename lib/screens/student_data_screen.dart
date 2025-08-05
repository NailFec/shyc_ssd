import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_data_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/student_rank_chart.dart';
import '../widgets/student_exam_detail.dart';

class StudentDataScreen extends StatefulWidget {
  const StudentDataScreen({super.key});

  @override
  State<StudentDataScreen> createState() => _StudentDataScreenState();
}

class _StudentDataScreenState extends State<StudentDataScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentDataProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.people_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            const Text(
              '学生数据',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/about');
              },
              icon: Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              tooltip: '关于系统',
            ),
          ),
        ],
      ),
      body: Consumer<StudentDataProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator.adaptive(),
                  SizedBox(height: 16),
                  Text('正在加载学生数据...'),
                ],
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '数据加载失败',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => provider.loadData(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('重新加载'),
                  ),
                ],
              ),
            );
          }

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 欢迎信息卡片
                  Card(
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.person_search,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '学生个人数据分析',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '查看学生的成绩趋势和详细考试记录',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // 搜索部分
                  _buildSearchSection(context, provider),
                  
                  const SizedBox(height: 24),
                  
                  // 学生列表或选中学生的详情
                  if (provider.selectedStudent != null)
                    _buildStudentDetail(context, provider.selectedStudent!)
                  else
                    _buildStudentList(context, provider),
                  
                  // 底部间距
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context, StudentDataProvider provider) {
    return SizedBox(
      width: double.infinity, // 占满可用宽度
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '搜索学生',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
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
                    elevation: MaterialStateProperty.resolveWith<double>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.focused)) {
                          return 6.0;
                        }
                        return 1.0;
                      },
                    ),
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        final colorScheme = Theme.of(context).colorScheme;
                        if (states.contains(MaterialState.focused)) {
                          return colorScheme.surface;
                        }
                        return colorScheme.surfaceContainerHigh;
                      },
                    ),
                    shadowColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        return Theme.of(context).colorScheme.shadow;
                      },
                    ),
                    surfaceTintColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        return Theme.of(context).colorScheme.surfaceTint;
                      },
                    ),
                    overlayColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        final colorScheme = Theme.of(context).colorScheme;
                        if (states.contains(MaterialState.pressed)) {
                          return colorScheme.onSurface.withOpacity(0.1);
                        }
                        if (states.contains(MaterialState.hovered)) {
                          return colorScheme.onSurface.withOpacity(0.08);
                        }
                        return null;
                      },
                    ),
                    side: MaterialStateProperty.resolveWith<BorderSide?>(
                      (Set<MaterialState> states) {
                        return BorderSide.none;
                      },
                    ),
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.0),
                      ),
                    ),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    textStyle: MaterialStateProperty.all<TextStyle?>(
                      Theme.of(context).textTheme.bodyLarge,
                    ),
                    hintStyle: MaterialStateProperty.all<TextStyle?>(
                      Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                },
                suggestionsBuilder: (BuildContext context, SearchController controller) {
                  if (controller.text.isEmpty) {
                    return <Widget>[];
                  }
                  
                  final suggestions = provider.filteredStudents
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
                      final studentName = suggestion.split(' ')[0];
                      final student = provider.filteredStudents.firstWhere(
                        (s) => s.name == studentName,
                      );
                      provider.selectStudent(student);
                    },
                  )).toList();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentList(BuildContext context, StudentDataProvider provider) {
    if (provider.filteredStudents.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
                  provider.searchTerm.isEmpty ? '暂无学生数据' : '未找到匹配的学生',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '学生列表',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...provider.filteredStudents.map((student) => _buildStudentCard(context, student)),
      ],
    );
  }

  Widget _buildStudentCard(BuildContext context, student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            student.name[0],
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          student.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '学号: ${student.studentId}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 16,
        ),
        onTap: () {
          context.read<StudentDataProvider>().selectStudent(student);
        },
      ),
    );
  }

  Widget _buildStudentDetail(BuildContext context, student) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 学生信息头部
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    student.name[0],
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '学号: ${student.studentId}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    context.read<StudentDataProvider>().clearSelectedStudent();
                  },
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  tooltip: '返回学生列表',
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // 排名变化趋势图
        StudentRankChart(rankHistory: student.getRankHistory()),
        
        const SizedBox(height: 24),
        
        // 考试记录
        Text(
          '考试记录',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        ...student.getExamRecordsSorted().map((examRecord) => 
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: StudentExamDetail(examRecord: examRecord),
          ),
        ),
      ],
    );
  }
} 