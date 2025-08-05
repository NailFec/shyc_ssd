import 'package:flutter/material.dart';
import '../models/student_data.dart';

class StudentRankChart extends StatelessWidget {
  final List<StudentRankPoint> rankHistory;

  const StudentRankChart({
    super.key,
    required this.rankHistory,
  });

  @override
  Widget build(BuildContext context) {
    if (rankHistory.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.show_chart_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  '暂无排名数据',
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '排名变化趋势',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: CustomPaint(
                size: const Size(double.infinity, 200),
                painter: RankChartPainter(
                  rankHistory: rankHistory,
                  colorScheme: Theme.of(context).colorScheme,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem(
          context,
          '最高排名',
          rankHistory.map((p) => p.rank).reduce((a, b) => a < b ? a : b).toString(),
          Colors.green,
        ),
        _buildLegendItem(
          context,
          '最低排名',
          rankHistory.map((p) => p.rank).reduce((a, b) => a > b ? a : b).toString(),
          Colors.red,
        ),
        _buildLegendItem(
          context,
          '平均排名',
          (rankHistory.map((p) => p.rank).reduce((a, b) => a + b) / rankHistory.length)
              .round()
              .toString(),
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class RankChartPainter extends CustomPainter {
  final List<StudentRankPoint> rankHistory;
  final ColorScheme colorScheme;

  RankChartPainter({
    required this.rankHistory,
    required this.colorScheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (rankHistory.isEmpty) return;

    final paint = Paint()
      ..color = colorScheme.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = colorScheme.primary.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final pointPaint = Paint()
      ..color = colorScheme.primary
      ..style = PaintingStyle.fill;

    // 固定排名范围：1到336
    const minRank = 1;
    const maxRank = 336;
    const rankRange = maxRank - minRank;

    // 绘制坐标轴
    final axisPaint = Paint()
      ..color = colorScheme.outline
      ..strokeWidth = 1;

    // Y轴（排名）
    canvas.drawLine(
      Offset(50, 20),
      Offset(50, size.height - 40),
      axisPaint,
    );

    // X轴（时间）
    canvas.drawLine(
      Offset(50, size.height - 40),
      Offset(size.width - 20, size.height - 40),
      axisPaint,
    );

    // 绘制Y轴标签
    final textStyle = TextStyle(
      color: colorScheme.onSurface,
      fontSize: 12,
    );

    // 绘制固定的Y轴标签：1, 84, 168, 252, 336
    final yLabels = [1, 84, 168, 252, 336];
    for (int i = 0; i < yLabels.length; i++) {
      final rank = yLabels[i];
      // Y轴倒置：1在顶部，336在底部
      final y = 20 + (size.height - 60) * (1 - (rank - minRank) / rankRange);
      
      final textSpan = TextSpan(
        text: rank.toString(),
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(10, y - textPainter.height / 2));
    }

    // 绘制数据点和连线
    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < rankHistory.length; i++) {
      final point = rankHistory[i];
      final x = 50 + (size.width - 70) * i / (rankHistory.length - 1);
      // 使用固定的排名范围计算Y坐标，Y轴倒置：1在顶部，336在底部
      final y = 20 + (size.height - 60) * (1 - (point.rank - minRank) / rankRange);

      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // 绘制数据点
      canvas.drawCircle(Offset(x, y), 4, pointPaint);

      // 绘制考试名称
      final examTextSpan = TextSpan(
        text: point.examName,
        style: textStyle.copyWith(fontSize: 10),
      );
      final examTextPainter = TextPainter(
        text: examTextSpan,
        textDirection: TextDirection.ltr,
      );
      examTextPainter.layout();
      
      // 旋转文本以避免重叠
      canvas.save();
      canvas.translate(x, size.height - 20);
      canvas.rotate(-0.5);
      examTextPainter.paint(canvas, Offset(-examTextPainter.width / 2, 0));
      canvas.restore();
    }

    // 绘制填充区域
    final fillPath = Path.from(path);
    fillPath.lineTo(points.last.dx, size.height - 40);
    fillPath.lineTo(points.first.dx, size.height - 40);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // 绘制连线
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 