import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/theme_provider.dart';
import 'login_screen.dart';

class CaregiverProfileScreen extends StatefulWidget {
  const CaregiverProfileScreen({super.key});

  @override
  State<CaregiverProfileScreen> createState() => _CaregiverProfileScreenState();
}

class _CaregiverProfileScreenState extends State<CaregiverProfileScreen> {
  String _caregiverName = '...';
  String _caregiverEmail = '...';
  String _caregiverAge = '--';
  String _caregiverRole = '--';
  bool _isLinked = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _caregiverEmail = user.email ?? 'لا يوجد بريد إلكتروني';
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          final data = doc.data()!;
          setState(() {
            _caregiverName = data['name']?.toString() ?? 'مرافق';
            _caregiverAge = data['age']?.toString() ?? '--';
            _caregiverRole = data['caregiverRole']?.toString() ?? '--';
            _isLinked = data.containsKey('linkedPatientId') &&
                data['linkedPatientId'] != null;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching profile data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    final bgColor =
        isDarkMode ? const Color(0xFF101014) : const Color(0xFFF5F5F5);
    final headerColor = isDarkMode
        ? const Color(0xFF0B0742)
        : const Color.fromARGB(255, 6, 0, 59);
    final cardColor = isDarkMode ? const Color(0xFF1A1A22) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor = isDarkMode ? Colors.white54 : Colors.grey.shade600;
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Positioned.fill(
            top: 200,
            child: Opacity(
              opacity: isDarkMode ? 0.5 : 0.8,
              child: Center(
                child: Image.asset(
                  isDarkMode
                      ? 'assets/images/logo_dark.png'
                      : 'assets/images/logo_light.png',
                  width: 250,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                // --- Header Section ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 50, bottom: 30),
                  decoration: BoxDecoration(
                    color: headerColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Text(
                              lang == 'ar' ? 'الملف الشخصي' : 'User Profile',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_note_rounded,
                                  color: Colors.white, size: 28),
                              onPressed: () => _showEditProfileDialog(
                                  lang, cardColor, textColor, subtitleColor),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 3),
                        ),
                        child: const CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person,
                              size: 50, color: Color(0xFF0B0742)),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        _caregiverName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: _isLinked
                                  ? Icons.monitor_heart_outlined
                                  : Icons.link_off_rounded,
                              title: lang == 'ar' ? 'الارتباط' : 'Status',
                              value: _isLinked
                                  ? (lang == 'ar' ? 'نشط' : 'Linked')
                                  : (lang == 'ar' ? 'غير مرتبط' : 'Unlinked'),
                              color: _isLinked
                                  ? Colors.orange.shade400
                                  : Colors.grey,
                              cardColor: cardColor,
                              textColor: textColor,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.shield_outlined,
                              title: lang == 'ar' ? 'الدور' : 'Role',
                              value: lang == 'ar' ? 'مرافق' : 'Caregiver',
                              color: Colors.teal.shade400,
                              cardColor: cardColor,
                              textColor: textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // --- Settings Menu ---
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            _buildMenuTile(
                              icon: Icons.language_rounded,
                              iconColor: Colors.blue,
                              title: lang == 'ar' ? 'English' : 'العربية',
                              trailing: const Icon(Icons.swap_horiz_rounded,
                                  color: Colors.grey),
                              onTap: () async {
                                if (lang == 'ar') {
                                  await context.setLocale(const Locale('en'));
                                } else {
                                  await context.setLocale(const Locale('ar'));
                                }
                              },
                              textColor: textColor,
                            ),
                            _buildMenuTile(
                              icon: Icons.dark_mode_rounded,
                              iconColor: Colors.amber,
                              title:
                                  lang == 'ar' ? 'الوضع الداكن' : 'Dark Mode',
                              trailing: Switch(
                                value: isDarkMode,
                                activeColor: Colors.amber,
                                onChanged: (val) {
                                  themeProvider.toggleTheme(val);
                                },
                              ),
                              onTap: null,
                              textColor: textColor,
                            ),
                            _buildMenuTile(
                              icon: Icons.password_rounded,
                              iconColor: Colors.orange,
                              title: lang == 'ar'
                                  ? 'تغيير كلمة المرور'
                                  : 'Change Password',
                              trailing: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.grey,
                                  size: 16),
                              onTap: () => _showChangePasswordDialog(
                                  lang, cardColor, textColor, subtitleColor),
                              textColor: textColor,
                            ),
                            Divider(
                                color: isDarkMode
                                    ? Colors.white10
                                    : Colors.grey.shade200,
                                height: 1),
                            _buildMenuTile(
                              icon: Icons.link_off_rounded,
                              iconColor: Colors.teal,
                              title: lang == 'ar'
                                  ? 'فك الارتباط بالمريض'
                                  : 'Unlink Patient',
                              trailing: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.grey,
                                  size: 16),
                              onTap: () => _unlinkPatient(lang),
                              textColor: textColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // --- Account Details Section ---
                      Text(
                        lang == 'ar' ? 'بيانات الحساب' : 'Account Details',
                        style: TextStyle(
                            color: Colors.blue.shade400,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            _buildInfoTile(
                              icon: Icons.badge_outlined,
                              title:
                                  lang == 'ar' ? 'الاسم بالكامل' : 'Full Name',
                              subtitle: _caregiverName,
                              textColor: textColor,
                              subtitleColor: subtitleColor,
                            ),
                            Divider(
                                color: isDarkMode
                                    ? Colors.white10
                                    : Colors.grey.shade200,
                                height: 1),
                            _buildInfoTile(
                              icon: Icons.email_outlined,
                              title: lang == 'ar'
                                  ? 'البريد الإلكتروني'
                                  : 'Email Address',
                              subtitle: _caregiverEmail,
                              textColor: textColor,
                              subtitleColor: subtitleColor,
                            ),
                            Divider(
                                color: isDarkMode
                                    ? Colors.white10
                                    : Colors.grey.shade200,
                                height: 1),
                            _buildInfoTile(
                              icon: Icons.cake_outlined,
                              title: lang == 'ar' ? 'السن' : 'Age',
                              subtitle: _caregiverAge,
                              textColor: textColor,
                              subtitleColor: subtitleColor,
                            ),
                            Divider(
                                color: isDarkMode
                                    ? Colors.white10
                                    : Colors.grey.shade200,
                                height: 1),
                            _buildInfoTile(
                              icon: Icons.medical_information_outlined,
                              title: lang == 'ar'
                                  ? 'الدور / صلة القرابة'
                                  : 'Role / Relation',
                              subtitle: _caregiverRole,
                              textColor: textColor,
                              subtitleColor: subtitleColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // --- Logout Button ---
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton.icon(
                          onPressed: () => _handleLogout(lang),
                          icon: const Icon(Icons.logout_rounded,
                              color: Colors.redAccent),
                          label: Text(
                            lang == 'ar' ? 'تسجيل الخروج' : 'Logout',
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Colors.redAccent, width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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

  Future<void> _showEditProfileDialog(String lang, Color cardColor,
      Color textColor, Color subtitleColor) async {
    _nameController.text = _caregiverName;
    _ageController.text = _caregiverAge == '--' ? '' : _caregiverAge;

    List<String> roles = lang == 'ar'
        ? [
            'أحد الوالدين',
            'ابن / ابنة',
            'زوج / زوجة',
            'أخ / أخت',
            'طبيب مقيم',
            'ممرض',
            'صديق',
            'أخرى'
          ]
        : [
            'Parent',
            'Child',
            'Spouse',
            'Sibling',
            'Doctor',
            'Nurse',
            'Friend',
            'Other'
          ];

    String? tempRole = roles.contains(_caregiverRole) ? _caregiverRole : null;

    bool? confirm = await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
          // استخدمنا StatefulBuilder عشان الـ Dropdown يشتغل جوه الـ Dialog
          builder: (context, setStateDialog) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: Text(
            lang == 'ar' ? 'تعديل الملف الشخصي' : 'Edit Profile',
            style: TextStyle(
                color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: lang == 'ar' ? 'الاسم بالكامل' : 'Full Name',
                    labelStyle: TextStyle(color: subtitleColor, fontSize: 14),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: subtitleColor)),
                    focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent)),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _ageController,
                  style: TextStyle(color: textColor),
                  keyboardType: TextInputType.number, // كيبورد أرقام بس
                  decoration: InputDecoration(
                    labelText: lang == 'ar' ? 'السن' : 'Age',
                    labelStyle: TextStyle(color: subtitleColor, fontSize: 14),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: subtitleColor)),
                    focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent)),
                  ),
                ),
                const SizedBox(height: 25),
                DropdownButtonFormField<String>(
                  value: tempRole,
                  dropdownColor: cardColor,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: lang == 'ar'
                        ? 'الدور / صلة القرابة'
                        : 'Role / Relation',
                    labelStyle: TextStyle(color: subtitleColor, fontSize: 14),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                  items: roles
                      .map((role) =>
                          DropdownMenuItem(value: role, child: Text(role)))
                      .toList(),
                  onChanged: (val) {
                    setStateDialog(() => tempRole = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(lang == 'ar' ? 'إلغاء' : 'Cancel',
                  style: const TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(lang == 'ar' ? 'حفظ' : 'Save',
                  style: const TextStyle(
                      color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      }),
    );

    if (confirm == true) {
      final newName = _nameController.text.trim();
      final newAge = _ageController.text.trim();
      final newRole = tempRole ?? _caregiverRole;

      if (newName.isNotEmpty) {
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .update({
              'name': newName,
              'age': newAge,
              'caregiverRole': newRole,
            });

            setState(() {
              _caregiverName = newName;
              _caregiverAge = newAge.isEmpty ? '--' : newAge;
              _caregiverRole = newRole;
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(lang == 'ar'
                      ? 'تم التحديث بنجاح'
                      : 'Updated successfully'),
                  backgroundColor: Colors.teal));
            }
          }
        } catch (e) {
          debugPrint("Error updating profile: $e");
        }
      }
    }
  }

  Future<void> _showChangePasswordDialog(String lang, Color cardColor,
      Color textColor, Color subtitleColor) async {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _obscureCurrentPassword = true;
    _obscureNewPassword = true;
    bool isSaving = false;
    String? errorMessage;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: cardColor,
            title: Text(
              lang == 'ar' ? 'تغيير كلمة المرور' : 'Change Password',
              style: TextStyle(
                  color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _currentPasswordController,
                    obscureText: _obscureCurrentPassword,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: lang == 'ar'
                          ? 'كلمة المرور الحالية'
                          : 'Current Password',
                      labelStyle: TextStyle(color: subtitleColor, fontSize: 14),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: subtitleColor)),
                      focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureCurrentPassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: subtitleColor,
                          size: 20,
                        ),
                        onPressed: () => setStateDialog(() =>
                            _obscureCurrentPassword = !_obscureCurrentPassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _newPasswordController,
                    obscureText: _obscureNewPassword,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText:
                          lang == 'ar' ? 'كلمة المرور الجديدة' : 'New Password',
                      labelStyle: TextStyle(color: subtitleColor, fontSize: 14),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: subtitleColor)),
                      focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNewPassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: subtitleColor,
                          size: 20,
                        ),
                        onPressed: () => setStateDialog(
                            () => _obscureNewPassword = !_obscureNewPassword),
                      ),
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      errorMessage!,
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(context),
                child: Text(lang == 'ar' ? 'إلغاء' : 'Cancel',
                    style: const TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        final currentPassword =
                            _currentPasswordController.text.trim();
                        final newPassword = _newPasswordController.text.trim();

                        if (currentPassword.isEmpty) {
                          setStateDialog(() => errorMessage = lang == 'ar'
                              ? 'من فضلك أدخلي كلمة المرور الحالية'
                              : 'Please enter your current password');
                          return;
                        }
                        if (newPassword.length < 6) {
                          setStateDialog(() => errorMessage = lang == 'ar'
                              ? 'كلمة المرور الجديدة يجب أن تكون 6 أحرف على الأقل'
                              : 'New password must be at least 6 characters');
                          return;
                        }

                        setStateDialog(() {
                          isSaving = true;
                          errorMessage = null;
                        });

                        try {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null && user.email != null) {
                            final credential = EmailAuthProvider.credential(
                              email: user.email!,
                              password: currentPassword,
                            );
                            await user.reauthenticateWithCredential(credential);
                            await user.updatePassword(newPassword);

                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(lang == 'ar'
                                      ? 'تم تغيير كلمة المرور بنجاح ✅'
                                      : 'Password changed successfully ✅'),
                                  backgroundColor: Colors.teal,
                                ),
                              );
                            }
                          }
                        } on FirebaseAuthException catch (e) {
                          String msg;
                          if (e.code == 'wrong-password' ||
                              e.code == 'invalid-credential') {
                            msg = lang == 'ar'
                                ? 'كلمة المرور الحالية غير صحيحة'
                                : 'Current password is incorrect';
                          } else if (e.code == 'weak-password') {
                            msg = lang == 'ar'
                                ? 'كلمة المرور الجديدة ضعيفة جداً'
                                : 'New password is too weak';
                          } else {
                            msg = lang == 'ar'
                                ? 'حدث خطأ، يرجى المحاولة لاحقاً'
                                : 'An error occurred, please try again';
                          }
                          setStateDialog(() {
                            isSaving = false;
                            errorMessage = msg;
                          });
                        } catch (e) {
                          setStateDialog(() {
                            isSaving = false;
                            errorMessage = lang == 'ar'
                                ? 'حدث خطأ، يرجى المحاولة لاحقاً'
                                : 'An error occurred, please try again';
                          });
                        }
                      },
                child: isSaving
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: subtitleColor),
                      )
                    : Text(lang == 'ar' ? 'حفظ' : 'Save',
                        style: const TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _unlinkPatient(String lang) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1A1A24)
              : Colors.white,
          title: Text(
            lang == 'ar' ? 'فك الارتباط' : 'Unlink Patient',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          content: Text(
            lang == 'ar'
                ? 'هل أنت متأكد أنك تريد فك الارتباط بهذا المريض؟ لن تتمكن من رؤية بياناته بعد الآن.'
                : 'Are you sure you want to unlink this patient? You will no longer see their data.',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // لو داس إلغاء
              child: Text(lang == 'ar' ? 'إلغاء' : 'Cancel',
                  style: const TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // لو داس تأكيد
              child: Text(lang == 'ar' ? 'فك الارتباط' : 'Unlink',
                  style: const TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final caregiverId = FirebaseAuth.instance.currentUser?.uid;
        if (caregiverId != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(caregiverId)
              .update({
            'linkedPatientId': FieldValue.delete(),
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(lang == 'ar'
                    ? 'تم فك الارتباط بنجاح 🔗'
                    : 'Unlinked successfully 🔗'),
                backgroundColor: Colors.teal,
              ),
            );

            setState(() {
              _isLinked = false;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(lang == 'ar'
                  ? 'حدث خطأ، يرجى المحاولة لاحقاً'
                  : 'An error occurred, please try again'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleLogout(String lang) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang == 'ar' ? 'تسجيل الخروج' : 'Logout'),
        content: Text(lang == 'ar'
            ? 'هل أنتِ متأكدة من تسجيل الخروج؟'
            : 'Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(lang == 'ar' ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(lang == 'ar' ? 'خروج' : 'Logout',
                style: const TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint("Error signing out: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(lang == 'ar'
                ? 'حدث خطأ أثناء تسجيل الخروج'
                : 'Error signing out')));
      }
    }
  }

  // --- Helper Widgets ---

  Widget _buildStatCard(
      {required IconData icon,
      required String title,
      required String value,
      required Color color,
      required Color cardColor,
      required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(title,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
      {required IconData icon,
      required Color iconColor,
      required String title,
      required Widget trailing,
      required VoidCallback? onTap,
      required Color textColor}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(title,
          style: TextStyle(
              color: textColor, fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: trailing,
    );
  }

  Widget _buildInfoTile(
      {required IconData icon,
      required String title,
      required String subtitle,
      required Color textColor,
      required Color subtitleColor}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.blueAccent, size: 22),
      ),
      title: Text(title, style: TextStyle(color: subtitleColor, fontSize: 12)),
      subtitle: Text(subtitle,
          style: TextStyle(
              color: textColor, fontSize: 15, fontWeight: FontWeight.bold)),
    );
  }
}
