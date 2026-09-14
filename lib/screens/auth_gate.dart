import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart'; // تأكدي إن اسم شاشة اللوجين عندك كده
import 'home_screen.dart';
import 'role_selection_screen.dart';
import 'caregiver_home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // 1. بنراقب هل اليوزر عامل تسجيل دخول ولا لأ
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // لو لسه بيحمل
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        // لو مش عامل تسجيل دخول أصلاً، نوديه شاشة اللوجين
        if (!authSnapshot.hasData || authSnapshot.data == null) {
          return const LoginScreen(); // 💡 بدليها باسم شاشة الدخول بتاعتك لو مختلفة
        }

        // 2. لو عامل تسجيل دخول، نروح نقرأ بياناته من الفايربيز
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(authSnapshot.data!.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }

            if (userSnapshot.hasData && userSnapshot.data!.exists) {
              final userData =
                  userSnapshot.data!.data() as Map<String, dynamic>;
              final role = userData['role']; // بنقرا الخانة اللي سجلناها

              // 3. التوزيع بناءً على نوع الحساب
              if (role == 'patient') {
                return const HomeScreen(); // شاشة المريض
              } else if (role == 'caregiver') {
                return const CaregiverHomeScreen(); // شاشة المرافق
              }
            }

            // لو مفيش role متسجل (أول مرة يفتح أو حساب جديد)
            return const RoleSelectionScreen();
          },
        );
      },
    );
  }
}
