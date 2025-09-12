import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_data_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/student_rank_chart.dart';
import '../widgets/student_exam_detail.dart';
import '../widgets/student_avatar.dart';

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
                  if (controller.text.isEmpty) {
                    return <Widget>[];
                  }
                  final lower = controller.text.toLowerCase();
                  final matches = provider.filteredStudents
                      .where((s) => s.name.toLowerCase().contains(lower) || s.studentId.toLowerCase().contains(lower))
                      .toList();
                  return matches.map((student) => ListTile(
                    leading: StudentAvatar(studentId: student.studentId, name: student.name, size: 28),
                    title: Text('${student.name} (${student.studentId})'),
                    onTap: () {
                      controller.closeView('${student.name} (${student.studentId})');
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
      child: InkWell(
        borderRadius: BorderRadius.circular(12), // 设置圆角
        onTap: () {
          context.read<StudentDataProvider>().selectStudent(student);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const SizedBox(width: 2),
              StudentAvatar(studentId: student.studentId, name: student.name, size: 36),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '学号: ${student.studentId}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 16,
              ),
            ],
          ),
        ),
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
                StudentAvatar(studentId: student.studentId, name: student.name, size: 60),
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