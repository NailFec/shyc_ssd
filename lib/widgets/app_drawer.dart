import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const SizedBox(height: 8),
                Text(
                  '学生考试成绩分析系统',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '教育数据分析平台',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.home_outlined,
                  title: '首页',
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    );
                  },
                ),
                                 _buildDrawerItem(
                   context,
                   icon: Icons.analytics_outlined,
                   title: '考试数据',
                   onTap: () {
                     Navigator.pushNamed(context, '/exam-data');
                   },
                 ),
                 _buildDrawerItem(
                   context,
                   icon: Icons.people_outline,
                   title: '学生数据',
                   onTap: () {
                     Navigator.pushNamed(context, '/student-data');
                   },
                 ),
                 _buildDrawerItem(
                   context,
                   icon: Icons.bar_chart_outlined,
                   title: '统计信息',
                   onTap: () {
                     Navigator.pop(context);
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('功能开发中...')),
                     );
                   },
                 ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  icon: Icons.info_outline,
                  title: '关于系统',
                  onTap: () {
                    Navigator.pushNamed(context, '/about');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      onTap: onTap,
    );
  }
} 