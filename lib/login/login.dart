import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: LoginScreen(), debugShowCheckedModeBanner: false);
  }
}

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // ✅ REST 방식 Kakao 로그인 함수
  void _loginWithKakao() async {
    final kakaoAuthUrl = Uri.parse(
      'https://kauth.kakao.com/oauth/authorize'
      '?client_id=210093e20b9250b8187c91a8863de561'
      '&redirect_uri=myapp://oauth'
      '&response_type=code',
    );

    if (await canLaunchUrl(kakaoAuthUrl)) {
      await launchUrl(kakaoAuthUrl, mode: LaunchMode.externalApplication);
    } else {
      print('카카오 로그인 URL 실행 실패');
    }

    uriLinkStream.listen((uri) async {
      if (uri != null && uri.scheme == 'myapp' && uri.host == 'oauth') {
        final code = uri.queryParameters['code'];
        print('🟡 받은 code: $code');

        // 🔐 access token 요청
        final tokenRes = await http.post(
          Uri.parse('https://kauth.kakao.com/oauth/token'),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'grant_type': 'authorization_code',
            'client_id': '210093e20b9250b8187c91a8863de561',
            'redirect_uri': 'myapp://oauth',
            'code': code ?? '',
          },
        );

        if (tokenRes.statusCode == 200) {
          final tokenData = json.decode(tokenRes.body);
          final accessToken = tokenData['access_token'];
          print('🟢 accessToken: $accessToken');

          // 👤 사용자 정보 요청
          final userInfoRes = await http.get(
            Uri.parse('https://kapi.kakao.com/v2/user/me'),
            headers: {'Authorization': 'Bearer $accessToken'},
          );

          if (userInfoRes.statusCode == 200) {
            final user = json.decode(userInfoRes.body);
            print('🟢 사용자 정보: $user');

            // 로그인 성공 후 이동
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/');
            }
          } else {
            print('🟥 사용자 정보 요청 실패: ${userInfoRes.body}');
          }
        } else {
          print('🟥 토큰 요청 실패: ${tokenRes.body}');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(icon: Icon(Icons.arrow_back), onPressed: () {}),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      '돌아오신 걸 환영합니다!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: _loginWithKakao,
                    icon: Icon(Icons.login, color: Colors.white),
                    label: Text(
                      '카카오 계정으로 계속하기',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8183D9),
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: 350,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: Image.asset('assets/google_icon.png', height: 20),
                      label: Text('Google로 계속하기'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(0, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        side: BorderSide(color: Colors.grey.shade400),
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Center(
                    child: Text(
                      '이메일로 로그인하기',
                      style: TextStyle(color: Colors.grey),
                    ),
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
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8183D9),
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text('로그인', style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(height: 10),
                  Center(child: Text('비밀번호를 잊으셨나요?')),
                  SizedBox(height: 40),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: '계정이 없으신가요? ',
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: '회원가입하기',
                            style: TextStyle(
                              color: Color(0xFF8183D9),
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
        ),
      ),
    );
  }
}
