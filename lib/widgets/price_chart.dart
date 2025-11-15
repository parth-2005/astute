import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PriceChart extends StatefulWidget {
  final List<FlSpot> data;
  final Color color;
  final double height;

  const PriceChart({
    super.key,
    required this.data,
    required this.color,
    this.height = 250,
  });

  @override
  State<PriceChart> createState() => _PriceChartState();
}

class _PriceChartState extends State<PriceChart> {
  String _selectedTimeframe = '1M';
  List<String> _timeframes = ['1D', '5D', '1M', '6M', 'YTD', '1Y', '3Y', '5Y'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 50,
                  verticalInterval: 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.dividerColor,
                      strokeWidth: 0.5,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: AppTheme.dividerColor,
                      strokeWidth: 0.5,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 5,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() % 5 != 0) {
                          return const SizedBox.shrink();
                        }
                        
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 8.0,
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 50,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 8.0,
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                minX: 0,
                maxX: widget.data.length.toDouble() - 1,
                minY: widget.data
                        .map((spot) => spot.y)
                        .reduce((a, b) => a < b ? a : b) -
                    20,
                maxY: widget.data
                        .map((spot) => spot.y)
                        .reduce((a, b) => a > b ? a : b) +
                    20,
                lineBarsData: [
                  LineChartBarData(
                    spots: widget.data,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        widget.color.withOpacity(0.8),
                        widget.color,
                      ],
                    ),
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: false,
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          widget.color.withOpacity(0.2),
                          widget.color.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: _timeframes.map((timeframe) {
              final isSelected = _selectedTimeframe == timeframe;
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTimeframe = timeframe;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? widget.color.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? widget.color
                            : AppTheme.dividerColor,
                      ),
                    ),
                    child: Text(
                      timeframe,
                      style: TextStyle(
                        color: isSelected
                            ? widget.color
                            : AppTheme.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
} 