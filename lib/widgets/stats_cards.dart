import 'package:flutter/material.dart';
import '../models/exam_data.dart';

class StatsCards extends StatelessWidget {
  final ExamStats stats;

  const StatsCards({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        final crossAxisCount = isTablet ? 4 : 2;
        final childAspectRatio = isTablet ? 2.0 : 1.5;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _StatCard(
              title: '总学生数',
              value: stats.totalStudents.toString(),
              icon: Icons.people,
              color: Colors.blue,
            ),
            _StatCard(
              title: '平均总分',
              value: stats.averageTotalScore > 0 
                  ? stats.averageTotalScore.toStringAsFixed(1)
                  : '-',
              icon: Icons.analytics,
              color: Colors.green,
            ),
            _StatCard(
              title: '最高总分',
              value: stats.maxTotalScore > 0 
                  ? stats.maxTotalScore.toStringAsFixed(1)
                  : '-',
              icon: Icons.trending_up,
              color: Colors.orange,
            ),
            _StatCard(
              title: '最低总分',
              value: stats.minTotalScore > 0 
                  ? stats.minTotalScore.toStringAsFixed(1)
                  : '-',
              icon: Icons.trending_down,
              color: Colors.red,
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 