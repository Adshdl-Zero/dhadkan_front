import 'package:dhadkan_front/utils/constants/colors.dart';
import 'package:dhadkan_front/utils/device/device_utility.dart';
import 'package:dhadkan_front/utils/helpers/helper_functions.dart';
import 'package:dhadkan_front/utils/theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Graph extends StatelessWidget {
  final List<double> times, diastolic, systolic, weight;
  final double width;

  const Graph(
      {super.key,
      required this.times,
      required this.diastolic,
      required this.systolic,
      required this.weight,
      required this.width});

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        SizedBox(
          width: width,
          height: 140,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(
                  show: true, horizontalInterval: 40, verticalInterval: 40),
              titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true,
                        interval: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}',
                            style: MyTextTheme.textTheme.bodySmall,
                            // overflow: TextOverflow.fade, // Prevent overflow
                          );
                        }),
                  ),
                  bottomTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                        interval: 40,
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Row(
                            children: [
                              const SizedBox(width: 2),
                              Text('${value.toInt()}',
                                  style: MyTextTheme.textTheme.bodySmall)
                            ],
                          );
                        }),
                  )),
              borderData: FlBorderData(
                show: true,
                border: const Border.symmetric(
                    horizontal: BorderSide(
                        color: Colors.transparent, // Make borders invisible
                        width: 0),
                    vertical: BorderSide(color: Colors.black54, width: 1)),
              ),

              lineBarsData: [
                _buildLineChartBarData(
                    times, systolic, MyColors.sColor, 'Systolic', true),
                _buildLineChartBarData(
                    times, diastolic, MyColors.dColor, 'Diastolic', true),
                _buildLineChartBarData(
                    times, weight, MyColors.weightColor, 'Weight', true),
              ],
              minY: 30,
              // Set minimum value of y-axis (for weight)
              maxY: 180, // Set maximum value of y-axis (for systolic)
            ),
          ),
        ),
        const SizedBox(height: 15),
        Row(children: [
          SizedBox(
            width: 300,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(MyColors.sColor, 'Systolic BP'),
                _buildLegendItem(MyColors.dColor, 'Diastolic BP'),
                _buildLegendItem(MyColors.weightColor, 'Weight'),
              ],
            ),
          ),
          const Spacer(),
        ])
      ],
    );
  }

  LineChartBarData _buildLineChartBarData(List<double> xValues,
      List<double> yValues, Color color, String label, bool showDots) {
    return LineChartBarData(
      spots: List.generate(
        xValues.length,
        (index) => FlSpot(xValues[index], yValues[index]),
      ),
      color: color,
      isCurved: false,
      // colors: [color],
      barWidth: 2,

      dotData: FlDotData(
        show: showDots,
        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
          radius: 3,
          color: Colors.white,
          strokeWidth: 1.5, // Border width
          strokeColor: color, // Border color
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 14,
          height: 14,
          color: color, // Color box for the legend
        ),
        const SizedBox(width: 4),
        Text(label, style: MyTextTheme.textTheme.bodySmall), // Legend label
      ],
    );
  }
}
