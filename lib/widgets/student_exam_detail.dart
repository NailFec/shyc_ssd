import 'package:flutter/material.dart';
import '../models/student_data.dart';
import '../models/exam_data.dart';

class StudentExamDetail extends StatelessWidget {
  final StudentExamRecord examRecord;

  const StudentExamDetail({
    super.key,
    required this.examRecord,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 考试标题和总分信息
            Row(
              children: [
                Text(
                  examRecord.examName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                _buildTotalScoreCard(context),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // 科目成绩表格
            Text(
              '各科成绩详情',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            // 科目成绩水平排列
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: examRecord.getSubjects().map((subject) => 
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: _buildSubjectCard(context, subject),
                  ),
                ).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalScoreCard(BuildContext context) {
    final totalRank = examRecord.totalRank;
    final totalGrade = examRecord.totalGrade;

    if (totalRank == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '无排名数据',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Row(
      children: [
        // 排名
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '第$totalRank名',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        
        // 等地
        if (totalGrade != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: ExamData.getGradeColor(totalGrade),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              totalGrade,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubjectCard(BuildContext context, String subject) {
    final score = examRecord.getScore(subject);
    final rank = examRecord.getRank(subject);
    final grade = examRecord.getGrade(subject);

    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 科目名称
          Text(
            subject,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          
          // 成绩 - 更大字体
          Text(
            score?.toStringAsFixed(1) ?? '--',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: score != null ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // 排名和等地在同一行
          Row(
            children: [
              // 排名
              Expanded(
                child: Text(
                  rank != null ? '第$rank名' : '--',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: rank != null ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              // 等地
              if (grade != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: ExamData.getGradeColor(grade),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    grade,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }


} 