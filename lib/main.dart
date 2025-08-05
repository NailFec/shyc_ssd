import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/exam_data_provider.dart';
import 'screens/exam_data_screen.dart';
import 'screens/home_screen.dart';
import 'screens/about_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ExamDataProvider(),
      child: MaterialApp(
        title: '学生考试成绩分析系统',
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/exam-data': (context) => const ExamDataScreen(),
          '/about': (context) => const AboutScreen(),
        },
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6750A4), // 更现代的紫色
            brightness: Brightness.light,
          ),
          fontFamily: 'PingFang SC, Microsoft YaHei, sans-serif',
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          cardTheme: const CardThemeData(
            elevation: 2,
            shadowColor: Color(0x1A000000),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
          searchBarTheme: SearchBarThemeData(
            backgroundColor: WidgetStateProperty.all(Colors.grey.shade50),
            elevation: WidgetStateProperty.all(2),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          chipTheme: ChipThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: const Color(0xFF6750A4).withValues(alpha: 0.08),
            selectedColor: const Color(0xFF6750A4),
            labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            side: BorderSide.none,
            elevation: 0,
            pressElevation: 2,
            showCheckmark: false,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
      ),
    );
  }
}
