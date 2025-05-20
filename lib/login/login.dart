import 'package:flutter/material.dart';

void main() {
  runApp(LoginApp());
}

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: LoginScreen(), debugShowCheckedModeBanner: false);
  }
}

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(icon: Icon(Icons.arrow_back), onPressed: () {}),
              SizedBox(height: 20),
              Text(
                '돌아오신 걸 환영합니다!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              // 카카오 버튼
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.facebook, color: Colors.white),
                label: Text('카카오톡으로 계속하기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8183D9),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              SizedBox(height: 12),
              // 구글 버튼
              OutlinedButton.icon(
                onPressed: () {},
                icon: Image.asset(
                  'assets/google_icon.png',
                  height: 20,
                ), // 구글 아이콘 필요 시
                label: Text('GOOGLE로 계속하기'),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Center(
                child: Text('이메일로 로그인하기', style: TextStyle(color: Colors.grey)),
              ),
              SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: '이메일',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '비밀번호',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // 로그인 처리
                },
                child: Text('로그인'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFB0AEF4),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Center(child: Text('비밀번호를 잊으셨나요?')),
              Spacer(),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: '계정이 없으신가요? ',
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: '회원가입하기',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
