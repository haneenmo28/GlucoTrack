import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:easy_localization/easy_localization.dart';
import 'caregiver_home_screen.dart';

class AppImages {
  static const String logoLight = 'assets/images/logo_light.png';
  static const String logoDark = 'assets/images/logo_dark.png';
  static const String googleLogo = 'assets/images/google.png';

  static String getLogo(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? logoDark : logoLight;
  }
}

class SignUpScreen extends StatefulWidget {
  final String role;

  const SignUpScreen({super.key, required this.role});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        "116290014601-cj98pg1q2lkefbn2nvi4obsbmm088u97.apps.googleusercontent.com",
    scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(AppImages.logoLight), context);
    precacheImage(const AssetImage(AppImages.logoDark), context);
  }

  Future<void> _signUpWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': userCredential.user!.displayName,
        'email': userCredential.user!.email,
        'role': widget.role, // 💡 حفظنا نوع الحساب هنا
        if (userCredential.additionalUserInfo!.isNewUser)
          'createdAt': FieldValue.serverTimestamp(),
        if (widget.role == 'patient' &&
            userCredential.additionalUserInfo!.isNewUser)
          'diabetesType': 'Type 1',
      }, SetOptions(merge: true));

      if (mounted) {
        if (widget.role == 'caregiver') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const CaregiverHomeScreen()));
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } on PlatformException catch (e) {
      String userMessage = 'error'.tr();
      if (e.code == '10') {
        userMessage =
            "مشكلة في الربط (Error 10): تأكدي من إضافة إيميلك في الـ Test Users.";
      }
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(userMessage)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignUp() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('enter_credentials'.tr())));
      return;
    }
    setState(() => _isLoading = true);
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': widget.role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        if (widget.role == 'caregiver') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const CaregiverHomeScreen()));
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg = 'error'.tr();
      if (e.code == 'weak-password') errorMsg = 'weak_password_msg'.tr();
      if (e.code == 'email-already-in-use') errorMsg = 'email_in_use_msg'.tr();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMsg)));
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
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  Image.asset(
                    AppImages.getLogo(context),
                    width: 300,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox(height: 100),
                  ),
                  const SizedBox(height: 10),
                  Text('join_our_family'.tr(),
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color.fromARGB(255, 6, 0, 59))),
                  Text('onboarding_slogan'.tr(),
                      style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? Colors.white70
                              : const Color.fromARGB(255, 6, 0, 59)),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  _buildTextField(
                      context: context,
                      controller: _nameController,
                      label: 'full_name'.tr(),
                      icon: Icons.person),
                  const SizedBox(height: 10),
                  _buildTextField(
                      context: context,
                      controller: _emailController,
                      label: 'email'.tr(),
                      icon: Icons.email,
                      type: TextInputType.emailAddress),
                  const SizedBox(height: 10),
                  _buildTextField(
                      context: context,
                      controller: _passwordController,
                      label: 'password'.tr(),
                      icon: Icons.lock,
                      isPassword: true),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignUp,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? Colors.blueAccent
                              : const Color.fromARGB(255, 6, 0, 59),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text('create_account'.tr(),
                              style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  OutlinedButton(
                    onPressed: _isLoading ? null : _signUpWithGoogle,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      backgroundColor: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.transparent,
                      side: BorderSide(
                          color: isDark
                              ? Colors.white24
                              : const Color.fromARGB(255, 6, 0, 59)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppImages.googleLogo,
                          height: 65,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('already_have_account'.tr(),
                          style: TextStyle(
                              color: isDark
                                  ? Colors.white70
                                  : const Color.fromARGB(255, 6, 0, 59),
                              fontWeight: FontWeight.bold))),
                ],
              ),
            ),
          ),
          Positioned(
              top: 50,
              left: context.locale == const Locale('ar') ? null : 15,
              right: context.locale == const Locale('ar') ? 15 : null,
              child: IconButton(
                  icon: Icon(
                      context.locale == const Locale('ar')
                          ? Icons.arrow_forward_ios
                          : Icons.arrow_back_ios,
                      color: isDark
                          ? Colors.white
                          : const Color.fromARGB(255, 6, 0, 59)),
                  onPressed: () => Navigator.pop(context))),
          Positioned(
            top: 50,
            right: context.locale == const Locale('ar') ? null : 20,
            left: context.locale == const Locale('ar') ? 20 : null,
            child: InkWell(
              onTap: () => context.setLocale(
                  context.locale == const Locale('ar')
                      ? const Locale('en')
                      : const Locale('ar')),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    color: (isDark
                            ? Colors.white
                            : const Color.fromARGB(255, 6, 0, 59))
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: isDark
                            ? Colors.white24
                            : const Color.fromARGB(255, 6, 0, 59),
                        width: 1)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.language,
                      size: 18,
                      color: isDark
                          ? Colors.white
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
                          fontWeight: FontWeight.bold))
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      {required BuildContext context,
      required TextEditingController controller,
      required String label,
      required IconData icon,
      bool isPassword = false,
      TextInputType type = TextInputType.text}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: type,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
          labelText: label,
          labelStyle:
              TextStyle(color: isDark ? Colors.white70 : Colors.black54),
          prefixIcon: Icon(icon,
              color: isDark
                  ? Colors.blueAccent
                  : const Color.fromARGB(255, 6, 0, 59)),
          filled: true,
          fillColor:
              isDark ? const Color(0xFF1E1E1E) : Colors.white.withOpacity(0.9),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none)),
    );
  }
}
