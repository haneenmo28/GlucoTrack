import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'caregiver_profile.dart';
import 'qr_scanner_screen.dart';
import 'login_screen.dart';

class CaregiverHomeScreen extends StatefulWidget {
  const CaregiverHomeScreen({super.key});

  @override
  State<CaregiverHomeScreen> createState() => _CaregiverHomeScreenState();
}

class _CaregiverHomeScreenState extends State<CaregiverHomeScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = true;
  bool _isLinking = false;
  String? _linkedPatientId;

  Stream<QuerySnapshot>? _readingsStream;

  String _caregiverName = 'Caregiver';
  String _patientName = 'المريض';
  String _patientAge = '--';
  String _patientWeight = '--';
  String _patientDiabetesType = '--';
  String _patientTreatment = '--';

  final List<Map<String, dynamic>> _caregiverTipsList = [
    {
      'tags': ['general', 'support'],
      'ar':
          'أنتِ شريك داعم ولستِ شرطياً. ركزي على التشجيع بدلاً من التوبيخ عند ارتفاع السكر 🫂',
      'en':
          'You are a supportive partner, not a police officer. Focus on encouragement rather than scolding for high readings 🫂'
    },
    {
      'tags': ['general', 'mental_health'],
      'ar':
          'تجنب سؤال "ماذا أكلت؟" فور رؤية قراءة مرتفعة. السكر يتأثر بالتوتر، الهرمونات، والنوم وليس الأكل فقط 🛑',
      'en':
          'Avoid asking "What did you eat?" right after a high reading. Blood sugar is affected by stress, hormones, and sleep, not just food 🛑'
    },
    {
      'tags': ['general', 'parent'],
      'ar':
          'احتفلوا بالانتصارات الصغيرة! استقرار التراكمي ولو بنسبة قليلة هو مجهود جبار يستحق الثناء 🎉',
      'en':
          'Celebrate small victories! Even a slight stabilization in A1C is a massive effort worth praising 🎉'
    },
    {
      'tags': ['general', 'mental_health'],
      'ar':
          'اسأل المريض: "كيف يمكنني مساعدتك اليوم؟" بدلاً من إخباره بما يجب عليه فعله 🗣️',
      'en':
          'Ask the patient: "How can I help you today?" instead of telling them what to do 🗣️'
    },
    {
      'tags': ['general', 'support'],
      'ar':
          'الإرهاق من السكري حقيقي (Diabetes Burnout). إذا شعرتِ أن المريض يائس، فقط استمعي له وتفهمي مشاعره ❤️',
      'en':
          'Diabetes burnout is real. If the patient feels overwhelmed, just listen and validate their feelings ❤️'
    },
    {
      'tags': ['general', 'family'],
      'ar':
          'اجعلوا النظام الغذائي الصحي نظاماً للأسرة كلها، وليس "عقاباً" للمريض وحده 🥗',
      'en':
          'Make the healthy diet a lifestyle for the whole family, not a "punishment" just for the patient 🥗'
    },
    {
      'tags': ['general', 'mental_health'],
      'ar':
          'لا تصابي بالذعر من قراءة واحدة مرتفعة. السكري هو ماراثون وليس سباق سرعة 🏃‍♀️',
      'en':
          'Don\'t panic over a single high reading. Diabetes management is a marathon, not a sprint 🏃‍♀️'
    },
    {
      'tags': ['general', 'support'],
      'ar':
          'المرضى غالباً ما يشعرون بالذنب عند تذبذب القراءات، دوركِ هو إخبارهم أن الأرقام هي معلومات وليست درجات تقييم 📊',
      'en':
          'Patients often feel guilty when numbers fluctuate. Your role is to remind them that numbers are data, not a grade 📊'
    },
    {
      'tags': ['parent', 'child'],
      'ar':
          'إذا كان المريض طفلاً، علميه الاستقلالية تدريجياً ليكون هو مدير صحته الأول 🦸‍♂️',
      'en':
          'If the patient is a child, gradually teach them independence so they become the primary manager of their health 🦸‍♂️'
    },
    {
      'tags': ['general', 'mental_health'],
      'ar':
          'تذكري أن تعتني بنفسكِ أيضاً. "مقدم الرعاية المجهد لا يستطيع تقديم رعاية جيدة" ☕',
      'en':
          'Remember to care for yourself too. "A burnt-out caregiver cannot give good care" ☕'
    },

    {
      'tags': ['emergency', 'hypo', 'insulin'],
      'ar':
          'اعرفي قاعدة الـ 15 للهبوط: 15 جرام كربوهيدرات سريعة، ثم انتظار 15 دقيقة للقياس. لا تبالغي في إعطاء السكريات ⏱️',
      'en':
          'Know the 15-15 rule for lows: 15g fast carbs, wait 15 mins to test. Don\'t overtreat with sugar ⏱️'
    },
    {
      'tags': ['emergency', 'hypo'],
      'ar':
          'في حالة الهبوط الشديد (فقدان الوعي)، لا تضعي أي شيء في فم المريض! استخدمي حقنة الجلوكاجون فوراً أو اتصلي بالإسعاف 🚑',
      'en':
          'In severe lows (unconsciousness), NEVER put food in their mouth! Use a Glucagon pen immediately or call an ambulance 🚑'
    },
    {
      'tags': ['emergency', 'hypo'],
      'ar':
          'تغير المزاج المفاجئ، العصبية، أو التعرق قد تكون من علامات هبوط السكر. اطلبي منه القياس بهدوء ⚠️',
      'en':
          'Sudden mood swings, irritability, or sweating can be signs of a low. Calmly suggest they test ⚠️'
    },
    {
      'tags': ['emergency', 'hyper', 'type 1'],
      'ar':
          'إذا كان السكر مرتفعاً جداً (فوق 250) وكان هناك غثيان، افحصي الكيتونات فوراً واذهبي للمستشفى إذا كانت إيجابية 🧪',
      'en':
          'If sugar is very high (over 250) with nausea, check for ketones immediately and go to the ER if positive 🧪'
    },
    {
      'tags': ['emergency', 'general'],
      'ar':
          'تأكدي من وجود "عصير أو حلوى سريعة" في سيارتك، حقيبتك، وبجوار سرير المريض دائماً 🧃',
      'en':
          'Always keep fast-acting carbs (juice/candy) in your car, your bag, and on the patient\'s nightstand 🧃'
    },
    {
      'tags': ['emergency', 'general'],
      'ar':
          'أثناء نوبات الهبوط، قد يتصرف المريض بعدوانية أو تشوش. لا تأخذي الأمر بشكل شخصي، هذا تأثير نقص جلوكوز المخ 🧠',
      'en':
          'During a low, the patient might act aggressively or confused. Don\'t take it personally; it\'s the brain lacking glucose 🧠'
    },
    {
      'tags': ['emergency', 'hyper'],
      'ar':
          'في حالة ارتفاع السكر بدون كيتونات، شجعي المريض على شرب الكثير من الماء لمساعدة الكلى في طرد السكر 🚰',
      'en':
          'For high blood sugar without ketones, encourage drinking lots of water to help kidneys flush out the sugar 🚰'
    },
    {
      'tags': ['emergency', 'doctor'],
      'ar':
          'احفظي أرقام الطوارئ ورقم الطبيب المعالج في قائمة الاتصال السريع بهاتفك 📞',
      'en':
          'Save emergency contacts and the endocrinologist\'s number on your phone\'s speed dial 📞'
    },
    {
      'tags': ['emergency', 'type 1', 'insulin'],
      'ar':
          'تعلمي كيفية استخدام قلم الجلوكاجون (إبرة الطوارئ للهبوط). تدربي عليها لتكوني مستعدة 💉',
      'en':
          'Learn how to use a Glucagon pen (emergency low kit). Practice the steps so you are ready 💉'
    },
    {
      'tags': ['emergency', 'general'],
      'ar':
          'تأكدي أن المريض يرتدي دائماً "سوار تنبيه طبي" يوضح إصابته بالسكري 📿',
      'en':
          'Ensure the patient always wears a medical alert bracelet indicating they have diabetes 📿'
    },

    // 🍽️ الغذاء والتخطيط اليومي
    {
      'tags': ['diet', 'general'],
      'ar':
          'تعلمي أساسيات "حساب الكربوهيدرات" (Carb Counting). سيساعدك ذلك في التخطيط لوجبات تمنع الارتفاعات المفاجئة ⚖️',
      'en':
          'Learn the basics of "Carb Counting". It will help you plan meals that prevent sudden spikes ⚖️'
    },
    {
      'tags': ['diet', 'general'],
      'ar':
          'استبدال النشويات البيضاء بالحبوب الكاملة يقلل من مؤشر الجهد السكري للوجبة (Glycemic Index) 🌾',
      'en':
          'Replacing white carbs with whole grains lowers the Glycemic Index of the meal 🌾'
    },
    {
      'tags': ['diet', 'cooking'],
      'ar':
          'عند الطبخ، إضافة الدهون الصحية (زيت زيتون، مكسرات) للنشويات يبطئ من امتصاص السكر في الدم 🥑',
      'en':
          'When cooking, adding healthy fats (olive oil, nuts) to carbs slows down sugar absorption 🥑'
    },
    {
      'tags': ['diet', 'general'],
      'ar':
          'ساعدي المريض في قراءة الملصقات الغذائية والبحث عن الكربوهيدرات الكلية، وليس "السكر" فقط 🏷️',
      'en':
          'Help the patient read nutrition labels, focusing on Total Carbohydrates, not just "Sugar" 🏷️'
    },
    {
      'tags': ['diet', 'general'],
      'ar':
          'حضري وجبات خفيفة صحية مقطعة (خيار، جزر، مكسرات) لتكون جاهزة عند شعور المريض بالجوع 🥕',
      'en':
          'Prep healthy snacks (cucumber, carrots, nuts) so they are ready when the patient is hungry 🥕'
    },
    {
      'tags': ['diet', 'type 2', 'pills'],
      'ar':
          'وجبة العشاء المتأخرة الدسمة هي العدو الأول لقراءات الصباح (Fasting Blood Sugar). اجعلي العشاء خفيفاً ومبكراً 🍽️',
      'en':
          'A late heavy dinner is the main enemy of morning fasting readings. Keep dinner light and early 🍽️'
    },
    {
      'tags': ['diet', 'cooking'],
      'ar':
          'تجنبي القلي واستخدمي الشواء أو الطهي بالبخار للحفاظ على وزن صحي وتقليل مقاومة الإنسولين 🍳',
      'en':
          'Avoid frying; use grilling or steaming to maintain a healthy weight and reduce insulin resistance 🍳'
    },
    {
      'tags': ['diet', 'general'],
      'ar':
          'شرب الماء قبل الوجبة بـ 15 دقيقة يساعد في تقليل كمية الطعام المستهلكة 💧',
      'en':
          'Drinking water 15 minutes before a meal helps reduce the amount of food consumed 💧'
    },
    {
      'tags': ['diet', 'general'],
      'ar':
          'لا تمنعي عنه الحلويات تماماً! يمكن دمج قطعة صغيرة من الحلوى بعد وجبة متوازنة غنية بالألياف 🍫',
      'en':
          'Don\'t ban sweets entirely! A small piece can be integrated right after a balanced, high-fiber meal 🍫'
    },
    {
      'tags': ['diet', 'family'],
      'ar':
          'إخفاء الأطعمة غير الصحية في المنزل يقلل من "الإغراءات" ويدعم المريض نفسياً 🏠',
      'en':
          'Keeping unhealthy foods out of the house reduces "temptations" and supports the patient psychologically 🏠'
    },

    {
      'tags': ['medication', 'insulin'],
      'ar':
          'ذكري المريض بتغيير مكان حقن الإنسولين لمنع التليفات (Lipo-hypertrophy) التي تضعف امتصاص الدواء 🔄',
      'en':
          'Remind the patient to rotate injection sites to prevent lumps that block insulin absorption 🔄'
    },
    {
      'tags': ['medication', 'insulin'],
      'ar':
          'احرصي على تخزين أقلام الإنسولين غير المفتوحة في الثلاجة، والمفتوحة في درجة حرارة الغرفة (بعيداً عن الحرارة) 🧊',
      'en':
          'Store unopened insulin pens in the fridge, and in-use pens at room temp (away from heat) 🧊'
    },
    {
      'tags': ['medication', 'general'],
      'ar':
          'رتبي الأدوية في علبة مقسمة حسب الأيام (Pill Organizer) لتجنب نسيان أي جرعة 💊',
      'en': 'Use a daily pill organizer to ensure no doses are forgotten 💊'
    },
    {
      'tags': ['medication', 'doctor'],
      'ar':
          'سجلي أسئلتك وملاحظاتك في نوتة قبل زيارة الطبيب، الوقت في العيادة يمر بسرعة وغالباً ما ننسى 📝',
      'en':
          'Write down your questions and notes before the doctor\'s visit; clinic time flies and we often forget 📝'
    },
    {
      'tags': ['medication', 'general'],
      'ar':
          'تابعي تواريخ صلاحية شرائط تحليل السكر، الشرائط المنتهية تعطي قراءات خاطئة تماماً 📆',
      'en':
          'Check the expiry dates on test strips; expired strips give completely wrong readings 📆'
    },
    {
      'tags': ['medication', 'doctor'],
      'ar':
          'احرصي على تذكير المريض بمواعيد الفحوصات الدورية (العين، الكلى، القدمين) فهي أهم من قراءات السكر اليومية 👁️',
      'en':
          'Remind the patient of annual checkups (eyes, kidneys, feet). They are as important as daily readings 👁️'
    },
    {
      'tags': ['medication', 'type 2', 'pills'],
      'ar':
          'بعض أدوية السكري (مثل الميتفورمين) قد تسبب اضطرابات في المعدة في البداية، شجعيه على أخذها وسط الأكل 🍽️',
      'en':
          'Some diabetes pills (like Metformin) can cause initial stomach upset. Suggest taking them mid-meal 🍽️'
    },
    {
      'tags': ['medication', 'general'],
      'ar':
          'تأكدي من غسل يدي المريض وتجفيفها جيداً قبل الوخز، بقايا الطعام على الإصبع ترفع القراءة الوهمية 🧼',
      'en':
          'Ensure the patient washes and dries their hands before pricking. Food residue causes fake high readings 🧼'
    },
    {
      'tags': ['medication', 'general'],
      'ar':
          'لا تغيري جرعات الدواء من تلقاء نفسك بناءً على قراءة واحدة، العودة للطبيب هي الأساس 👨‍⚕️',
      'en':
          'Never adjust medication doses on your own based on one reading. Always consult the doctor 👨‍⚕️'
    },
    {
      'tags': ['medication', 'insulin', 'type 1'],
      'ar':
          'المرض (كالبرد أو الإنفلونزا) يرفع السكر. اسألي طبيبك عن "خطة الأيام المرضية" (Sick Day Rules) 🤒',
      'en':
          'Illness (like a cold) raises blood sugar. Ask your doctor about "Sick Day Rules" 🤒'
    },

    {
      'tags': ['lifestyle', 'exercise'],
      'ar':
          'شجعي المريض على رياضة المشي، ومرافقته فيها تعتبر دعماً نفسياً رائعاً وحرقاً للسكريات 🚶‍♀️',
      'en':
          'Encourage walking. Accompanying the patient is great emotional support and helps burn sugar 🚶‍♀️'
    },
    {
      'tags': ['lifestyle', 'exercise'],
      'ar':
          'تذكري دائماً قياس السكر قبل الرياضة. إذا كان أقل من 100، يجب تناول سناك خفيف أولاً 🍌',
      'en':
          'Always remind them to test before exercise. If under 100, they need a small snack first 🍌'
    },
    {
      'tags': ['lifestyle', 'care'],
      'ar':
          'القدم السكري تبدأ بجرح صغير. ذكري المريض بتفقد قدميه يومياً والبحث عن أي احمرار أو تشقق 👣',
      'en':
          'Diabetic foot starts with a tiny cut. Remind them to inspect their feet daily for redness or cracks 👣'
    },
    {
      'tags': ['lifestyle', 'care'],
      'ar':
          'اشتري جوارب قطنية مريحة بدون حواف قاسية أو أستيك ضيق يمنع الدورة الدموية 🧦',
      'en':
          'Buy comfortable cotton socks without harsh seams or tight elastic that restricts circulation 🧦'
    },
    {
      'tags': ['lifestyle', 'sleep'],
      'ar':
          'النوم المتقطع يفرز الكورتيزول ويرفع السكر صباحاً. وفري بيئة نوم هادئة ومريحة للمريض 😴',
      'en':
          'Broken sleep releases cortisol and causes high morning sugar. Provide a quiet, comfortable sleep environment 😴'
    },
    {
      'tags': ['lifestyle', 'travel'],
      'ar':
          'عند السفر، احملي ضعف كمية الأدوية والشرائط المعتادة في حقيبة يدكِ وليس في حقائب الشحن ✈️',
      'en':
          'When traveling, pack twice the usual amount of meds and strips in your carry-on, not checked bags ✈️'
    },
    {
      'tags': ['lifestyle', 'exercise'],
      'ar':
          'الأعمال المنزلية (كالتنظيف والبستنة) تعتبر نشاطاً بدنياً ممتازاً يخفض السكر تدريجياً 🧹',
      'en':
          'Household chores (like cleaning and gardening) are excellent physical activities that lower sugar gradually 🧹'
    },
    {
      'tags': ['lifestyle', 'care'],
      'ar':
          'حذري المريض من قص الأظافر بشكل دائري، يجب قصها بشكل مستقيم لتجنب غرس الظفر في اللحم ✂️',
      'en':
          'Warn the patient against cutting nails in a curve; they should be cut straight across to avoid ingrown nails ✂️'
    },
    {
      'tags': ['lifestyle', 'care'],
      'ar':
          'تجنبي استخدام "قربة الماء الساخن" لتدفئة قدمي المريض، الإحساس لديه قد يكون ضعيفاً وتسبب حروقاً خطيرة 🔥',
      'en':
          'Avoid using a "hot water bottle" to warm their feet; reduced sensation can lead to severe burns 🔥'
    },
    {
      'tags': ['lifestyle', 'doctor'],
      'ar':
          'لا توجد أجهزة قياس سكر دقيقة 100%. هامش الخطأ المسموح به طبياً هو ±15%، فلا تدققي في الأرقام المتقاربة جداً 📉',
      'en':
          'No glucose meter is 100% accurate. The medical margin of error is ±15%, so don\'t obsess over very close numbers 📉'
    },
  ];

  Map<String, dynamic>? _currentTip;

  @override
  void initState() {
    super.initState();
    _checkIfLinked();
    _generateRandomTip();
  }

  void _generateRandomTip() {
    if (_caregiverTipsList.isNotEmpty) {
      final random = (List.from(_caregiverTipsList)..shuffle()).first;
      setState(() {
        _currentTip = random;
      });
    }
  }

  Future<void> _checkIfLinked() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          final caregiverData = doc.data()!;
          _caregiverName = caregiverData['name']?.toString() ?? 'Caregiver';

          if (caregiverData.containsKey('linkedPatientId')) {
            final patientId = caregiverData['linkedPatientId'];
            final patientDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(patientId)
                .get();

            if (mounted) {
              setState(() {
                _linkedPatientId = patientId;

                _readingsStream = FirebaseFirestore.instance
                    .collection('readings')
                    .where('userId', isEqualTo: patientId)
                    .orderBy('timestamp', descending: true)
                    .snapshots();

                if (patientDoc.exists) {
                  final data = patientDoc.data()!;
                  _patientName = data['name']?.toString() ?? 'المريض';
                  _patientAge = data['age']?.toString() ?? '--';
                  _patientWeight = data['weight']?.toString() ?? '--';
                  _patientDiabetesType =
                      data['diabetesType'] ?? data['diabetes_type'] ?? '--';
                  _patientTreatment =
                      data['treatment'] ?? data['treatmentType'] ?? '--';
                }
              });
            }
          }
        }
      } catch (e) {
        debugPrint("Error checking link status: $e");
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _linkPatient() async {
    final code = _codeController.text.trim();
    final lang = context.locale.languageCode;

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(lang == 'ar'
              ? 'يرجى إدخال كود صحيح من 6 أرقام'
              : 'Please enter a valid 6-digit code')));
      return;
    }

    setState(() => _isLinking = true);

    try {
      int? numericCode = int.tryParse(code);
      var querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('linkCode', isEqualTo: code)
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(lang == 'ar'
                  ? 'الكود غير صحيح أو المريض غير موجود'
                  : 'Invalid code or patient not found')));
          setState(() => _isLinking = false);
        }
        return;
      }

      final patientDoc = querySnapshot.docs.first;
      final patientId = patientDoc.id;
      final data = patientDoc.data();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({'linkedPatientId': patientId}, SetOptions(merge: true));

        if (mounted) {
          setState(() {
            _linkedPatientId = patientId;

            _readingsStream = FirebaseFirestore.instance
                .collection('readings')
                .where('userId', isEqualTo: patientId)
                .orderBy('timestamp', descending: true)
                .snapshots();

            _patientName = data['name']?.toString() ?? 'المريض';
            _patientAge = data['age']?.toString() ?? '--';
            _patientWeight = data['weight']?.toString() ?? '--';
            _patientDiabetesType =
                data['diabetesType'] ?? data['diabetes_type'] ?? '--';
            _patientTreatment =
                data['treatment'] ?? data['treatmentType'] ?? '--';
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(lang == 'ar'
                  ? 'تم الربط بنجاح مع $_patientName!'
                  : 'Successfully linked with $_patientName!'),
              backgroundColor: Colors.teal));
        }
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(lang == 'ar'
                ? 'حدث خطأ، يرجى المحاولة'
                : 'Network error, please try again')));
    } finally {
      if (mounted) setState(() => _isLinking = false);
    }
  }

  // دالة تصدير الـ PDF
  Future<void> _generateAndSharePdf(
      List<QueryDocumentSnapshot> readings, String lang) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            lang == 'ar' ? 'جاري تجهيز التقرير...' : 'Generating Report...'),
        duration: const Duration(seconds: 1)));

    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicFontBold = await PdfGoogleFonts.cairoBold();
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFontBold),
        build: (pw.Context context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('GlucoTrack',
                          style: pw.TextStyle(
                              fontSize: 22,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.indigo900)),
                      pw.SizedBox(height: 4),
                      pw.Text('Medical Glucose Report',
                          style: const pw.TextStyle(
                              fontSize: 12, color: PdfColors.grey700)),
                    ]),
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                          'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
                          style: const pw.TextStyle(fontSize: 10)),
                      pw.Text(
                          'Time: ${DateFormat('hh:mm a').format(DateTime.now())}',
                          style: const pw.TextStyle(fontSize: 10)),
                    ]),
              ],
            ),
            pw.Divider(height: 20, thickness: 1, color: PdfColors.blueGrey200),
            pw.Container(
              padding: pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.blueGrey100)),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Patient Information',
                        style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.indigo900)),
                    pw.SizedBox(height: 8),
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Row(children: [
                            pw.Text('Name: ',
                                style: const pw.TextStyle(fontSize: 11)),
                            pw.Text(_patientName,
                                style: const pw.TextStyle(fontSize: 11),
                                textDirection: pw.TextDirection.rtl)
                          ]),
                          pw.Text('Age: $_patientAge',
                              style: const pw.TextStyle(fontSize: 11)),
                          pw.Text('Weight: $_patientWeight',
                              style: const pw.TextStyle(fontSize: 11)),
                        ]),
                    pw.SizedBox(height: 6),
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Row(children: [
                            pw.Text('Diabetes Type: ',
                                style: const pw.TextStyle(fontSize: 11)),
                            pw.Text(_patientDiabetesType,
                                style: const pw.TextStyle(fontSize: 11),
                                textDirection: pw.TextDirection.rtl)
                          ]),
                          pw.Row(children: [
                            pw.Text('Treatment: ',
                                style: const pw.TextStyle(fontSize: 11)),
                            pw.Text(_patientTreatment,
                                style: const pw.TextStyle(fontSize: 11),
                                textDirection: pw.TextDirection.rtl)
                          ]),
                        ]),
                  ]),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: [
                'Date',
                'Time',
                'Fasting / Fed',
                'Reading (mg/dL)',
                'Status'
              ],
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  fontSize: 10),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.indigo900),
              cellStyle: const pw.TextStyle(fontSize: 10),
              cellAlignment: pw.Alignment.centerLeft,
              data: readings.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final level = data['glucoseLevel'] ?? '--';
                final timestamp = data['timestamp'] as Timestamp?;
                final type = data['type'] ?? 'Fasting';
                String dateStr = '';
                String timeStr = '';
                if (timestamp != null) {
                  final dt = timestamp.toDate();
                  dateStr = DateFormat('yyyy-MM-dd').format(dt);
                  timeStr = DateFormat('hh:mm a').format(dt);
                }
                int numLevel = int.tryParse(level.toString()) ?? 0;
                String status = numLevel > 180
                    ? 'High'
                    : (numLevel < 70 && numLevel > 0 ? 'Low' : 'Normal');
                return [dateStr, timeStr, type, '$level.0', status];
              }).toList(),
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    await Printing.sharePdf(
        bytes: bytes,
        filename:
            'GlucoTrack_Report_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // تعريف الألوان بناءً على حالة الـ isDarkMode اللي جاية من الأبلكيشن
    final bgColor =
        isDarkMode ? const Color(0xFF101014) : const Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: bgColor,
      // ... باقي الكود بتاعك (Stack والـ SingleChildScrollView)
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : _linkedPatientId != null
              ? _buildDashboard(isDarkMode, lang)
              : _buildLinkingScreen(isDarkMode, lang),
    );
  }

  Widget _buildDashboard(bool isDark, String lang) {
    final headerColor =
        isDark ? const Color(0xFF0B0742) : const Color.fromARGB(255, 6, 0, 59);
    final cardColor = isDark ? const Color(0xFF1A1A22) : Colors.white;

    return Stack(
      children: [
        Positioned.fill(
          top: 170,
          child: Opacity(
            opacity: isDark ? 0.5 : 0.8,
            child: Center(
              child: Image.asset(
                isDark
                    ? 'assets/images/logo_dark.png'
                    : 'assets/images/logo_light.png',
                width: 250,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Column(
          children: [
            // --- Custom App Bar ---
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35)),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // حطينا SizedBox فاضي مكان زرار اللوج أوت عشان نحافظ على التوسيط
                          const SizedBox(width: 48),

                          Text('Stay CALM, Stay BALANCED ❤️',
                              style: TextStyle(
                                  color: Colors.amber.shade400,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17)),

                          IconButton(
                            icon: const Icon(Icons.picture_as_pdf_rounded,
                                color: Colors.white70),
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('readings')
                                  .where('userId', isEqualTo: _linkedPatientId)
                                  .orderBy('timestamp', descending: true)
                                  .get()
                                  .then((snapshot) {
                                if (snapshot.docs.isNotEmpty) {
                                  _generateAndSharePdf(snapshot.docs, lang);
                                }
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  lang == 'ar'
                                      ? 'مرحباً بعودتك،'
                                      : 'Welcome back,',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 16)),
                              const SizedBox(height: 5),
                              Text('$_caregiverName ❤️',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  lang == 'ar'
                                      ? 'نعتني بـ $_patientName معاً ❤️'
                                      : 'Taking care of $_patientName together ❤️',
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic)),
                            ],
                          ),

                          // --- إضافة GestureDetector للبروفايل هنا ---
                          GestureDetector(
                            onTap: () {
                              // الكود ده بينقلك لصفحة البروفايل لما تدوسي على الدايرة
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CaregiverProfileScreen(),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white24, width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 26,
                                // استخدمنا withValues عشان نتجنب الخط الأصفر بتاع withOpacity
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.1),
                                child: const Icon(
                                  Icons.person_outline_rounded,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    _readingsStream, // ✅ استخدام المتغير هنا لمنع التحميل اللانهائي
                builder: (context, snapshot) {
                  // ✅ فحص الأخطاء أولاً
                  if (snapshot.hasError) {
                    print(
                        "🔥 Firebase Error: ${snapshot.error}"); // السطر ده هيظهرلك اللينك
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'حدث خطأ: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.teal));
                  }

                  final readings = snapshot.hasData ? snapshot.data!.docs : [];
                  double totalSum = 0;
                  for (var doc in readings) {
                    final data = doc.data() as Map<String, dynamic>;
                    totalSum +=
                        double.tryParse(data['glucoseLevel'].toString()) ?? 0;
                  }
                  int averageLevel = readings.isNotEmpty
                      ? (totalSum / readings.length).round()
                      : 0;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Card(
                                color: isDark
                                    ? const Color(0xFF1E2749)
                                    : Colors.teal.shade50,
                                elevation: isDark ? 0 : 2,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: BorderSide(
                                        color: isDark
                                            ? Colors.transparent
                                            : Colors.teal.shade200)),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  child: Column(
                                    children: [
                                      Text(lang == 'ar' ? 'المتوسط' : 'Average',
                                          style: TextStyle(
                                              color: isDark
                                                  ? Colors.white70
                                                  : Colors.teal.shade700,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 5),
                                      Text('$averageLevel',
                                          style: TextStyle(
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.teal.shade900,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Card(
                                color: isDark
                                    ? const Color(0xFF2B1B3D)
                                    : Colors.orange.shade50,
                                elevation: isDark ? 0 : 2,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: BorderSide(
                                        color: isDark
                                            ? Colors.transparent
                                            : Colors.orange.shade200)),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  child: Column(
                                    children: [
                                      Text(
                                          lang == 'ar'
                                              ? 'إجمالي القراءات'
                                              : 'Total Readings',
                                          style: TextStyle(
                                              color: isDark
                                                  ? Colors.white70
                                                  : Colors.orange.shade700,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 5),
                                      Text('${readings.length}',
                                          style: TextStyle(
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.orange.shade900,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        if (_currentTip != null)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_caregiverTipsList.isNotEmpty) {
                                  _currentTip = (List.from(_caregiverTipsList)
                                        ..shuffle())
                                      .first;
                                }
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.1)
                                        : Colors.amber.withValues(alpha: 0.4),
                                    width: isDark ? 1 : 1.5),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.lightbulb_circle_rounded,
                                      color: Colors.amber, size: 30),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lang == 'ar'
                                              ? 'نصيحة اليوم (اضغط للتغيير)'
                                              : 'Tip of the day (Tap to change)',
                                          style: const TextStyle(
                                              color: Colors.amber,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _currentTip != null
                                              ? (lang == 'ar'
                                                  ? _currentTip!['ar']
                                                  : _currentTip!['en'])
                                              : (lang == 'ar'
                                                  ? 'أنتِ شريك داعم ولستِ شرطياً. ركزي على التشجيع 🫂'
                                                  : 'You are a supportive partner, not a police officer 🫂'),
                                          style: TextStyle(
                                              color: isDark
                                                  ? Colors.white70
                                                  : Colors.black87,
                                              fontSize: 13,
                                              height: 1.4),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 30),
                        Text(
                            lang == 'ar'
                                ? 'سجل قراءات المريض'
                                : 'Patient Readings',
                            style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),

                        // --- Last Readings List ---
                        if (readings.isEmpty)
                          Center(
                              child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                                lang == 'ar'
                                    ? 'لا توجد قراءات مسجلة'
                                    : 'No readings yet',
                                style: TextStyle(color: Colors.grey.shade500)),
                          ))
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: readings.length,
                            itemBuilder: (context, index) {
                              final data = readings[index].data()
                                  as Map<String, dynamic>;
                              final glucoseLevelStr =
                                  data['glucoseLevel']?.toString() ?? '0';
                              final glucoseLevel =
                                  int.tryParse(glucoseLevelStr) ?? 0;
                              final timestamp = data['timestamp'] as Timestamp?;
                              String timeStr = '';
                              if (timestamp != null)
                                timeStr = DateFormat('h:mm a')
                                    .format(timestamp.toDate());

                              Color statusColor = Colors.amber;
                              String statusText = 'Normal';
                              IconData statusIcon = Icons.info_outline_rounded;

                              if (glucoseLevel > 180) {
                                statusColor = Colors.redAccent;
                                statusText = 'High';
                                statusIcon = Icons.arrow_upward_rounded;
                              } else if (glucoseLevel < 70 &&
                                  glucoseLevel > 0) {
                                statusColor = Colors.lightBlueAccent;
                                statusText = 'Low';
                                statusIcon = Icons.arrow_downward_rounded;
                              }

                              return Container(
                                margin: const EdgeInsets.only(bottom: 15),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: isDark
                                      ? Border.all(
                                          color: Colors.white.withOpacity(0.05))
                                      : null,
                                  boxShadow: isDark
                                      ? []
                                      : [
                                          BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.03),
                                              blurRadius: 10)
                                        ],
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor:
                                          statusColor.withOpacity(0.12),
                                      radius: 24,
                                      child: Icon(statusIcon,
                                          color: statusColor, size: 24),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('$glucoseLevelStr mg/dL',
                                              style: TextStyle(
                                                  color: statusColor,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 2),
                                          Text(statusText,
                                              style: TextStyle(
                                                  color: statusColor,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 2),
                                          Text('No notes',
                                              style: TextStyle(
                                                  color: isDark
                                                      ? Colors.white54
                                                      : Colors.grey,
                                                  fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Text(timeStr,
                                        style: TextStyle(
                                            color: isDark
                                                ? Colors.white38
                                                : Colors.grey,
                                            fontSize: 12)),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
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

  // شاشة الربط
  Widget _buildLinkingScreen(bool isDark, String lang) {
    return SafeArea(
      child: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.family_restroom_rounded,
                          size: 80, color: Colors.teal)),
                  const SizedBox(height: 30),
                  Text(
                      lang == 'ar' ? 'اربط حسابك بمريض' : 'Link with a Patient',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color.fromARGB(255, 6, 0, 59))),
                  const SizedBox(height: 10),
                  Text(
                      lang == 'ar'
                          ? 'أدخل الكود المكون من 6 أرقام.'
                          : 'Enter the 6-digit code.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontSize: 15)),
                  const SizedBox(height: 40),
                  Container(
                    decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    child: TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 10,
                          color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                          counterText: "",
                          hintText: "000000",
                          hintStyle: TextStyle(
                              color: isDark
                                  ? Colors.white24
                                  : Colors.grey.shade300,
                              letterSpacing: 10),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 20)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                          onPressed: _isLinking ? null : _linkPatient,
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 6, 0, 59),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15))),
                          child: _isLinking
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  lang == 'ar' ? 'ربط الحساب' : 'Link Account',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)))),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const QRScannerScreen()),
                        );
                        _checkIfLinked();
                      },
                      icon: const Icon(Icons.qr_code_scanner_rounded,
                          color: Colors.teal),
                      label: Text(lang == 'ar' ? 'مسح رمز QR' : 'Scan QR Code',
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.teal,
                              fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                          side:
                              const BorderSide(color: Colors.teal, width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: lang == 'ar' ? null : 15,
            right: lang == 'ar' ? 15 : null,
            child: IconButton(
              icon: Icon(Icons.logout_rounded,
                  color: isDark ? Colors.white70 : Colors.black54, size: 28),
              onPressed: () => _handleLogout(lang),
              tooltip: lang == 'ar' ? 'تسجيل الخروج' : 'Logout',
            ),
          ),
        ],
      ),
    );
  }
}
