import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

// توحيد كلاس الصور لضمان صحة المسارات (بإضافة كلمة images)
class AppImages {
  static const String logoLight = 'assets/images/logo_light.png';
  static const String logoDark = 'assets/images/logo_dark.png';

  static String getLogo(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? logoDark : logoLight;
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 4), () {
      _checkUserStatus();
    });
  }

  // تحسين الأداء: تحميل اللوجوهات في الميموري فوراً عند فتح التطبيق
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(AppImages.logoLight), context);
    precacheImage(const AssetImage(AppImages.logoDark), context);
  }

  void _checkUserStatus() {
    final user = FirebaseAuth.instance.currentUser;
    if (mounted) {
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // لون الخلفية ثابت حسب تصميمك (كحلي غامق)
      backgroundColor: const Color.fromARGB(255, 6, 0, 59),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'logo',
              child: Image.asset(
                // تم تعديل المسار باستخدام الميثود الموحدة
                AppImages.getLogo(context),
                width: 220,
                fit: BoxFit.contain,
                // أمان إضافي لمنع الـ Crash
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox(height: 220),
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              color: Color.fromARGB(255, 247, 181, 2),
            ),
            const SizedBox(height: 20),
            const Text(
              'GlucoTrack',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
