import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool agreedToPrivacy = false;
  bool isLoading = false;

  final storage = FlutterSecureStorage();

  @override
  void dispose() {
    nameController.dispose();
    idController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool get isFormValid {
    return nameController.text.isNotEmpty &&
        idController.text.isNotEmpty &&
        passwordController.text.length >= 6 &&
        agreedToPrivacy;
  }

  Future<void> _handleSignUp() async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/users/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userID': idController.text.trim(),
          'name': nameController.text.trim(),
          'password': passwordController.text,
          'age': 25,
          'gender': 'female',
        }),
      );

      if (response.statusCode == 201) {
        // 회원가입 성공 → 로그인 페이지로 이동
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        throw Exception('회원가입 실패: ${response.body}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  '계정을 생성하세요',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 30),

              _buildInputField(
                controller: nameController,
                hint: '이름',
                isValid: nameController.text.isNotEmpty,
              ),
              SizedBox(height: 12),

              _buildInputField(
                controller: idController,
                hint: '아이디',
                isValid: idController.text.isNotEmpty,
              ),
              SizedBox(height: 12),

              TextField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: '비밀번호',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),

              Row(
                children: [
                  Checkbox(
                    value: agreedToPrivacy,
                    onChanged: (value) {
                      setState(() {
                        agreedToPrivacy = value!;
                      });
                    },
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '개인정보 처리방침을 읽고 동의합니다',
                            style: TextStyle(color: Colors.green.shade700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: isFormValid && !isLoading ? _handleSignUp : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isFormValid
                          ? Color(0xFF9187F4)
                          : Color(0xFF9187F4).withOpacity(0.3),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child:
                    isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('시작하기'),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required bool isValid,
  }) {
    return TextField(
      controller: controller,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        suffixIcon:
            isValid
                ? Icon(Icons.check, color: Colors.green)
                : SizedBox(width: 0),
      ),
    );
  }
}
