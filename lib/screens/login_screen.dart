import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';

// توحيد كلاس الصور لضمان عدم حدوث خطأ في المسارات (بإضافة كلمة images)
class AppImages {
  static const String logoLight = 'assets/images/logo_light.png';
  static const String logoDark = 'assets/images/logo_dark.png';

  static String getLogo(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? logoDark : logoLight;
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // تحسين الأداء: تحميل الصور في الذاكرة مسبقاً لمنع أي تهنيج عند فتح التطبيق
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(AppImages.logoLight), context);
    precacheImage(const AssetImage(AppImages.logoDark), context);
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("enter_credentials").tr()),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'حدث خطأ ما';
      if (e.code == 'user-not-found') {
        message = 'user_not_found'.tr();
      } else if (e.code == 'wrong-password') {
        message = 'wrong_password_msg'.tr();
      } else if (e.code == 'invalid-email') {
        message = 'email'.tr();
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    // تم تعديل المسار لاستخدام الكلاس الموحد (حل مشكلة File not found)
                    AppImages.getLogo(context),
                    height: 250,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox(height: 250),
                  ),
                  const SizedBox(height: 25),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'email'.tr(),
                      labelStyle: TextStyle(
                          color: isDark
                              ? Colors.white70
                              : const Color.fromARGB(255, 6, 0, 59)),
                      prefixIcon: Icon(Icons.email,
                          color: isDark
                              ? Colors.blueAccent
                              : const Color.fromARGB(255, 6, 0, 59)),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF1E1E1E)
                          : Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'password'.tr(),
                      labelStyle: TextStyle(
                          color: isDark
                              ? Colors.white70
                              : const Color.fromARGB(255, 6, 0, 59)),
                      prefixIcon: Icon(Icons.lock,
                          color: isDark
                              ? Colors.blueAccent
                              : const Color.fromARGB(255, 6, 0, 59)),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF1E1E1E)
                          : Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? Colors.blueAccent
                            : const Color.fromARGB(255, 6, 0, 59),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(
                              'log_in'.tr(),
                              style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                    child: Text(
                      'don\'t_have_account'.tr(),
                      style: TextStyle(
                          color: isDark
                              ? Colors.white70
                              : const Color.fromARGB(255, 6, 0, 59),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // زرار الترجمة العايم
          Positioned(
            top: 50,
            right: context.locale == const Locale('ar') ? null : 20,
            left: context.locale == const Locale('ar') ? 20 : null,
            child: InkWell(
              onTap: () {
                if (context.locale == const Locale('ar')) {
                  context.setLocale(const Locale('en'));
                } else {
                  context.setLocale(const Locale('ar'));
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white10
                      : const Color.fromARGB(255, 6, 0, 59).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: isDark
                          ? Colors.blueAccent
                          : const Color.fromARGB(255, 6, 0, 59),
                      width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.language,
                        size: 18,
                        color: isDark
                            ? Colors.blueAccent
                            : const Color.fromARGB(255, 6, 0, 59)),
                    const SizedBox(width: 8),
                    Text(
                      context.locale == const Locale('ar')
                          ? "English"
                          : "العربية",
                      style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color.fromARGB(255, 6, 0, 59),
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
