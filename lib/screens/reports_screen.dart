import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

// توحيد كلاس الصور لضمان صحة المسارات (بإضافة كلمة images)
class AppImages {
  static const String logoLight = 'assets/images/logo_light.png';
  static const String logoDark = 'assets/images/logo_dark.png';

  static String getLogo(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? logoDark : logoLight;
  }
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // تحسين الأداء: تحميل الصور في الذاكرة مسبقاً لمنع الـ Skipped Frames
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(AppImages.logoLight), context);
    precacheImage(const AssetImage(AppImages.logoDark), context);
  }

  String _generateSmartAdvice(int age, double weight, String type,
      int yearsCount, String treatment, double avg) {
    if (avg > 250) return "high_sugar_msg".tr();
    if (avg < 70 && avg > 0) return "low_sugar_msg".tr();
    if (yearsCount < 1) return "new_warrior_msg".tr();
    if (type == 'Type 2' && weight > 90) return "weight_msg".tr();
    if (type == 'Type 2' && treatment == 'إنسولين') return "insulin_msg".tr();
    if (type == 'Type 1' && age < 25) return "youth_msg".tr();
    return "general_msg".tr();
  }

  String _getAverageAnalysis(double avg, String type) {
    if (avg == 0) return "no_data_msg".tr();
    if (type == 'Type 1') {
      if (avg >= 90 && avg <= 150) return "type1_perfect_plan".tr();
      if (avg < 90) return "type1_low_plan".tr();
      return "type1_high_plan".tr();
    } else {
      if (avg >= 80 && avg <= 130) return "type2_perfect_plan".tr();
      return "type2_warning_plan".tr();
    }
  }

  Future<Map<String, dynamic>> _calculateHealthData(String? uid) async {
    final readingsSnapshot = await FirebaseFirestore.instance
        .collection('readings')
        .where('userId', isEqualTo: uid)
        .get();

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final userData = userDoc.data() ?? {};

    if (readingsSnapshot.docs.isEmpty) {
      return {
        'average': 0.0,
        'max': 0,
        'min': 0,
        'weight': (userData['weight'] ?? 0.0).toDouble(),
        'age': userData['age'] ?? 0,
        'diagnosisYear': userData['diagnosisYear'] ?? DateTime.now().year,
        'diabetesType': userData['diabetesType'] ?? 'Type 1',
        'treatmentType': userData['treatmentType'] ?? 'إنسولين',
      };
    }

    List<double> levels = readingsSnapshot.docs
        .map((doc) => (doc.data()['glucoseLevel'] as num).toDouble())
        .toList();

    double average = levels.reduce((a, b) => a + b) / levels.length;
    levels.sort();

    return {
      'average': average,
      'max': levels.last.toInt(),
      'min': levels.first.toInt(),
      'weight': (userData['weight'] ?? 0.0).toDouble(),
      'age': userData['age'] ?? 0,
      'diagnosisYear': userData['diagnosisYear'] ?? DateTime.now().year,
      'diabetesType': userData['diabetesType'] ?? 'Type 1',
      'treatmentType': userData['treatmentType'] ?? 'إنسولين',
    };
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('report'.tr(),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 6, 0, 59),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Opacity(
              opacity: isDark ? 0.4 : 0.6,
              child: Image.asset(
                // تم تعديل المسار لاستخدام الكلاس الموحد (بكلمة images)
                AppImages.getLogo(context),
                width: 300,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),
          FutureBuilder<Map<String, dynamic>>(
            future: _calculateHealthData(user?.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.blue));
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              final data = snapshot.data!;
              final double avg = data['average'];
              final String diabetesType = data['diabetesType'];
              final int age = data['age'];
              final double weight = data['weight'];
              final int diagYear = data['diagnosisYear'];
              final String treatment = data['treatmentType'];

              int currentYear = DateTime.now().year;
              int yearsCount = currentYear - diagYear;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(context, "Summary_of_the_week".tr()),
                    const SizedBox(height: 15),
                    _buildMainReportCard(avg, diabetesType),
                    _buildWeeklyPlanCard(context, avg, diabetesType),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildSmallStatCard(
                            context,
                            "The_highest_measurement".tr(),
                            "${data['max']}",
                            Icons.trending_up,
                            Colors.red),
                        const SizedBox(width: 15),
                        _buildSmallStatCard(
                            context,
                            "The_lowest_measurement".tr(),
                            "${data['min']}",
                            Icons.trending_down,
                            Colors.blue),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _buildSectionTitle(context, "Heartfelt_chat".tr()),
                    const SizedBox(height: 15),
                    _buildWeightAnalysisCard(context, weight, age, diabetesType,
                        yearsCount, treatment, avg),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPlanCard(BuildContext context, double avg, String type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: Colors.amber.withOpacity(isDark ? 0.3 : 0.5), width: 1.5),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
              ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    shape: BoxShape.circle),
                child: const Icon(Icons.assignment_turned_in_rounded,
                    color: Colors.orange, size: 20),
              ),
              const SizedBox(width: 12),
              Text("Plan_for_next_week".tr(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark
                          ? Colors.amber
                          : const Color.fromARGB(255, 6, 0, 59))),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getAverageAnalysis(avg, type),
            style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(title,
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark
                ? Colors.blueAccent
                : const Color.fromARGB(255, 6, 0, 59)));
  }

  Widget _buildMainReportCard(double avg, String type) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 6, 0, 59),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          Text("Average_measurement".tr(),
              style: const TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 10),
          Text(avg.toStringAsFixed(1),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold)),
          const Text("mg/dL",
              style: TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
                color: Colors.white12, borderRadius: BorderRadius.circular(20)),
            child: Text(
              type == 'Type 1'
                  ? "Type_1_diabetes".tr()
                  : "Type_2_diabetes".tr(),
              style: const TextStyle(
                  color: Colors.amber, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSmallStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: isDark ? Colors.white10 : Colors.black12)),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 10),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 5),
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightAnalysisCard(BuildContext context, double weight, int age,
      String type, int yearsCount, String treatment, double average) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String smartAdvice =
        _generateSmartAdvice(age, weight, type, yearsCount, treatment, average);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05), blurRadius: 10)
                ]),
      child: Row(
        children: [
          CircleAvatar(
              radius: 30,
              backgroundColor: isDark
                  ? Colors.blue.withOpacity(0.1)
                  : const Color(0xFFE3F2FD),
              child: Icon(
                  type == 'Type 1'
                      ? Icons.stars_rounded
                      : Icons.favorite_rounded,
                  color: Colors.blue)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Special_for_you".tr(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark
                            ? Colors.blueAccent
                            : const Color.fromARGB(255, 6, 0, 59))),
                const SizedBox(height: 8),
                Text(smartAdvice,
                    style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: 14,
                        height: 1.5)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
