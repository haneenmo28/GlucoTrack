import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.locale.languageCode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment:
                    lang == 'ar' ? Alignment.topLeft : Alignment.topRight,
                child: TextButton.icon(
                  onPressed: () {
                    if (lang == 'ar') {
                      context.setLocale(const Locale('en'));
                    } else {
                      context.setLocale(const Locale('ar'));
                    }
                  },
                  icon:
                      const Icon(Icons.language, color: Colors.teal, size: 20),
                  label: Text(
                    lang == 'ar' ? 'English' : 'عربي',
                    style: const TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                lang == 'ar'
                    ? 'مرحباً بك في GlucoTrack'
                    : 'Welcome to GlucoTrack',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? Colors.white
                      : const Color.fromARGB(255, 6, 0, 59),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                lang == 'ar' ? 'من سيستخدم التطبيق؟' : 'Who is using the app?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 40),
              _buildRoleCard(
                context: context,
                isDark: isDark,
                lang: lang,
                titleAr: 'أنا المريض',
                titleEn: 'I am the Patient',
                descAr: 'أريد تسجيل قراءاتي ومتابعة حالتي',
                descEn: 'I want to log my readings and track my health',
                icon: Icons.person,
                color: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const SignUpScreen(role: 'patient')),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildRoleCard(
                context: context,
                isDark: isDark,
                lang: lang,
                titleAr: 'أنا مُرافق (عائلة/طبيب)',
                titleEn: 'I am a Caregiver',
                descAr: 'أريد متابعة حالة مريض واستقبال الإشعارات',
                descEn: 'I want to monitor a patient and receive alerts',
                icon: Icons.volunteer_activism,
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const SignUpScreen(role: 'caregiver')),
                  );
                },
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
                child: RichText(
                  text: TextSpan(
                    text: lang == 'ar'
                        ? 'لدي حساب بالفعل؟ '
                        : 'Already have an account? ',
                    style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 14),
                    children: [
                      TextSpan(
                        text: lang == 'ar' ? 'تسجيل الدخول' : 'Log in',
                        style: const TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required bool isDark,
    required String lang,
    required String titleAr,
    required String titleEn,
    required String descAr,
    required String descEn,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2A38) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(isDark ? 0.1 : 0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 35),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang == 'ar' ? titleAr : titleEn,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    lang == 'ar' ? descAr : descEn,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              lang == 'ar' ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios,
              color: color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
