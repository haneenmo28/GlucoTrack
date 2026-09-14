import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AppImages {
  static const String logoLight = 'assets/images/logo_light.png';
  static const String logoDark = 'assets/images/logo_dark.png';

  static String getLogo(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? logoDark : logoLight;
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _diagnosisYearController = TextEditingController();

  String _diabetesType = 'Type 1';
  String _treatmentType = 'حبوب';
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _generateAndShowLinkCode() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      String linkCode = '';

      if (doc.exists && doc.data()!.containsKey('linkCode')) {
        linkCode = doc.data()!['linkCode'];
      } else {
        final random = Random();
        linkCode = (100000 + random.nextInt(900000)).toString();

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'linkCode': linkCode,
        }, SetOptions(merge: true));
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      _showCodeDialog(linkCode);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ، حاول مرة أخرى')));
    }
  }

  void _showCodeDialog(String code) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.locale.languageCode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          lang == 'ar' ? 'كود الربط الخاص بك' : 'Your Link Code',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                lang == 'ar'
                    ? 'أعط هذا الكود لمرافقك أو دعه يمسح الرمز ليتمكن من المتابعة.'
                    : 'Give this code to your caregiver or let them scan the QR.',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: isDark ? Colors.white70 : Colors.black54),
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.teal.withOpacity(0.5)),
                ),
                child: Text(
                  code,
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                      color: Colors.teal),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 160,
                height: 160,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.teal.shade200, width: 2),
                ),
                child: QrImageView(
                  data: code,
                  version: QrVersions.auto,
                  backgroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(lang == 'ar'
                      ? 'تم نسخ الكود بنجاح!'
                      : 'Code copied successfully!'),
                  backgroundColor: Colors.teal,
                ),
              );
            },
            icon: const Icon(Icons.copy, color: Colors.white),
            label: Text(lang == 'ar' ? 'نسخ الكود' : 'Copy Code',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final TextEditingController newPasswordController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('change_password'.tr(),
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87)),
        content: TextField(
          controller: newPasswordController,
          obscureText: true,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            labelText: 'new_password'.tr(),
            labelStyle:
                TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr(),
                  style: TextStyle(
                      color: isDark ? Colors.blueAccent : Colors.blue))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 6, 0, 59)),
            onPressed: () async {
              if (newPasswordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('weak_password_msg'.tr())));
                return;
              }
              try {
                await FirebaseAuth.instance.currentUser!
                    .updatePassword(newPasswordController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('password_changed_success'.tr())));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('re_login_required'.tr())));
              }
            },
            child: Text('password_update'.tr(),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          final data = doc.data()!;
          _nameController.text = data['name'] ?? '';
          _ageController.text = (data['age'] ?? '').toString();
          _weightController.text = (data['weight'] ?? '').toString();
          _diagnosisYearController.text =
              (data['diagnosisYear'] ?? '').toString();

          if (mounted) {
            setState(() {
              _diabetesType = data['diabetesType'] ?? 'Type 1';
              _treatmentType = data['treatmentType'] ?? 'حبوب';
              _isEditMode = false;
            });
          }
        } else {
          if (mounted) setState(() => _isEditMode = true);
        }
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': _nameController.text.trim(),
        'age': int.tryParse(_ageController.text) ?? 0,
        'weight': double.tryParse(_weightController.text) ?? 0.0,
        'diagnosisYear':
            int.tryParse(_diagnosisYearController.text) ?? DateTime.now().year,
        'diabetesType': _diabetesType,
        'treatmentType': _diabetesType == 'Type 2' ? _treatmentType : 'إنسولين',
      }, SetOptions(merge: true));
      setState(() => _isEditMode = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('user_profile_updated'.tr())));
    }
    setState(() => _isLoading = false);
  }

  Future<void> _logout() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
        title: Text('log_out'.tr(),
            style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: Text('confirm_log_out'.tr(),
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('cancel'.tr())),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                Text('log_out'.tr(), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('user_profile_title'.tr(),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 6, 0, 59),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.close : Icons.edit_note_rounded,
                color: Colors.white, size: 28),
            onPressed: () => setState(() => _isEditMode = !_isEditMode),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.teal,
                    strokeWidth: 4,
                  ),
                  SizedBox(height: 20),
                  Text('جاري التحميل...',
                      style: TextStyle(
                          color: Colors.teal,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            )
          : Stack(
              children: [
                Center(
                  child: Opacity(
                    opacity: isDark ? 0.4 : 0.6,
                    child: Image.asset(
                      AppImages.getLogo(context),
                      width: 320,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox(),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildProfileHeader(),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!_isEditMode) _buildStatsRow(context),
                            const SizedBox(height: 25),
                            if (!_isEditMode) ...[
                              _buildLanguageSwitch(context),
                              const SizedBox(height: 15),
                              _buildThemeSwitch(context),
                              const SizedBox(height: 15),
                              _buildPasswordTile(context),
                              const SizedBox(height: 15),
                              _buildLinkCodeTile(context),
                            ],
                            const SizedBox(height: 15),
                            Text(
                              _isEditMode ? "edit".tr() : "report".tr(),
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.blueAccent
                                      : const Color.fromARGB(255, 6, 0, 59)),
                            ),
                            const SizedBox(height: 15),
                            _isEditMode
                                ? _buildEditForm(context)
                                : _buildInfoSection(context),
                            if (!_isEditMode) ...[
                              const SizedBox(height: 40),
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: OutlinedButton.icon(
                                  onPressed: _logout,
                                  icon: const Icon(Icons.logout_rounded,
                                      color: Colors.red),
                                  label: Text("log_out".tr(),
                                      style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: Colors.red, width: 1.5),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLinkCodeTile(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.locale.languageCode;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
              ],
      ),
      child: ListTile(
        leading:
            const Icon(Icons.qr_code_2_rounded, color: Colors.teal, size: 28),
        title: Text(lang == 'ar' ? 'كود الربط للمرافق' : 'Caregiver Link Code',
            style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold)),
        trailing: Icon(Icons.arrow_forward_ios,
            size: 16, color: isDark ? Colors.white54 : Colors.grey),
        onTap: _generateAndShowLinkCode,
      ),
    );
  }

  Widget _buildThemeSwitch(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
              ],
      ),
      child: ListTile(
        leading: Icon(
          isDark ? Icons.dark_mode : Icons.light_mode,
          color: isDark ? Colors.amber : Colors.blue,
        ),
        title: Text(
          isDark ? 'dark_mode'.tr() : 'light_mode'.tr(),
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        trailing: Switch(
          value: isDark,
          activeThumbColor: Colors.amber,
          onChanged: (value) {
            Provider.of<ThemeProvider>(context, listen: false)
                .toggleTheme(value);
          },
        ),
      ),
    );
  }

  Widget _buildPasswordTile(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
              ],
      ),
      child: ListTile(
        leading: const Icon(Icons.lock_reset_rounded, color: Colors.orange),
        title: Text('change_password'.tr(),
            style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        trailing: Icon(Icons.arrow_forward_ios,
            size: 16, color: isDark ? Colors.white54 : Colors.grey),
        onTap: _showChangePasswordDialog,
      ),
    );
  }

  Widget _buildLanguageSwitch(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
              ],
      ),
      child: ListTile(
        leading: const Icon(Icons.language, color: Colors.blue),
        title: Text(
            context.locale == const Locale('ar') ? 'English' : 'العربية',
            style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        trailing: Icon(Icons.swap_horiz,
            color: isDark ? Colors.white54 : Colors.grey),
        onTap: () async {
          final prefs = await SharedPreferences.getInstance();
          if (context.locale == const Locale('ar')) {
            context.setLocale(const Locale('en'));
            await prefs.setString('language_code', 'en');
          } else {
            context.setLocale(const Locale('ar'));
            await prefs.setString('language_code', 'ar');
          }
        },
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 30, top: 20),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 6, 0, 59),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white24,
            child: CircleAvatar(
                radius: 46,
                backgroundColor: Colors.white,
                child: Icon(Icons.person,
                    size: 50, color: Color.fromARGB(255, 6, 0, 59))),
          ),
          const SizedBox(height: 15),
          if (!_isEditMode)
            Text(_nameController.text.isEmpty ? "..." : _nameController.text,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    int currentYear = DateTime.now().year;
    int diagYear = int.tryParse(_diagnosisYearController.text) ?? currentYear;
    int yearsCount = currentYear - diagYear;
    return Row(
      children: [
        _buildStatCard(context, "fighter_since".tr(), "$yearsCount",
            "years".tr(), Icons.history_edu_rounded, Colors.orange),
        const SizedBox(width: 15),
        _buildStatCard(context, "weight".tr(), _weightController.text,
            "kg".tr(), Icons.fitness_center_rounded, Colors.teal),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      String unit, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05), blurRadius: 10)
                ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text("$value $unit",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white
                        : const Color.fromARGB(255, 6, 0, 59))),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
              ],
      ),
      child: Column(
        children: [
          _buildInfoTile(context, "full_name".tr(), _nameController.text,
              Icons.badge_outlined),
          Divider(
              height: 1,
              indent: 55,
              color: isDark ? Colors.white10 : Colors.grey[200]),
          _buildInfoTile(
              context,
              "type_of_diabetes".tr(),
              _diabetesType == 'Type 1' ? "Type_1".tr() : "Type_2".tr(),
              Icons.bloodtype_outlined),
          Divider(
              height: 1,
              indent: 55,
              color: isDark ? Colors.white10 : Colors.grey[200]),
          _buildInfoTile(
              context,
              "Type_of_treatment".tr(),
              _treatmentType == 'حبوب'
                  ? "Oral_medication".tr()
                  : "Insulin".tr(),
              Icons.medication_liquid_rounded),
          Divider(
              height: 1,
              indent: 55,
              color: isDark ? Colors.white10 : Colors.grey[200]),
          _buildInfoTile(context, "Year_of_diagnosis".tr(),
              _diagnosisYearController.text, Icons.event_available_rounded),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
      BuildContext context, String label, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 6, 0, 59)
                .withOpacity(isDark ? 0.4 : 0.1),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon,
            color: isDark
                ? Colors.blueAccent
                : const Color.fromARGB(255, 6, 0, 59),
            size: 20),
      ),
      title:
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value,
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87)),
    );
  }

  Widget _buildEditForm(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStyledTextField(
            context, _nameController, "full_name".tr(), Icons.person_outline),
        _buildStyledTextField(
            context, _ageController, "age".tr(), Icons.calendar_today_outlined,
            isNum: true),
        _buildStyledTextField(context, _weightController, "weight".tr(),
            Icons.monitor_weight_outlined,
            isNum: true),
        _buildStyledTextField(context, _diagnosisYearController,
            "Year_of_diagnosis".tr(), Icons.history,
            isNum: true),
        _buildStyledDropdown(context),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Text("Type_of_treatment".tr(),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? Colors.blueAccent
                      : const Color.fromARGB(255, 6, 0, 59))),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
                color:
                    isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
          ),
          child: DropdownButton<String>(
            value: _treatmentType,
            isExpanded: true,
            dropdownColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
            underline: const SizedBox(),
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            items: [
              DropdownMenuItem(value: 'إنسولين', child: Text("Insulin".tr())),
              DropdownMenuItem(
                  value: 'حبوب', child: Text("Oral_medication".tr())),
            ],
            onChanged: (v) => setState(() => _treatmentType = v!),
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? Colors.blueAccent
                  : const Color.fromARGB(255, 6, 0, 59),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            ),
            child: Text("save_changes".tr(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildStyledTextField(BuildContext context,
      TextEditingController controller, String label, IconData icon,
      {bool isNum = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05))),
      child: TextField(
        controller: controller,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              TextStyle(color: isDark ? Colors.white70 : Colors.black54),
          prefixIcon: Icon(icon,
              color: isDark
                  ? Colors.blueAccent
                  : const Color.fromARGB(255, 6, 0, 59)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildStyledDropdown(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05))),
      child: DropdownButton<String>(
        value: _diabetesType,
        isExpanded: true,
        dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        underline: const SizedBox(),
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        items: [
          DropdownMenuItem(value: 'Type 1', child: Text("Type_1".tr())),
          DropdownMenuItem(value: 'Type 2', child: Text("Type_2".tr())),
        ],
        onChanged: (v) => setState(() {
          _diabetesType = v!;
          if (_diabetesType == 'Type 1') _treatmentType = 'إنسولين';
        }),
      ),
    );
  }
}
