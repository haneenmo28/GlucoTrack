import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isScanned = false;
  Future<void> _linkWithPatient(String scannedCode, String lang) async {
    if (_isScanned) return;
    setState(() => _isScanned = true);

    try {
      final caregiverId = FirebaseAuth.instance.currentUser?.uid;

      if (caregiverId != null) {
        int? numericCode = int.tryParse(scannedCode);
        var querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('linkCode', isEqualTo: scannedCode)
            .where('role', isEqualTo: 'patient')
            .get();

        if (querySnapshot.docs.isEmpty && numericCode != null) {
          querySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('linkCode', isEqualTo: numericCode)
              .where('role', isEqualTo: 'patient')
              .get();
        }

        if (querySnapshot.docs.isEmpty) {
          setState(() => _isScanned = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(lang == 'ar'
                    ? 'الكود غير صحيح أو المريض غير موجود'
                    : 'Invalid code or patient not found'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
          return;
        }

        final String patientId = querySnapshot.docs.first.id;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(caregiverId)
            .set({'linkedPatientId': patientId}, SetOptions(merge: true));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(lang == 'ar'
                  ? 'تم ربط الحساب بالمريض بنجاح! 🎉'
                  : 'Account linked with patient successfully! 🎉'),
              backgroundColor: Colors.teal,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      debugPrint("Error linking patient via QR: $e");
      setState(() => _isScanned = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang == 'ar'
                ? 'حدث خطأ أثناء الربط، يرجى المحاولة مرة أخرى'
                : 'An error occurred while linking, please try again'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          lang == 'ar' ? 'مسح كود المريض' : 'Scan Patient Code',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  final String patientId = barcode.rawValue!;
                  _linkWithPatient(patientId, lang);
                  break;
                }
              }
            },
          ),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.tealAccent, width: 2.5),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.tealAccent.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Colors.tealAccent,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          lang == 'ar' ? 'توجيه الكاميرا' : 'Align QR Code',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          lang == 'ar'
                              ? 'قم بتوجيه الكاميرا نحو كود المريض لإتمام الربط تلقائياً'
                              : 'Point camera at the patient\'s QR code to link automatically',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ],
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
