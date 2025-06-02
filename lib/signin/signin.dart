import 'package:flutter/material.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool agreedToPrivacy = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool get isFormValid {
    return nameController.text.isNotEmpty &&
        emailController.text.contains('@') &&
        passwordController.text.length >= 6 &&
        agreedToPrivacy;
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
              IconButton(icon: Icon(Icons.arrow_back), onPressed: () {}),
              SizedBox(height: 10),
              Center(
                child: Text(
                  '계정을 생성하세요',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 30),

              // 카카오 (Facebook 아이콘)
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.facebook, color: Colors.white),
                label: Text('카카오톡으로 계속하기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8183D9),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              SizedBox(height: 12),

              // Google 버튼
              OutlinedButton.icon(
                onPressed: () {},
                icon: Image.asset('assets/google_icon.png', height: 20),
                label: Text('GOOGLE로 계속하기'),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              SizedBox(height: 24),

              Center(
                child: Text('이메일로 로그인하기', style: TextStyle(color: Colors.grey)),
              ),
              SizedBox(height: 16),

              // 이름 필드
              _buildInputField(
                controller: nameController,
                hint: '이름',
                isValid: nameController.text.isNotEmpty,
              ),
              SizedBox(height: 12),

              // 이메일 필드
              _buildInputField(
                controller: emailController,
                hint: '이메일',
                isValid: emailController.text.contains('@'),
              ),
              SizedBox(height: 12),

              // 비밀번호 필드
              TextField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
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

              // 개인정보 동의
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

              // 시작하기 버튼
              ElevatedButton(
                onPressed:
                    isFormValid
                        ? () {
                          Navigator.pushReplacementNamed(context, '/welcome');
                        }
                        : null,
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
                child: Text('시작하기'),
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
