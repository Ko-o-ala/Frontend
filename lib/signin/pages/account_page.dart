// lib/onboarding/pages/account_page.dart
import 'package:flutter/material.dart';
import '../onboarding_data.dart';

class AccountPage extends StatefulWidget {
  final VoidCallback onNext;
  const AccountPage({Key? key, required this.onNext}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _idCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool isPwVisible = false;

  bool get isValid =>
      _idCtrl.text.trim().isNotEmpty && _pwCtrl.text.length >= 6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Image.asset('lib/assets/koala.png', width: 120),
              const SizedBox(height: 16),
              TextField(
                controller: _idCtrl,
                decoration: InputDecoration(
                  hintText: '아이디 입력',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextField(
                obscureText: !isPwVisible,
                controller: _pwCtrl,
                decoration: InputDecoration(
                  hintText: '비밀번호 (6자 이상)',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPwVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => isPwVisible = !isPwVisible),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    isValid
                        ? () {
                          OnboardingData.answers['userID'] =
                              _idCtrl.text.trim();
                          OnboardingData.answers['password'] = _pwCtrl.text;
                          widget.onNext();
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8183D9),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  '시작하기',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
