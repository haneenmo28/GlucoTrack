import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/firebase_service.dart';
import '../models/reading_model.dart';
import 'package:intl/intl.dart';
import 'profile_screen.dart';
import 'dart:math';

class AppImages {
  static const String logoLight = 'assets/images/logo_light.png';
  static const String logoDark = 'assets/images/logo_dark.png';

  static String getLogo(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? logoDark : logoLight;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<Map<String, dynamic>> _tipsList = [
    {
      'tags': ['general'],
      'ar':
          'شرب الماء بانتظام يساعد الكلى على طرد السكر الزائد من الدم عبر البول 💧',
      'en':
          'Drinking water regularly helps kidneys flush out excess sugar through urine 💧'
    },
    {
      'tags': ['general'],
      'ar':
          'الألياف هي صديقك! الخضروات الورقية تبطئ من امتصاص السكر في الدم 🥗',
      'en':
          'Fiber is your friend! Leafy greens slow down sugar absorption in the blood 🥗'
    },
    {
      'tags': ['general'],
      'ar':
          'استبدل العصائر المحلاة بثمرة الفاكهة الكاملة للاستفادة من الألياف وتجنب الارتفاع المفاجئ للسكر 🍎',
      'en':
          'Replace sugary juices with whole fruits to benefit from fiber and avoid sugar spikes 🍎'
    },
    {
      'tags': ['general'],
      'ar':
          'لا تفوت وجبة الإفطار! إنها تضبط إيقاع السكر وحساسية الإنسولين لباقي اليوم 🍳',
      'en':
          'Don\'t skip breakfast! It sets your blood sugar rhythm and insulin sensitivity for the day 🍳'
    },
    {
      'tags': ['type 2', 'diet', 'pills'],
      'ar':
          'قرفة، كركم، وزنجبيل.. بهارات مفيدة أثبتت الدراسات دورها في تحسين حساسية الإنسولين 🌿',
      'en':
          'Cinnamon, turmeric, and ginger are useful spices proven to improve insulin sensitivity 🌿'
    },
    {
      'tags': ['general'],
      'ar':
          'اعتمد على "طريقة الطبق": نصفه خضار، ربعه بروتين، وربعه نشويات معقدة 🍽️',
      'en':
          'Use the "Plate Method": half veggies, quarter protein, and quarter complex carbs 🍽️'
    },
    {
      'tags': ['general'],
      'ar':
          'المكسرات النيئة (كاللوز والجوز) وجبة خفيفة ممتازة لا ترفع السكر بسرعة 🥜',
      'en':
          'Raw nuts (like almonds and walnuts) are excellent snacks that don\'t spike sugar 🥜'
    },
    {
      'tags': ['general'],
      'ar':
          'تجنب الكربوهيدرات البسيطة كالدقيق الأبيض، واستبدلها بالحبوب الكاملة كالشوفان والبرغل 🌾',
      'en':
          'Avoid simple carbs like white flour, and replace them with whole grains like oats and bulgur 🌾'
    },
    {
      'tags': ['general'],
      'ar':
          'الدهون الصحية في زيت الزيتون والأفوكادو تحمي قلبك وتساعد في استقرار السكر 🥑',
      'en':
          'Healthy fats in olive oil and avocados protect your heart and stabilize sugar 🥑'
    },
    {
      'tags': ['general'],
      'ar':
          'اقرأ الملصقات الغذائية دائماً للبحث عن "السكريات المخفية" في الأطعمة الجاهزة 🔍',
      'en':
          'Always read nutrition labels to check for "hidden sugars" in processed foods 🔍'
    },

    {
      'tags': ['general'],
      'ar':
          'المشي لمدة 15 دقيقة بعد الوجبات يقلل من ارتفاع السكر بشكل ملحوظ جداً 🚶‍♂️',
      'en':
          'Walking for 15 mins after meals significantly reduces blood sugar spikes 🚶‍♂️'
    },
    {
      'tags': ['general'],
      'ar': 'ممارسة الرياضة تزيد من استهلاك العضلات للسكر حتى بدون إنسولين 💪',
      'en':
          'Exercise increases your muscles\' uptake of glucose even without insulin 💪'
    },
    {
      'tags': ['general'],
      'ar':
          'حاول الوصول لـ 150 دقيقة من النشاط البدني المعتدل أسبوعياً لحماية قلبك ⏱️',
      'en':
          'Aim for 150 minutes of moderate physical activity per week to protect your heart ⏱️'
    },
    {
      'tags': ['type 2', 'diet'],
      'ar':
          'تمارين المقاومة (رفع الأوزان الخفيفة) تبني عضلات تحرق السكر بفعالية أكبر 🏋️',
      'en':
          'Resistance training builds muscles that burn sugar more effectively 🏋️'
    },
    {
      'tags': ['insulin', 'type 1'],
      'ar':
          'افحص سكرك قبل ممارسة الرياضة، وإذا كان أقل من 100، تناول وجبة خفيفة أولاً 🍌',
      'en':
          'Check sugar before exercise. If it\'s under 100 mg/dL, have a light snack first 🍌'
    },

    // 🩺 القياس والمتابعة الدوائية (مخصصة جداً)
    {
      'tags': ['general'],
      'ar': 'تسجيل قراءاتك بانتظام يساعد طبيبك في تعديل العلاج بدقة فائقة 📉',
      'en':
          'Logging your readings regularly helps your doctor adjust your medication accurately 📉'
    },
    {
      'tags': ['general'],
      'ar':
          'أفضل وقت لقياس السكر هو صباحاً (صائم) وبعد بداية الوجبة بساعتين ⏱️',
      'en':
          'The best time to test sugar is fasting in the morning and 2 hours after starting a meal ⏱️'
    },
    {
      'tags': ['insulin', 'type 1', 'type 2'],
      'ar':
          'احرص على تغيير مكان حقن الإنسولين باستمرار لمنع تكون التكتلات الدهنية تحت الجلد 💉',
      'en':
          'Rotate your insulin injection sites regularly to prevent fat lumps under the skin 💉'
    },
    {
      'tags': ['general'],
      'ar':
          'تحليل السكر التراكمي (HbA1c) يجب إجراؤه كل 3 إلى 6 أشهر لمتابعة حالتك العامة 🧪',
      'en':
          'HbA1c tests should be done every 3 to 6 months to monitor your overall condition 🧪'
    },
    {
      'tags': ['general'],
      'ar':
          'إذا كنت مريضاً (زكام أو حمى)، قس سكرك أكثر، فالمرض يرفع السكر بسبب هرمونات التوتر 🤒',
      'en':
          'If you are sick (cold or fever), test more often. Illness raises sugar due to stress hormones 🤒'
    },
    {
      'tags': ['insulin'],
      'ar':
          'احفظ الإنسولين بعيداً عن أشعة الشمس المباشرة والحرارة الشديدة للحفاظ على فعاليته 🧊',
      'en':
          'Keep insulin away from direct sunlight and extreme heat to maintain its effectiveness 🧊'
    },

    {
      'tags': ['insulin', 'pills', 'type 1'],
      'ar':
          'احمل معك دائماً مصدر سكر سريع (عصير أو حلوى) لعلاج الهبوط المفاجئ 🍬',
      'en':
          'Always carry a fast-acting sugar source (juice or candy) to treat sudden lows 🍬'
    },
    {
      'tags': ['insulin', 'pills', 'type 1'],
      'ar':
          'قاعدة الـ 15 للهبوط: تناول 15 جم سكر، وانتظر 15 دقيقة، ثم قس السكر مجدداً ⏱️',
      'en':
          'The 15-15 Rule for lows: eat 15g of sugar, wait 15 mins, then test again ⏱️'
    },
    {
      'tags': ['insulin', 'pills'],
      'ar':
          'التعرق الشديد، الرعشة، وسرعة النبض هي علامات هبوط السكر.. لا تتجاهلها! ⚠️',
      'en':
          'Heavy sweating, shaking, and fast heartbeat are signs of low sugar. Don\'t ignore them! ⚠️'
    },
    {
      'tags': ['general'],
      'ar':
          'العطش الشديد وكثرة التبول علامات تحذيرية لارتفاع مستوى السكر في الدم 📈',
      'en':
          'Extreme thirst and frequent urination are warning signs of high blood sugar 📈'
    },
    {
      'tags': ['general'],
      'ar':
          'إذا كان سكرك مرتفعاً جداً، اشرب كميات كبيرة من الماء فوراً واستشر طبيبك 🚰',
      'en':
          'If your sugar is very high, drink plenty of water immediately and consult your doctor 🚰'
    },
    {
      'tags': ['insulin', 'pills'],
      'ar':
          'تأكد من قياس السكر قبل قيادة السيارة لتجنب حدوث هبوط أثناء القيادة 🚗',
      'en':
          'Always check your blood sugar before driving to avoid hypoglycemia on the road 🚗'
    },

    {
      'tags': ['general'],
      'ar':
          'افحص قدميك يومياً للبحث عن أي جروح أو احمرار، فالإحساس بالألم قد يكون ضعيفاً 👣',
      'en':
          'Inspect your feet daily for cuts or redness, as pain sensation might be reduced 👣'
    },
    {
      'tags': ['general'],
      'ar': 'جفف بين أصابع قدميك جيداً بعد الغسيل لمنع نمو الفطريات 🧼',
      'en':
          'Dry thoroughly between your toes after washing to prevent fungal infections 🧼'
    },
    {
      'tags': ['general'],
      'ar': 'رطب قدميك يومياً بالكريمات، ولكن تجنب وضع الكريم بين الأصابع 🧴',
      'en':
          'Moisturize your feet daily, but avoid putting lotion between the toes 🧴'
    },
    {
      'tags': ['general'],
      'ar':
          'لا تمشِ حافي القدمين أبداً، حتى داخل المنزل، لحماية قدميك من الجروح الخفية 🚫',
      'en':
          'Never walk barefoot, even indoors, to protect your feet from hidden injuries 🚫'
    },
    {
      'tags': ['general'],
      'ar':
          'قص أظافر قدميك بشكل مستقيم وليس دائرياً لتجنب نمو الظفر داخل اللحم ✂️',
      'en':
          'Cut your toenails straight across, not rounded, to avoid ingrown nails ✂️'
    },
    {
      'tags': ['general'],
      'ar': 'ارتدِ أحذية مريحة وواسعة، وتأكد من خلوها من الحصى قبل ارتدائها 👟',
      'en':
          'Wear comfortable, wide shoes, and check for pebbles before putting them on 👟'
    },
    {
      'tags': ['general'],
      'ar':
          'مرضى السكر أكثر عرضة لالتهابات اللثة، اغسل أسنانك مرتين يومياً واستخدم الخيط 🪥',
      'en':
          'Diabetics are more prone to gum disease. Brush twice daily and floss 🪥'
    },
    {
      'tags': ['general'],
      'ar': 'زيارة طبيب العيون مرة سنوياً ضرورية جداً لفحص شبكية العين 👁️',
      'en':
          'Visiting an eye doctor once a year is crucial for a retinal exam 👁️'
    },

    {
      'tags': ['general'],
      'ar':
          'النوم الجيد (7-8 ساعات) ليلاً يحسن بشكل كبير من قدرة جسمك على تنظيم السكر 😴',
      'en':
          'Good sleep (7-8 hours) nightly significantly improves your body\'s ability to regulate sugar 😴'
    },
    {
      'tags': ['general'],
      'ar':
          'التوتر يفرز هرمون الكورتيزول الذي يرفع السكر.. جرب التأمل أو التنفس العميق 🧘‍♀️',
      'en':
          'Stress releases cortisol which spikes sugar. Try meditation or deep breathing 🧘‍♀️'
    },
    {
      'tags': ['general'],
      'ar':
          'الإقلاع عن التدخين يحسن الدورة الدموية ويقلل من مضاعفات السكري بشكل درامي 🚭',
      'en':
          'Quitting smoking improves blood circulation and drastically reduces diabetes complications 🚭'
    },
    {
      'tags': ['general'],
      'ar':
          'لا تدع الأرقام تحبطك! القراءة المرتفعة هي مجرد معلومة لتصحيح المسار، وليست فشلاً 💪',
      'en':
          'Don\'t let numbers bring you down! A high reading is just info to course-correct, not a failure 💪'
    },
    {
      'tags': ['general'],
      'ar':
          'انضم لمجموعات دعم.. الحديث مع أشخاص يمرون بنفس تجربتك يقلل من الضغط النفسي 🤝',
      'en':
          'Join support groups. Talking to people with similar experiences reduces psychological stress 🤝'
    },
    {
      'tags': ['general'],
      'ar':
          'احتفل بانتصاراتك الصغيرة! نزول التراكمي ولو بنسبة بسيطة هو إنجاز يستحق الفخر 🎉',
      'en':
          'Celebrate small wins! Even a slight drop in HbA1c is a proud achievement 🎉'
    },
    {
      'tags': ['insulin', 'pills'],
      'ar':
          'السفر يتطلب تخطيطاً.. احمل أدويتك في حقيبة يدك وليس في حقائب الشحن ✈️',
      'en':
          'Traveling needs planning. Carry your meds in your carry-on, not checked luggage ✈️'
    },
    {
      'tags': ['insulin', 'type 1'],
      'ar':
          'احمل بطاقة تعريفية طبية تفيد بأنك مريض سكري لمساعدتك في حالات الطوارئ 🪪',
      'en':
          'Carry a medical ID card stating you have diabetes to assist you in emergencies 🪪'
    },

    {
      'tags': ['type 2', 'diet', 'pills'],
      'ar':
          'السكري من النوع الثاني يمكن إدارته وتقليل أدويته بقوة عبر فقدان الوزن والرياضة 🏃‍♀️',
      'en':
          'Type 2 diabetes can be heavily managed and meds reduced through weight loss and exercise 🏃‍♀️'
    },
    {
      'tags': ['type 1', 'insulin'],
      'ar':
          'الإنسولين ليس عقاباً أو نهاية المطاف، بل هو أداة قوية وفعالة لإنقاذ الجسم 🛡️',
      'en':
          'Insulin isn\'t a punishment or the end of the road; it\'s a powerful tool to save the body 🛡️'
    },
    {
      'tags': ['gestational'],
      'ar':
          'سكري الحمل مؤقت غالباً، التزامك بالدايت يحمي طفلك ويمنع المضاعفات 👶',
      'en':
          'Gestational diabetes is often temporary. Sticking to your diet protects your baby 👶'
    },
    {
      'tags': ['general'],
      'ar':
          'لا توجد "أعشاب سحرية" تشفي السكري نهائياً، التزم بعلاجك واستشر طبيبك قبل أي عشبة 🌿',
      'en':
          'There are no "magic herbs" that cure diabetes completely. Stick to your meds 🌿'
    },
    {
      'tags': ['general'],
      'ar':
          'المنتجات المكتوب عليها "خالية من السكر" قد تحتوي على كربوهيدرات ترفع السكر! 📊',
      'en':
          '"Sugar-free" products may still contain carbs that raise blood sugar! 📊'
    },
    {
      'tags': ['general'],
      'ar':
          'ضبط ضغط الدم والكوليسترول لا يقل أهمية عن ضبط السكر لحماية قلبك ❤️',
      'en':
          'Controlling blood pressure and cholesterol is just as important as sugar to protect your heart ❤️'
    },
    {
      'tags': ['general'],
      'ar':
          'أنت المدير التنفيذي لصحتك! الطبيب يرشدك، لكن أنت من يتخذ القرارات اليومية 👑',
      'en':
          'You are the CEO of your health! The doctor guides you, but you make the daily decisions 👑'
    },
  ];

  Map<String, dynamic>? _currentTip;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(AppImages.logoLight), context);
    precacheImage(const AssetImage(AppImages.logoDark), context);
  }

  Map<String, dynamic> _getStatusData(double level, bool isFasting) {
    if (level < 70) {
      return {
        'color': Colors.blue,
        'icon': Icons.arrow_downward,
        'label': 'low'
      };
    }
    if (isFasting) {
      if (level >= 70 && level <= 99) {
        return {
          'color': Colors.green,
          'icon': Icons.check_circle,
          'label': 'normal'
        };
      } else if (level >= 100 && level <= 125) {
        return {
          'color': Colors.amber,
          'icon': Icons.info_outline,
          'label': 'normal'
        };
      } else {
        return {
          'color': Colors.red,
          'icon': Icons.arrow_upward,
          'label': 'high'
        };
      }
    } else {
      if (level < 140) {
        return {
          'color': Colors.green,
          'icon': Icons.check_circle,
          'label': 'normal'
        };
      } else if (level >= 140 && level <= 199) {
        return {
          'color': Colors.amber,
          'icon': Icons.info_outline,
          'label': 'normal'
        };
      } else {
        return {
          'color': Colors.red,
          'icon': Icons.arrow_upward,
          'label': 'high'
        };
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.locale.languageCode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Stay CALM, Stay BALANCED ❤️',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 247, 181, 2),
              fontSize: 16,
            )),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 6, 0, 59),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Center(
            child: Opacity(
              opacity: isDark ? 0.4 : 0.6,
              child: Image.asset(
                AppImages.getLogo(context),
                width: 300,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              Map<String, dynamic> userData = {};
              String nameDisplay = "fighter_since".tr();

              if (snapshot.hasData && snapshot.data!.exists) {
                userData = snapshot.data!.data() as Map<String, dynamic>;
                String fullName = userData['name'] ?? "";
                if (fullName.trim().isNotEmpty) {
                  nameDisplay = fullName.trim().split(' ').first;
                }
              }

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 6, 0, 59),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('home_welcome'.tr(),
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 16)),
                            const SizedBox(height: 5),
                            Text('$nameDisplay ❤️',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ProfileScreen()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const Icon(Icons.person_outline_rounded,
                                color: Colors.white, size: 30),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 2.2,
                      children: [
                        _buildMenuButton(context, 'add_reading'.tr(),
                            Icons.add_circle, Colors.teal, '/add'),
                        _buildMenuButton(context, 'history'.tr(), Icons.history,
                            Colors.orange, '/history'),
                        _buildMenuButton(context, 'graph'.tr(), Icons.bar_chart,
                            Colors.blue, '/graph'),
                        _buildMenuButton(
                            context,
                            'report'.tr(),
                            Icons.analytics_outlined,
                            Colors.purple,
                            '/reports'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildDailyTipCard(isDark, lang, userData),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Align(
                      alignment: lang == 'ar'
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Text('last_reading'.tr(),
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white70
                                  : const Color.fromARGB(255, 6, 0, 59))),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: StreamBuilder<List<ReadingModel>>(
                      stream: _firebaseService.getReadings(),
                      builder: (context, readingSnapshot) {
                        if (readingSnapshot.hasError) {
                          return const Center(child: Text('Error'));
                        }
                        if (!readingSnapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final readings = readingSnapshot.data!.take(2).toList();
                        if (readings.isEmpty) {
                          return Center(child: Text('random'.tr()));
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          itemCount: readings.length,
                          itemBuilder: (context, index) {
                            final reading = readings[index];
                            final status = _getStatusData(
                                reading.glucoseLevel, reading.isFasting);

                            return Card(
                              color: isDark
                                  ? const Color(0xFF1A1D29)
                                  : Colors.white,
                              elevation: isDark ? 0 : 3,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(
                                  color: isDark
                                      ? Colors.white10
                                      : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: (status['color'] as Color)
                                      .withOpacity(isDark ? 0.15 : 0.1),
                                  child: Icon(status['icon'],
                                      color: status['color']),
                                ),
                                title: Text(
                                  '${reading.glucoseLevel.toInt()} mg/dL',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: status['color']),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      status['label'].toString().tr(),
                                      style: TextStyle(
                                          color: status['color'],
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      reading.note.isEmpty
                                          ? 'without_notes'.tr()
                                          : reading.note,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: isDark
                                              ? Colors.white60
                                              : Colors.black54),
                                    ),
                                  ],
                                ),
                                trailing: Text(
                                  DateFormat('jm', lang)
                                      .format(reading.timestamp),
                                  style: TextStyle(
                                      color:
                                          isDark ? Colors.white38 : Colors.grey,
                                      fontSize: 12),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTipCard(
      bool isDark, String lang, Map<String, dynamic> userData) {
    String? dbType = userData['diabetesType']?.toString().toLowerCase();
    String? treatment = userData['treatmentType']?.toString().toLowerCase();

    List<Map<String, dynamic>> suitableTips = _tipsList.where((tip) {
      List<String> tags = List<String>.from(tip['tags']);
      if (tags.contains('general')) return true;
      if (dbType != null && tags.contains(dbType)) return true;
      if (treatment != null && tags.contains(treatment)) return true;
      return false;
    }).toList();

    if (suitableTips.isEmpty) suitableTips = _tipsList;

    _currentTip ??= suitableTips[Random().nextInt(suitableTips.length)];
    if (!suitableTips.contains(_currentTip)) {
      _currentTip = suitableTips[Random().nextInt(suitableTips.length)];
    }

    final tipText = _currentTip![lang] ?? _currentTip!['en'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentTip = suitableTips[Random().nextInt(suitableTips.length)];
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1E2A38), const Color(0xFF121A24)]
                : [Colors.teal.shade50, Colors.teal.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.teal.withOpacity(0.3) : Colors.teal.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(isDark ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lightbulb_rounded,
                  color: Colors.teal, size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang == 'ar' ? 'نصيحة اليوم 💡' : 'Daily Tip 💡',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark
                          ? Colors.tealAccent.shade100
                          : Colors.teal.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      tipText,
                      key: ValueKey<String>(tipText),
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon,
      Color color, String route) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 5),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
