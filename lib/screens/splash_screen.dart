import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'role_selection_screen.dart';
import 'caregiver_home_screen.dart';

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(AppImages.logoLight), context);
    precacheImage(const AssetImage(AppImages.logoDark), context);
  }

  Future<void> _checkUserStatus() async {
    final user = FirebaseAuth.instance.currentUser;

    if (mounted) {
      if (user != null) {
        try {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (mounted) {
            if (doc.exists && doc.data()!.containsKey('role')) {
              final role = doc.get('role');
              if (role == 'caregiver') {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CaregiverHomeScreen()));
              } else {
                Navigator.pushReplacementNamed(context, '/home');
              }
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          }
        } catch (e) {
          if (mounted) Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const RoleSelectionScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 6, 0, 59),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'logo',
              child: Image.asset(
                AppImages.getLogo(context),
                width: 220,
                fit: BoxFit.contain,
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
