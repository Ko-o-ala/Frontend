import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/TopNav.dart'; // ← TopNav 추가
import 'package:my_app/bottomNavigationBar.dart'; // ← CustomBottomNavBar 추가

class RealHomeScreen extends StatefulWidget {
  const RealHomeScreen({super.key});

  @override
  State<RealHomeScreen> createState() => _RealHomeScreenState();
}

class _RealHomeScreenState extends State<RealHomeScreen>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '🎤 여기에 인식된 텍스트가 표시됩니다';
  String _username = '';
  bool _isLoggedIn = false; // ← 로그인 상태
  int _currentIndex = 0;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _loadUsername();

    _speech = stt.SpeechToText();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).chain(CurveTween(curve: Curves.easeInOut)).animate(_animationController);

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed && _isListening) {
        _animationController.forward();
      }
    });
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    setState(() {
      _username = username;
      _isLoggedIn = username.isNotEmpty;
    });
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    setState(() {
      _username = '';
      _isLoggedIn = false;
    });
  }

  @override
  void dispose() {
    _speech.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('▶ 상태: $status'),
        onError: (err) => print('× 에러: $err'),
      );
      if (available) {
        setState(() {
          _isListening = true;
          _text = '🎙️ 듣고 있어요...';
        });
        _animationController.forward();
        _speech.listen(
          localeId: 'ko_KR',
          onResult: (val) {
            setState(() {
              _text = val.recognizedWords;
            });
          },
        );
      } else {
        setState(() => _text = '❌ 음성 인식 사용 불가');
      }
    } else {
      _speech.stop();
      _stopListening();
    }
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
    });
    _animationController.stop();
    _animationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNav(
        isLoggedIn: _isLoggedIn,
        onLogin: () {
          Navigator.pushNamed(context, '/login');
        },
        onLogout: _handleLogout,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            if (_username.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  '${_username}님, 안녕하세요!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'lib/assets/koala.png',
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '당신의 이야기를 들려주세요!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _text,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('크리스마스까지 며칠 남았어?'),
                  ),
                  GestureDetector(
                    onTap: _listen,
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        double scale = _isListening ? _animation.value : 1.0;
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color:
                                  _isListening ? Colors.red : Color(0xFF8183D9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.mic,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // 탭에 따른 추가 로직이 필요하면 여기에 구현
        },
      ),
    );
  }
}
