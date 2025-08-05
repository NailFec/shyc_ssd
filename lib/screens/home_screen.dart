import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.school_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            const Text(
              '学生考试成绩分析系统',
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              '欢迎使用学生考试成绩分析系统',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '这是一个强大的教育数据分析工具，帮助您深入了解学生的考试成绩表现。',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 48),
                                      Expanded(
               child: GridView.count(
                 crossAxisCount: 3,
                 crossAxisSpacing: 12,
                 mainAxisSpacing: 12,
                 childAspectRatio: 1.2,
                 children: [
                   _buildFeatureCard(
                     context,
                     icon: Icons.analytics_outlined,
                     title: '考试数据',
                     description: '查看详细的考试成绩数据和统计分析',
                     onTap: () => Navigator.pushNamed(context, '/exam-data'),
                   ),
                   _buildFeatureCard(
                     context,
                     icon: Icons.people_outline,
                     title: '学生数据',
                     description: '管理学生信息和班级数据',
                     onTap: () {
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text('功能开发中...')),
                       );
                     },
                   ),
                   _buildFeatureCard(
                     context,
                     icon: Icons.bar_chart_outlined,
                     title: '统计信息',
                     description: '查看成绩统计图表和分析报告',
                     onTap: () {
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text('功能开发中...')),
                       );
                     },
                   ),
                 ],
               ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
               child: Padding(
         padding: const EdgeInsets.all(12.0),
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Icon(
               icon,
               size: 32,
               color: Theme.of(context).colorScheme.primary,
             ),
             const SizedBox(height: 8),
             Text(
               title,
               style: Theme.of(context).textTheme.titleSmall?.copyWith(
                 fontWeight: FontWeight.w600,
               ),
               textAlign: TextAlign.center,
             ),
             const SizedBox(height: 4),
             Text(
               description,
               style: Theme.of(context).textTheme.bodySmall?.copyWith(
                 color: Theme.of(context).colorScheme.onSurfaceVariant,
               ),
               textAlign: TextAlign.center,
               maxLines: 2,
               overflow: TextOverflow.ellipsis,
             ),
           ],
         ),
       ),
      ),
    );
  }
} 