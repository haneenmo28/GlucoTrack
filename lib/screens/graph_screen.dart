import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/firebase_service.dart';
import '../models/reading_model.dart';
import 'package:intl/intl.dart';

// كلاس الصور لتوحيد المسارات ومنع أخطاء الـ "File not found"
class AppImages {
  static const String logoLight = 'assets/images/logo_light.png';
  static const String logoDark = 'assets/images/logo_dark.png';

  static String getLogo(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? logoDark : logoLight;
  }
}

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  // تحسين الأداء: تحميل الصور مسبقاً في الذاكرة
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(AppImages.logoLight), context);
    precacheImage(const AssetImage(AppImages.logoDark), context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('graph'.tr(),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 6, 0, 59),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<ReadingModel>>(
        stream: _firebaseService.getReadings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.blue));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'random'.tr(),
                style: TextStyle(
                    color: isDark
                        ? Colors.white70
                        : Colors.black54, // تعديل بسيط لضمان الرؤية
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            );
          }

          final sortedReadings = List<ReadingModel>.from(snapshot.data!)
            ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

          final readings = sortedReadings.length > 7
              ? sortedReadings.sublist(sortedReadings.length - 7)
              : sortedReadings;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              // إضافة لضمان عدم حدوث Overflow في الشاشات الصغيرة
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E1E1E)
                          : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isDark
                          ? []
                          : [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10)
                            ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Blood_sugar_level_in_the_last_7_measurements'.tr(),
                          style: TextStyle(
                            color: isDark
                                ? Colors.blueAccent
                                : const Color.fromARGB(255, 6, 0, 59),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        AspectRatio(
                          aspectRatio: 1.3,
                          child: LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: false),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    getTitlesWidget: (value, meta) {
                                      int index = value.toInt();
                                      if (index < 0 || index >= readings.length)
                                        return const SizedBox();
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        child: Text(
                                          DateFormat('d/M',
                                                  context.locale.languageCode)
                                              .format(
                                                  readings[index].timestamp),
                                          style: TextStyle(
                                              color: isDark
                                                  ? Colors.white60
                                                  : Colors.black87,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white60
                                              : Colors.black54,
                                          fontSize: 10,
                                        ),
                                      );
                                    },
                                    reservedSize: 28,
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: readings.asMap().entries.map((e) {
                                    return FlSpot(
                                        e.key.toDouble(), e.value.glucoseLevel);
                                  }).toList(),
                                  isCurved: true,
                                  color: isDark
                                      ? Colors.blue
                                      : const Color.fromARGB(255, 6, 0, 59),
                                  barWidth: 4,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) =>
                                            FlDotCirclePainter(
                                      radius: 4,
                                      color: isDark
                                          ? Colors.white
                                          : const Color.fromARGB(255, 6, 0, 59),
                                      strokeWidth: 2,
                                      strokeColor: Colors.blue,
                                    ),
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: (isDark
                                            ? Colors.blue
                                            : const Color.fromARGB(
                                                255, 6, 0, 59))
                                        .withOpacity(0.1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Image.asset(
                      // تم التعديل هنا لاستخدام المسار الصحيح من الكلاس
                      AppImages.getLogo(context),
                      width: 200,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLegend(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insights,
              color: isDark
                  ? Colors.blueAccent
                  : const Color.fromARGB(255, 6, 0, 59)),
          const SizedBox(width: 10),
          Text(
            'Glucose_level'.tr(),
            style: TextStyle(
              color:
                  isDark ? Colors.white70 : const Color.fromARGB(255, 6, 0, 59),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
