import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/firebase_service.dart';
import '../models/reading_model.dart';

class AppImages {
  static const String logoLight = 'assets/images/logo_light.png';
  static const String logoDark = 'assets/images/logo_dark.png';

  static String getLogo(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? logoDark : logoLight;
  }
}

class AddReadingScreen extends StatefulWidget {
  const AddReadingScreen({super.key});

  @override
  State<AddReadingScreen> createState() => _AddReadingScreenState();
}

class _AddReadingScreenState extends State<AddReadingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _levelController = TextEditingController();
  final _noteController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  bool _isSaving = false;
  bool _isFasting = true;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(AppImages.logoLight), context);
    precacheImage(const AssetImage(AppImages.logoDark), context);
  }
  // ---------------------------------------

  void _saveReading() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('login_required'.tr())),
        );
        setState(() => _isSaving = false);
        return;
      }

      final ReadingModel newReading = ReadingModel(
        userId: user.uid,
        glucoseLevel: double.parse(_levelController.text),
        timestamp: DateTime.now(),
        note: _noteController.text,
        isFasting: _isFasting, 
      );

      try {
        await _firebaseService.addReading(newReading);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(
            'last_reading', DateTime.now().millisecondsSinceEpoch);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('update_success'.tr())),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('error'.tr())),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _levelController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'add_reading'.tr(),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 6, 0, 59),
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
              opacity: 0.20,
              child: Image.asset(
                AppImages.getLogo(context),
                width: 250,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox();
                },
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(25.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.bloodtype,
                      size: 80, color: Colors.redAccent),
                  const SizedBox(height: 20),
                  Text(
                    'select_condition'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: Text(
                          'fasting'.tr(),
                          style: TextStyle(
                            color: _isFasting
                                ? Colors.white
                                : (isDark
                                    ? Colors.white70
                                    : const Color.fromARGB(255, 6, 0, 59)),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        selected: _isFasting,
                        selectedColor: const Color.fromARGB(255, 6, 0, 59),
                        backgroundColor:
                            isDark ? Colors.white10 : Colors.grey[200],
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        onSelected: (selected) {
                          if (selected) setState(() => _isFasting = true);
                        },
                      ),
                      const SizedBox(width: 20),
                      ChoiceChip(
                        label: Text(
                          'Non_fasting'.tr(),
                          style: TextStyle(
                            color: !_isFasting ? Colors.white : Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        selected: !_isFasting,
                        selectedColor: Colors.teal,
                        backgroundColor:
                            isDark ? Colors.white10 : Colors.grey[200],
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        onSelected: (selected) {
                          if (selected) setState(() => _isFasting = false);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _levelController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: '${'blood_sugar_level'.tr()} (mg/dL)',
                      labelStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54),
                      prefixIcon: Icon(Icons.speed,
                          color: isDark ? Colors.blueAccent : Colors.grey),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF1E1E1E)
                          : Colors.grey[300]!.withValues(alpha: 0.1),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'select_condition'.tr() : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _noteController,
                    maxLines: 3,
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: '${'notes'.tr()} (${'optional'.tr()})',
                      labelStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54),
                      hintText: 'other'.tr(),
                      hintStyle: TextStyle(
                          color: isDark ? Colors.white30 : Colors.grey),
                      prefixIcon: Icon(Icons.notes,
                          color: isDark ? Colors.blueAccent : Colors.grey),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF1E1E1E)
                          : Colors.grey[300]!.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveReading,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? Colors.blueAccent
                          : const Color.fromARGB(255, 6, 0, 59),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'save'.tr(),
                            style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
