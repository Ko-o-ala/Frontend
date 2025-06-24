import 'dart:async';
import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:uni_links/uni_links.dart';

import 'package:url_launcher/url_launcher.dart';

final storage = FlutterSecureStorage();

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late final TapGestureRecognizer _tapRecognizer;
  StreamSubscription? _sub;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tapRecognizer = TapGestureRecognizer()..onTap = _handleSignUp;
    _sub = uriLinkStream.listen(
      _handleIncomingUri,
      onError: (err) {
        print('URI 리스너 에러: $err');
      },
    );
  }

  @override
  void dispose() {
    idController.dispose();
    passwordController.dispose();
    _tapRecognizer.dispose();


    _sub?.cancel();

    super.dispose();
  }

  void _handleSignUp() {
    Navigator.pushNamed(context, '/sign-in');
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.post(
        Uri.parse('http://localhost:8000/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userID': idController.text.trim(),
          'password': passwordController.text.trim(),
        }),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = json.decode(res.body)['data'];
        await storage.write(key: 'jwt', value: data['token']);
        await storage.write(key: 'username', value: data['name']);
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/sleep');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 실패. 아이디 또는 비밀번호 확인하세요.')),
        );
      }
    } catch (e) {
      print('로그인 에러: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


    final response = await http.post(
      Uri.parse('https://kooala.tassoo.uk/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userID': idController.text.trim(),
        'password': passwordController.text.trim(),
      }),



  Future<void> _handleIncomingUri(Uri? uri) async {
    if (uri == null) return;
    if (uri.scheme == 'myapp' && uri.host == 'oauth') {
      final code = uri.queryParameters['code'] ?? '';
      print('🟡 받은 code: $code');
      final tokenRes = await http.post(
        Uri.parse('https://kauth.kakao.com/oauth/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'authorization_code',
          'client_id': '210093e20b9250b8187c91a8863de561',
          'redirect_uri': 'myapp://oauth',
          'code': code,
        },
      );
      if (tokenRes.statusCode == 200) {
        final at = json.decode(tokenRes.body)['access_token'];
        final userInfoRes = await http.get(
          Uri.parse('https://kapi.kakao.com/v2/user/me'),
          headers: {'Authorization': 'Bearer $at'},
        );
        if (userInfoRes.statusCode == 200) {
          print('🟢 사용자 정보: ${userInfoRes.body}');
          if (mounted) Navigator.pushReplacementNamed(context, '/sleep');
        } else {
          print('사용자정보 요청 실패: ${userInfoRes.body}');
        }
      } else {
        print('토큰 요청 실패: ${tokenRes.body}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pushReplacementNamed(context, '/'),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  '로그인',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loginWithKakao,
                icon: const Icon(Icons.login, color: Colors.white),
                label: const Text('카카오 계정으로 계속하기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8183D9),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  /* Google 로그인 로직 */
                },
                icon: Image.asset('assets/google_icon.png', height: 20),
                label: const Text('Google로 계속하기'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  side: BorderSide(color: Colors.grey.shade400),
                  foregroundColor: Colors.black,
                ),
              ),
              const SizedBox(height: 32),
              const Center(
                child: Text('이메일로 로그인하기', style: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8183D9),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          '로그인',
                          style: TextStyle(color: Colors.white),
                        ),
              ),
              const SizedBox(height: 16),
              const Center(child: Text('비밀번호를 잊으셨나요?')),
              const SizedBox(height: 20),
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
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final storage = FlutterSecureStorage();

  HomeScreen({super.key});

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

  SleepScreen({super.key});

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
        final name = snapshot.data!;
        return Scaffold(
          appBar: AppBar(title: const Text('수면 화면')),
          body: Center(child: Text('$name 아 안녕!')),
        );
      },
    );
  }
}
