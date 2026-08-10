import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/firebase_service.dart';
import '../models/reading_model.dart';

// توحيد كلاس الصور لضمان عدم حدوث خطأ في المسارات
class AppImages {
  static const String logoLight = 'assets/images/logo_light.png';
  static const String logoDark = 'assets/images/logo_dark.png';

  static String getLogo(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? logoDark : logoLight;
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  // تحسين الأداء: تحميل الصور في ذاكرة الموبايل مسبقاً
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'history'.tr(),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 6, 0, 59),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Opacity(
              opacity: isDark ? 0.4 : 0.6,
              child: Image.asset(
                AppImages.getLogo(context),
                width: 300,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),
          StreamBuilder<List<ReadingModel>>(
            stream: _firebaseService.getReadings(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('error'.tr()));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text('random'.tr(),
                      style: TextStyle(
                          fontSize: 18,
                          color: isDark ? Colors.white70 : Colors.black45)),
                );
              }

              final readings = snapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: readings.length,
                itemBuilder: (context, index) {
                  final reading = readings[index];
                  final status =
                      _getStatusData(reading.glucoseLevel, reading.isFasting);
                  final Color statusColor = status['color'];

                  return Dismissible(
                    key: Key(reading.id ?? index.toString()),
                    direction: DismissDirection.endToStart,

                    // --- إضافة رسالة تأكيد الحذف ---
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor:
                                isDark ? const Color(0xFF1F1F1F) : Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            title: Text(
                              "confirm_delete_title".tr(),
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Text(
                              "confirm_delete_msg".tr(),
                              style: TextStyle(
                                  color:
                                      isDark ? Colors.white70 : Colors.black54),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text("cancel".tr(),
                                    style: const TextStyle(color: Colors.blue)),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text("delete".tr(),
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    // ----------------------------

                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.delete_sweep,
                          color: Colors.white, size: 35),
                    ),
                    onDismissed: (direction) async {
                      if (reading.id != null) {
                        await _firebaseService.deleteReading(reading.id!);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'delete_success'.tr(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor:
                                  const Color.fromARGB(255, 6, 0, 59),
                            ),
                          );
                        }
                      }
                    },
                    child: Card(
                      elevation: 3,
                      color: isDark
                          ? const Color(0xFF1E1E1E)
                          : Colors.white.withOpacity(0.95),
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${reading.glucoseLevel.toInt()}',
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('EEEE, d MMMM',
                                            context.locale.languageCode)
                                        .format(reading.timestamp),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        DateFormat('jm',
                                                context.locale.languageCode)
                                            .format(reading.timestamp),
                                        style: TextStyle(
                                            color: isDark
                                                ? Colors.white54
                                                : Colors.grey[600],
                                            fontSize: 14),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.white10
                                              : Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          reading.isFasting
                                              ? 'fasting'.tr()
                                              : 'Non_fasting'.tr(),
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? Colors.white70
                                                  : Colors.black87),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    status['label'].toString().tr(),
                                    style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  if (reading.note.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Text(
                                        '📝 ${reading.note}',
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: isDark
                                                ? Colors.white60
                                                : Colors.black54),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Icon(
                              status['icon'],
                              color: statusColor,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
