import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum TimeRange {
  day,
  week,
  month,
  threeMonths,
  sixMonths,
  year,
  threeYears,
  fiveYears,
}

class PriceHistoryChart extends StatefulWidget {
  final List<FlSpot> yesData;
  final List<FlSpot> noData;
  final double height;
  final double minY;
  final double maxY;

  const PriceHistoryChart({
    super.key,
    required this.yesData,
    required this.noData,
    this.height = 250,
    required this.minY,
    required this.maxY,
  });

  @override
  State<PriceHistoryChart> createState() => _PriceHistoryChartState();
}

class _PriceHistoryChartState extends State<PriceHistoryChart> {
  TimeRange _selectedTimeRange = TimeRange.month;
  late List<FlSpot> _filteredYesData;
  late List<FlSpot> _filteredNoData;
  late double _minX;
  late double _maxX;

  @override
  void initState() {
    super.initState();
    _filterDataByTimeRange();
  }

  void _filterDataByTimeRange() {
    if (widget.yesData.isEmpty || widget.noData.isEmpty) {
      _filteredYesData = widget.yesData;
      _filteredNoData = widget.noData;
      _minX = 0;
      _maxX = 30;
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch.toDouble();
    double cutoff;

    switch (_selectedTimeRange) {
      case TimeRange.day:
        cutoff = now - const Duration(days: 1).inMilliseconds.toDouble();
        break;
      case TimeRange.week:
        cutoff = now - const Duration(days: 7).inMilliseconds.toDouble();
        break;
      case TimeRange.month:
        cutoff = now - const Duration(days: 30).inMilliseconds.toDouble();
        break;
      case TimeRange.threeMonths:
        cutoff = now - const Duration(days: 90).inMilliseconds.toDouble();
        break;
      case TimeRange.sixMonths:
        cutoff = now - const Duration(days: 180).inMilliseconds.toDouble();
        break;
      case TimeRange.year:
        cutoff = now - const Duration(days: 365).inMilliseconds.toDouble();
        break;
      case TimeRange.threeYears:
        cutoff = now - const Duration(days: 365 * 3).inMilliseconds.toDouble();
        break;
      case TimeRange.fiveYears:
        cutoff = now - const Duration(days: 365 * 5).inMilliseconds.toDouble();
        break;
    }

    _filteredYesData = widget.yesData
        .where((spot) => spot.x >= cutoff)
        .toList();

    _filteredNoData = widget.noData
        .where((spot) => spot.x >= cutoff)
        .toList();

    // If no data points match the filter, show all data
    if (_filteredYesData.isEmpty) {
      _filteredYesData = widget.yesData;
    }
    if (_filteredNoData.isEmpty) {
      _filteredNoData = widget.noData;
    }

    // Get min and max X values for the chart
    final allData = [..._filteredYesData, ..._filteredNoData];
    if (allData.isNotEmpty) {
      _minX = allData.map((spot) => spot.x).reduce((a, b) => a < b ? a : b);
      _maxX = allData.map((spot) => spot.x).reduce((a, b) => a > b ? a : b);
    } else {
      _minX = 0;
      _maxX = 30;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final gridColor = isDarkMode ? AppTheme.darkGrey : AppTheme.lightGrey;
    final labelColor = isDarkMode ? AppTheme.grey : AppTheme.textSecondary;

    return Column(
      children: [
        Container(
          height: widget.height,
          padding: const EdgeInsets.only(right: 16, top: 16),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 0.1,
                verticalInterval: (_maxX - _minX) / 5,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: gridColor,
                    strokeWidth: 0.5,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: gridColor,
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
                    getTitlesWidget: (value, meta) {
                      final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                      String text;
                      
                      if (_selectedTimeRange == TimeRange.day) {
                        // Show hours for 1-day view
                        text = '${date.hour}:00';
                      } else if (_selectedTimeRange == TimeRange.week) {
                        // Show day of week for 1-week view
                        text = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
                      } else {
                        // Show date for longer periods
                        text = '${date.day}/${date.month}';
                        if (_selectedTimeRange == TimeRange.year || 
                            _selectedTimeRange == TimeRange.threeYears || 
                            _selectedTimeRange == TimeRange.fiveYears) {
                          text = '${date.month}/${date.year.toString().substring(2)}';
                        }
                      }
                      
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        angle: 0,
                        child: Text(
                          text,
                          style: TextStyle(
                            color: labelColor,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                    interval: (_maxX - _minX) / 5,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        angle: 0,
                        child: Text(
                          '${(value * 100).toInt()}',
                          style: TextStyle(
                            color: labelColor,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                    reservedSize: 36,
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: gridColor),
                  left: BorderSide(color: gridColor),
                ),
              ),
              minX: _minX,
              maxX: _maxX,
              minY: widget.minY,
              maxY: widget.maxY,
              lineBarsData: [
                // Yes price line
                LineChartBarData(
                  spots: _filteredYesData,
                  isCurved: true,
                  color: AppTheme.positiveColor,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: false,
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppTheme.positiveColor.withOpacity(0.1),
                  ),
                ),
                // No price line
                LineChartBarData(
                  spots: _filteredNoData,
                  isCurved: true,
                  color: AppTheme.negativeColor,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: false,
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppTheme.negativeColor.withOpacity(0.1),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: isDarkMode ? AppTheme.darkGrey : AppTheme.white,
                  tooltipRoundedRadius: 8,
                  getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                    return touchedBarSpots.map((barSpot) {
                      final date = DateTime.fromMillisecondsSinceEpoch(barSpot.x.toInt());
                      final dateStr = '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
                      final price = (barSpot.y * 100).toStringAsFixed(2);
                      final isYesLine = barSpot.barIndex == 0;
                      
                      return LineTooltipItem(
                        '${isYesLine ? 'Yes' : 'No'}: ₹$price\n$dateStr',
                        TextStyle(
                          color: isYesLine ? AppTheme.positiveColor : AppTheme.negativeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Legend
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Yes', AppTheme.positiveColor),
              const SizedBox(width: 24),
              _buildLegendItem('No', AppTheme.negativeColor),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Time range selector
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildTimeRangeButton('1D', TimeRange.day),
              _buildTimeRangeButton('1W', TimeRange.week),
              _buildTimeRangeButton('1M', TimeRange.month),
              _buildTimeRangeButton('3M', TimeRange.threeMonths),
              _buildTimeRangeButton('6M', TimeRange.sixMonths),
              _buildTimeRangeButton('1Y', TimeRange.year),
              _buildTimeRangeButton('3Y', TimeRange.threeYears),
              _buildTimeRangeButton('5Y', TimeRange.fiveYears),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeRangeButton(String text, TimeRange range) {
    final isSelected = _selectedTimeRange == range;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedTimeRange = range;
            _filterDataByTimeRange();
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? AppTheme.primaryColor : Colors.transparent,
          foregroundColor: isSelected ? AppTheme.white : AppTheme.primaryColor,
          elevation: isSelected ? 2 : 0,
          side: BorderSide(
            color: isSelected ? AppTheme.primaryColor : AppTheme.grey.withOpacity(0.3),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: const Size(40, 32),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
} 