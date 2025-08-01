import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/auth/auth_wrapper.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 인증 서비스 초기화
  Get.put(AuthService());

  runApp(const CookiApp());
}

class CookiApp extends StatelessWidget {
  const CookiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '요리하자!',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'NotoSans',
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR')],
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
