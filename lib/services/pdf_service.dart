import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:arabic_reshaper/arabic_reshaper.dart';
import 'package:bidi/bidi.dart' as bidi;

class PdfReportService {
  static String _translateValue(String? value, bool isAr) {
    if (value == null || value.trim().isEmpty || value == 'null') return '-';

    final val = value.trim().toLowerCase();

    bool isFastingCase = (val == 'true' ||
        val == 'fasting' ||
        val == 'صائم' ||
        val == 'صايم' ||
        val == 'قبل الأكل');
    bool isFedCase =
        (val == 'false' || val == 'fed' || val == 'فاطر' || val == 'بعد الأكل');

    if (isFastingCase) return isAr ? 'صائم' : 'Fasting';
    if (isFedCase) return isAr ? 'فاطر' : 'Fed';

    if (isAr) {
      switch (val) {
        case 'type 1':
          return 'النوع الأول';
        case 'type 2':
          return 'النوع الثاني';
        case 'gestational':
          return 'سكر الحمل';
        case 'insulin':
          return 'إنسولين';
        case 'pills':
        case 'tablets':
          return 'حبوب';
        case 'diet':
          return 'نظام غذائي';
        case 'none':
          return 'بدون علاج';
        case 'random':
          return 'عشوائي';
        case 'normal':
          return 'طبيعي';
        case 'high':
          return 'مرتفع';
        case 'low':
          return 'منخفض';
        default:
          return value.trim();
      }
    } else {
      switch (val) {
        case 'النوع الأول':
          return 'Type 1';
        case 'النوع الثاني':
          return 'Type 2';
        case 'سكر الحمل':
          return 'Gestational';
        case 'إنسولين':
          return 'Insulin';
        case 'حبوب':
        case 'أقراص':
          return 'Pills';
        case 'نظام غذائي':
          return 'Diet';
        case 'بدون علاج':
          return 'None';
        case 'عشوائي':
          return 'Random';
        case 'طبيعي':
          return 'Normal';
        case 'مرتفع':
          return 'High';
        case 'منخفض':
          return 'Low';
        default:
          return value.trim();
      }
    }
  }

  static pw.Widget _text(String text,
      {pw.TextStyle? style, pw.TextAlign? textAlign}) {
    final reshaped = ArabicReshaper().reshape(text);
    final visualText = String.fromCharCodes(bidi.logicalToVisual(reshaped));
    return pw.Directionality(
      textDirection: pw.TextDirection.ltr,
      child: pw.Text(
        visualText,
        style: style,
        textAlign: textAlign,
      ),
    );
  }

  static Future<void> generateAndShareReport({
    required Map<String, dynamic> userData,
    required List<Map<String, dynamic>> readings,
    required String langCode,
  }) async {
    final pdf = pw.Document();
    final bool isAr = langCode == 'ar';

    final fontData = await PdfGoogleFonts.cairoRegular();
    final boldFontData = await PdfGoogleFonts.cairoBold();

    pw.MemoryImage? logoImage;
    try {
      final ByteData bytes =
          await rootBundle.load('assets/images/logo_light.png');
      logoImage = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {}

    final now = DateTime.now();
    final String formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final String formattedTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    const title = 'GlucoTrack';
    final subTitle = isAr ? 'تقرير السكر الطبي' : 'Medical Glucose Report';
    final dateLabel = isAr ? 'التاريخ' : 'Date';
    final timeLabel = isAr ? 'الوقت' : 'Time';
    final patientInfoLabel = isAr ? 'بيانات المريض' : 'Patient Information';
    final nameLabel = isAr ? 'الاسم' : 'Name';
    final ageLabel = isAr ? 'العمر' : 'Age';
    final weightLabel = isAr ? 'الوزن' : 'Weight';
    final typeLabel = isAr ? 'نوع السكر' : 'Diabetes Type';
    final treatmentLabel = isAr ? 'العلاج' : 'Treatment';
    final mealContextLabel = isAr ? 'صائم / فاطر' : 'Fasting / Fed';
    final valueLabel = isAr ? 'القراءة (mg/dL)' : 'Reading (mg/dL)';
    final statusLabel = isAr ? 'الحالة' : 'Status';

    final sortedReadings = List<Map<String, dynamic>>.from(readings);
    sortedReadings.sort((a, b) {
      final dateTimeA = '${a['date'] ?? ''} ${a['time'] ?? ''}';
      final dateTimeB = '${b['date'] ?? ''} ${b['time'] ?? ''}';
      return dateTimeA.compareTo(dateTimeB);
    });

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        textDirection: isAr ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        theme: pw.ThemeData.withFont(
          base: fontData,
          bold: boldFontData,
        ),
        build: (pw.Context context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Row(
                  children: [
                    if (logoImage != null)
                      pw.Container(
                        width: 45,
                        height: 45,
                        margin: const pw.EdgeInsets.symmetric(horizontal: 8),
                        child: pw.Image(logoImage),
                      ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _text(title,
                            style: pw.TextStyle(
                                fontSize: 20,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue900)),
                        _text(subTitle,
                            style: const pw.TextStyle(
                                fontSize: 11, color: PdfColors.grey700)),
                      ],
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _text('$dateLabel: $formattedDate',
                        style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 4),
                    _text('$timeLabel: $formattedTime',
                        style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(thickness: 1, color: PdfColors.blue200),
            pw.SizedBox(height: 12),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _text(patientInfoLabel,
                      style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900)),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      _text('$nameLabel: ${userData['name'] ?? 'N/A'}',
                          style: const pw.TextStyle(fontSize: 10)),
                      _text('$ageLabel: ${userData['age'] ?? 'N/A'}',
                          style: const pw.TextStyle(fontSize: 10)),
                      _text('$weightLabel: ${userData['weight'] ?? 'N/A'}',
                          style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      _text(
                          '$typeLabel: ${_translateValue(userData['diabetesType']?.toString(), isAr)}',
                          style: const pw.TextStyle(fontSize: 10)),
                      _text(
                          '$treatmentLabel: ${_translateValue(userData['treatmentType']?.toString(), isAr)}',
                          style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 15),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.blue100),
                  children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: _text(dateLabel,
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: _text(timeLabel,
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: _text(mealContextLabel,
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: _text(valueLabel,
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: _text(statusLabel,
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                ...sortedReadings.map((item) {
                  final statusText =
                      _translateValue(item['status']?.toString(), isAr);

                  // قراءة isFasting من الداتا وتحويلها لنص
                  final rawMealStatus = item['isFasting'];
                  final mealStatusText =
                      _translateValue(rawMealStatus?.toString(), isAr);

                  return pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: _text(item['date']?.toString() ?? '',
                              style: const pw.TextStyle(fontSize: 10))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: _text(item['time']?.toString() ?? '',
                              style: const pw.TextStyle(fontSize: 10))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: _text(mealStatusText,
                              style: const pw.TextStyle(fontSize: 10))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: _text(item['value']?.toString() ?? '',
                              style: const pw.TextStyle(fontSize: 10))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: _text(statusText,
                              style: const pw.TextStyle(fontSize: 10))),
                    ],
                  );
                }),
              ],
            ),
          ];
        },
      ),
    );

    final Uint8List bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: 'GlucoTrack_Report.pdf');
  }
}
