import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'package:provider/provider.dart';
import 'services/theme_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'screens/home_screen.dart';
import 'screens/add_reading.dart';
import 'screens/history_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/graph_screen.dart';
import 'screens/reports_screen.dart';

class AppImages {
  static const String logoLight = 'assets/images/logo_light.png';
  static const String logoDark = 'assets/images/logo_dark.png';

  static String getLogo(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? logoDark : logoLight;
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final notificationService = NotificationService();
    await notificationService.initNotification();

    final prefs = await SharedPreferences.getInstance();

    String? languageCode = prefs.getString('language_code') ?? 'ar';

    int? lastReadingMillis = prefs.getInt('last_reading');

    if (lastReadingMillis != null) {
      DateTime lastReading =
          DateTime.fromMillisecondsSinceEpoch(lastReadingMillis);

      if (DateTime.now().difference(lastReading).inHours >= 24) {
        String title = (languageCode == 'en')
            ? "We missed you, hero! ❤️"
            : "وحشتنا يا بطل .. طمنا عليك ❤️";

        String body = (languageCode == 'en')
            ? "It's been 24 hours since your last reading. Take a quick check to stay safe!"
            : "بقالك يوم كامل مسجلتش قياسك .. شكة إبرة مش هتاخد ثانية بس هتطمنا.";

        await notificationService.showNotification(
          title: title,
          body: body,
        );
      }
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService().initNotification();
  await Permission.notification.request();

  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  await Workmanager().registerPeriodicTask(
    "unique_id_1",
    "checkLastReadingTask",
    frequency: const Duration(hours: 6),
    existingWorkPolicy: ExistingWorkPolicy.keep,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: EasyLocalization(
        supportedLocales: const [Locale('ar'), Locale('en')],
        path: 'assets/lang',
        fallbackLocale: const Locale('ar'),
        child: const GlucoTrackApp(),
      ),
    ),
  );
}

class GlucoTrackApp extends StatelessWidget {
  const GlucoTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GlucoTrack',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        fontFamily: 'Cairo',
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 6, 0, 59),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        fontFamily: 'Cairo',
        scaffoldBackgroundColor: const Color(0xFF0F111A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF1E1E1E),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1F1F1F),
          selectedItemColor: Colors.blueAccent,
        ),
      ),
      themeMode: themeProvider.themeMode,

      // نظام المسارات
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/add': (context) => const AddReadingScreen(),
        '/history': (context) => const HistoryScreen(),
        '/graph': (context) => const GraphScreen(),
        '/reports': (context) => const ReportsScreen(),
      },
    );
  }
}
