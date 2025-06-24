import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/gestures.dart';

final storage = FlutterSecureStorage();

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});


  @override
  State<LoginScreen> createState() => _LoginScreenState();
}


class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController idController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  late TapGestureRecognizer _tapRecognizer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tapRecognizer = TapGestureRecognizer()..onTap = _handleSignUp;
  }

  @override
  void dispose() {
    idController.dispose();
    passwordController.dispose();
    _tapRecognizer.dispose(); // 메모리 누수 방지
    super.dispose();
  }

  void _handleSignUp() {
    Navigator.pushNamed(context, '/sign-in');
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);

    final response = await http.post(
      Uri.parse('http://localhost:8000/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userID': idController.text.trim(),
        'password': passwordController.text.trim(),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = json.decode(response.body);
      final token = decoded['data']['token'];
      final username = decoded['data']['name'];

      await storage.write(key: 'jwt', value: token);
      await storage.write(key: 'username', value: username);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/sleep');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('로그인 실패. 아이디 또는 비밀번호를 확인하세요.')));
    }

    setState(() => _isLoading = false);
  }

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

                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/');
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Center(

                    child: Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 24,
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

                    ),
                  ),
                  const SizedBox(height: 40),

                  TextField(
                    controller: idController,
                    decoration: InputDecoration(
                      hintText: '아이디',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
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
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8183D9),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),

                    child: Text('로그인', style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(height: 10),
                  Center(child: Text('비밀번호를 잊으셨나요?')),
                  SizedBox(height: 40),

                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              '로그인',
                              style: TextStyle(color: Colors.white),
                            ),
                  ),
                  const SizedBox(height: 30),

                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: '계정이 없으신가요? ',
                        style: const TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: '회원가입하기',
                            style: const TextStyle(
                              color: Color(0xFF8183D9),
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: _tapRecognizer,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final storage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('홈 화면'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await storage.delete(key: 'jwt');
              await storage.delete(key: 'username');
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: const Center(child: Text('로그인 완료!')),
    );
  }
}

class SleepScreen extends StatelessWidget {
  final storage = FlutterSecureStorage();

  Future<String> _loadUsername() async {
    return await storage.read(key: 'username') ?? '사용자';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _loadUsername(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('수면 화면')),
          body: Center(child: Text('${snapshot.data}아 안녕!')),
        );
      },
    );
  }
}
