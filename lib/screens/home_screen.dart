import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/firebase_service.dart';
import '../models/reading_model.dart';
import 'package:intl/intl.dart';
import 'profile_screen.dart';

// توحيد كلاس الصور لضمان عدم حدوث خطأ في المسارات
class AppImages {
  static const String logoLight = 'assets/images/logo_light.png';
  static const String logoDark = 'assets/images/logo_dark.png';

  static String getLogo(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? logoDark : logoLight;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // تحسين الأداء: تحميل الصور في ذاكرة الموبايل مسبقاً لمنع الـ Choreographer Skipped frames
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(AppImages.logoLight), context);
    precacheImage(const AssetImage(AppImages.logoDark), context);
  }

  Map<String, dynamic> _getStatusData(double level, bool isFasting) {
    if (level < 70) {
      return {
        'color': Colors.blue,
        'icon': Icons.arrow_downward,
        'label': 'low',
      };
    }

    if (isFasting) {
      if (level >= 70 && level <= 99) {
        return {
          'color': Colors.green,
          'icon': Icons.check_circle,
          'label': 'normal'
        };
      } else if (level >= 100 && level <= 125) {
        return {
          'color': Colors.amber,
          'icon': Icons.info_outline,
          'label': 'normal'
        };
      } else {
        return {
          'color': Colors.red,
          'icon': Icons.arrow_upward,
          'label': 'high'
        };
      }
    } else {
      if (level < 140) {
        return {
          'color': Colors.green,
          'icon': Icons.check_circle,
          'label': 'normal'
        };
      } else if (level >= 140 && level <= 199) {
        return {
          'color': Colors.amber,
          'icon': Icons.info_outline,
          'label': 'normal'
        };
      } else {
        return {
          'color': Colors.red,
          'icon': Icons.arrow_upward,
          'label': 'high'
        };
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Stay CALM, Stay BALANCED ❤️',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 247, 181, 2),
              fontSize: 16,
            )),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 6, 0, 59),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Center(
            child: Opacity(
              opacity: isDark ? 0.4 : 0.6, // تعديل الشفافية
              child: Image.asset(
                // تم تعديل المسار هنا ليستخدم الكلاس الموحد بكلمة images
                AppImages.getLogo(context),
                width: 300,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 6, 0, 59),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        String nameDisplay = "fighter_since".tr();
                        if (snapshot.hasData && snapshot.data!.exists) {
                          final data =
                              snapshot.data!.data() as Map<String, dynamic>;
                          String fullName = data['name'] ?? "";
                          if (fullName.trim().isNotEmpty) {
                            nameDisplay = fullName.trim().split(' ').first;
                          }
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('home_welcome'.tr(),
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 16)),
                            const SizedBox(height: 5),
                            Text('$nameDisplay ❤️',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold)),
                          ],
                        );
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProfileScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(Icons.person_outline_rounded,
                            color: Colors.white, size: 30),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 2.2,
                  children: [
                    _buildMenuButton(context, 'add_reading'.tr(),
                        Icons.add_circle, Colors.teal, '/add'),
                    _buildMenuButton(context, 'history'.tr(), Icons.history,
                        Colors.orange, '/history'),
                    _buildMenuButton(context, 'graph'.tr(), Icons.bar_chart,
                        Colors.blue, '/graph'),
                    _buildMenuButton(context, 'report'.tr(),
                        Icons.analytics_outlined, Colors.purple, '/reports'),
                  ],
                ),
              ),
              const SizedBox(height: 150),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Align(
                  alignment: context.locale.languageCode == 'ar'
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Text('last_reading'.tr(),
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white70
                              : const Color.fromARGB(255, 6, 0, 59))),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<List<ReadingModel>>(
                  stream: _firebaseService.getReadings(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError)
                      return const Center(child: Text('Error'));
                    if (!snapshot.hasData)
                      return const Center(child: CircularProgressIndicator());

                    final readings = snapshot.data!.take(2).toList();
                    if (readings.isEmpty)
                      return Center(child: Text('random'.tr()));

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: readings.length,
                      itemBuilder: (context, index) {
                        final reading = readings[index];
                        final status = _getStatusData(
                            reading.glucoseLevel, reading.isFasting);

                        return Card(
                          color:
                              isDark ? const Color(0xFF1A1D29) : Colors.white,
                          elevation: isDark ? 0 : 3,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(
                              color:
                                  isDark ? Colors.white10 : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: (status['color'] as Color)
                                  .withOpacity(isDark ? 0.15 : 0.1),
                              child:
                                  Icon(status['icon'], color: status['color']),
                            ),
                            title: Text(
                              '${reading.glucoseLevel.toInt()} mg/dL',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: status['color'],
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  status['label'].toString().tr(),
                                  style: TextStyle(
                                    color: status['color'],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  reading.note.isEmpty
                                      ? 'without_notes'.tr()
                                      : reading.note,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Text(
                              DateFormat('jm', context.locale.languageCode)
                                  .format(reading.timestamp),
                              style: TextStyle(
                                color: isDark ? Colors.white38 : Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon,
      Color color, String route) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 5),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
