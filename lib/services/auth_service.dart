import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<User?> user = Rx<User?>(null);
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 인증 상태 변화 감지
    user.bindStream(_auth.authStateChanges());
  }

  // 이메일 회원가입
  Future<bool> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    try {
      isLoading.value = true;

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // 사용자 정보를 Firestore에 저장
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'cookingLevel': '',
          'preferredIngredients': [],
          'voiceGuideEnabled': true,
        });

        // 사용자 이름 업데이트
        await credential.user!.updateDisplayName(name);

        // 회원가입 후 로그아웃하여 로그인 화면으로 이동하도록 함
        await _auth.signOut();

        Get.snackbar(
          '회원가입 완료',
          '계정이 성공적으로 생성되었습니다. 로그인해주세요.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      String message = _getErrorMessage(e.code);
      Get.snackbar('회원가입 실패', message);
      return false;
    } catch (e) {
      Get.snackbar('오류', '회원가입 중 오류가 발생했습니다.');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 이메일 로그인
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      isLoading.value = true;

      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        Get.snackbar('성공', '로그인되었습니다!');
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      String message = _getErrorMessage(e.code);
      Get.snackbar('로그인 실패', message);
      return false;
    } catch (e) {
      Get.snackbar('오류', '로그인 중 오류가 발생했습니다.');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      Get.snackbar('로그아웃', '로그아웃되었습니다.');
    } catch (e) {
      Get.snackbar('오류', '로그아웃 중 오류가 발생했습니다.');
    }
  }

  // 현재 사용자 정보 가져오기
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    if (user.value != null) {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.value!.uid).get();
      return doc.data() as Map<String, dynamic>?;
    }
    return null;
  }

  // 사용자 프로필 업데이트
  Future<bool> updateUserProfile(Map<String, dynamic> data) async {
    try {
      if (user.value != null) {
        await _firestore.collection('users').doc(user.value!.uid).update(data);
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('오류', '프로필 업데이트 중 오류가 발생했습니다.');
      return false;
    }
  }

  // Firebase Auth 에러 메시지 변환
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'weak-password':
        return '비밀번호가 너무 약합니다.';
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'invalid-email':
        return '유효하지 않은 이메일 주소입니다.';
      case 'user-not-found':
        return '등록되지 않은 사용자입니다.';
      case 'wrong-password':
        return '잘못된 비밀번호입니다.';
      case 'user-disabled':
        return '비활성화된 계정입니다.';
      case 'too-many-requests':
        return '너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요.';
      default:
        return '인증 오류가 발생했습니다.';
    }
  }
}
