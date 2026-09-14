import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

import 'caregiver_home_screen.dart';
import 'role_selection_screen.dart';

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(AppImages.logoLight), context);
    precacheImage(const AssetImage(AppImages.logoDark), context);
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("enter_credentials".tr())),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      debugPrint(
          "Login Attempt -> Email: [${_emailController.text}] | Password: [${_passwordController.text}]");

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!mounted) return;

        if (doc.exists &&
            doc.data() != null &&
            doc.data()!.containsKey('role')) {
          final role = doc.data()!['role'];

          if (role == 'caregiver') {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const CaregiverHomeScreen()));
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Auth Error: ${e.code}");

      bool isAr = context.locale == const Locale('ar');
      String message = isAr
          ? 'حدث خطأ أثناء تسجيل الدخول'
          : 'An error occurred during login';

      if (e.code == 'invalid-credential' ||
          e.code == 'wrong-password' ||
          e.code == 'user-not-found') {
        message = isAr
            ? 'البريد الإلكتروني أو كلمة المرور غير صحيحة'
            : 'Email or password is incorrect';
      } else if (e.code == 'invalid-email') {
        message =
            isAr ? 'صيغة البريد الإلكتروني غير صحيحة' : 'Invalid email format';
      } else if (e.code == 'network-request-failed') {
        message = isAr
            ? 'تأكد من اتصالك بالإنترنت وحاول مجدداً'
            : 'Check your internet connection and try again';
      }

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      debugPrint("General Error: $e");
      if (mounted) {
        bool isAr = context.locale == const Locale('ar');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isAr
              ? 'خطأ غير متوقع، يرجى المحاولة مرة أخرى'
              : 'An unexpected error occurred, please try again'),
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController =
        TextEditingController(text: _emailController.text.trim());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          context.locale == const Locale('ar')
              ? "استعادة كلمة المرور"
              : "Reset Password",
          style: TextStyle(
            color: isDark ? Colors.white : const Color.fromARGB(255, 6, 0, 59),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.locale == const Locale('ar')
                  ? "أدخل بريدك الإلكتروني وسنرسل لك رابطاً لتعيين كلمة مرور جديدة."
                  : "Enter your email and we will send you a password reset link.",
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'email'.tr(),
                prefixIcon: const Icon(Icons.email_outlined),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.locale == const Locale('ar') ? "إلغاء" : "Cancel",
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.locale == const Locale('ar')
                        ? "يرجى كتابة البريد الإلكتروني"
                        : "Please enter your email"),
                  ),
                );
                return;
              }

              try {
                await FirebaseAuth.instance
                    .sendPasswordResetEmail(email: email);
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.green,
                      content: Text(context.locale == const Locale('ar')
                          ? "تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني"
                          : "Password reset link sent to your email"),
                    ),
                  );
                }
              } on FirebaseAuthException catch (e) {
                String errorMsg = context.locale == const Locale('ar')
                    ? "حدث خطأ"
                    : "An error occurred";
                if (e.code == 'user-not-found') {
                  errorMsg = context.locale == const Locale('ar')
                      ? "هذا الحساب غير مسجل "
                      : "User not found";
                } else if (e.code == 'invalid-email') {
                  errorMsg = context.locale == const Locale('ar')
                      ? "صيغة البريد غير صحيحة"
                      : "Invalid email format";
                }
                if (mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(errorMsg)));
                }
              } catch (_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.locale == const Locale('ar')
                          ? "تعذر إرسال البريد، يرجى المحاولة لاحقاً"
                          : "Could not send email, please try again later"),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? Colors.blueAccent
                  : const Color.fromARGB(255, 6, 0, 59),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              context.locale == const Locale('ar') ? "إرسال" : "Send",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
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
                    AppImages.getLogo(context),
                    height: 220,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox(height: 220),
                  ),
                  const SizedBox(height: 20),
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showForgotPasswordDialog,
                      child: Text(
                        context.locale == const Locale('ar')
                            ? "نسيت كلمة المرور؟"
                            : "Forgot Password?",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.blueAccent
                              : const Color.fromARGB(255, 6, 0, 59),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RoleSelectionScreen())),
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
