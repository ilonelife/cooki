import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';
import '../home/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Get.find<AuthService>();

    return Obx(() {
      // 로딩 중일 때
      if (authService.isLoading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      // 사용자가 로그인되어 있으면 홈 화면, 아니면 로그인 화면
      if (authService.user.value != null) {
        return const HomeScreen();
      } else {
        return const LoginScreen();
      }
    });
  }
}
