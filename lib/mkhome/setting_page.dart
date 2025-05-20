import 'package:flutter/material.dart';
import 'package:my_app/user_model.dart';

// 1. 서버 대신 임시 사용자 정보 제공 함수
Future<UserModel> fetchUserInfo() async {
  await Future.delayed(const Duration(seconds: 1));
  return UserModel(
    name: '이유나',
    email: 'yuna@example.com',
    profileImage: 'lib/assets/profile.jpg', // pubspec.yaml에 등록 필요
  );
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: FutureBuilder<UserModel>(
        future: fetchUserInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('사용자 정보를 불러오지 못했습니다.'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('사용자 정보가 없습니다.'));
          }

          final user = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundImage: AssetImage(user.profileImage),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(user.email,
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 24),
              _buildSettingsItem(context, '내 계정 정보'),
              _buildSettingsItem(context, '알림 설정'),
              _buildSettingsItem(context, '수면 데이터 관리'),
              const SizedBox(height: 24),
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('고객 지원',
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
              _buildSettingsItem(context, '자주 묻는 질문'),
              _buildSettingsItem(context, '이용 약관/개인정보 처리방침'),
              _buildSettingsItem(context, '버그 신고/기능 요청'),
              const SizedBox(height: 16),
              TextButton(
                  onPressed: () {},
                  child:
                  const Text('로그아웃', style: TextStyle(color: Colors.teal))),
              TextButton(
                  onPressed: () {},
                  child: const Text('계정 탈퇴하기',
                      style: TextStyle(color: Colors.black54))),
            ],
          );
        },
      ),

      // 네비게이션 바는 필요 시 아래에 추가 가능
    );
  }

  Widget _buildSettingsItem(BuildContext context, String title) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }
}
