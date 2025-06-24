import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:my_app/TopNav.dart';
import 'package:my_app/bottomNavigationBar.dart';

class SoundScreen extends StatefulWidget {
  const SoundScreen({Key? key}) : super(key: key);

  @override
  State<SoundScreen> createState() => _SoundScreenState();
}

class _SoundScreenState extends State<SoundScreen> {
  final player = AudioPlayer();
  String? currentPlaying;
  bool isPlaying = false;

  final List<String> soundFiles = [
    "ALPHA_1.mp3",
    "ALPHA_2.mp3",
    "ASMR_1_BOOK.mp3",
    "ASMR_2_HAIR.mp3",
    "ASMR_3_TAPPING.mp3",
    "FIRE_1.mp3",
    "FIRE_2.mp3",
    "LOFI_1.mp3",
    "LOFI_2.mp3",
    "MEDIT_1_TEMPLE.mp3",
    "MEDIT_2_MUSIC.mp3",
    "NATURE_1_WATER.mp3",
    "NATURE_2_MORNINGBIRDS.mp3",
    "NATURE_3_CRICKETS.mp3",
    "NATURE_4_CAVE_DROPLETS.mp3",
    "PINK_1_WIND.mp3",
    "PINK_2_RAIN.mp3",
    "PINK_3_RAIN_THUNDER.mp3",
    "PINK_4_WAVE.mp3",
    "WHITE_1.mp3",
    "WHITE_2_UNDERWATER.mp3",
  ];

  final PageController controller = PageController();
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    player.playerStateStream.listen((state) {
      setState(() {
        isPlaying = state.playing;
        if (state.processingState == ProcessingState.completed) {
          currentPlaying = null;
        }
      });
    });
  }

  @override
  void dispose() {
    player.dispose();
    controller.dispose();
    super.dispose();
  }

  Future<void> _playSound(String fileName) async {
    if (currentPlaying == fileName && isPlaying) {
      await player.pause();
    } else {
      try {
        await player.setAsset('assets/sounds/$fileName');
        player.play();
        setState(() {
          currentPlaying = fileName;
        });
      } catch (e) {
        debugPrint("⚠️ 재생 오류: $e");
      }
    }
  }

  void _stop() async {
    await player.stop();
    setState(() {
      currentPlaying = null;
    });
  }

  void _onReorder(int oldIdx, int newIdx) {
    setState(() {
      final item = soundFiles.removeAt(oldIdx);
      soundFiles.insert(newIdx, item);
    });
  }

  List<String> _getPageItems(int page, int perPage) {
    final start = page * perPage;
    return soundFiles.skip(start).take(perPage).toList();
  }

  @override
  Widget build(BuildContext context) {
    const perPage = 6;
    final pageCount = (soundFiles.length / perPage).ceil();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8FF),
      appBar: TopNav(isLoggedIn: true, onLogin: () {}, onLogout: () {}),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: controller,
              onPageChanged: (idx) => setState(() => currentPage = idx),
              itemCount: pageCount,
              itemBuilder: (_, pageIndex) {
                final items = _getPageItems(pageIndex, perPage);
                return ReorderableListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  onReorder: (oldI, newI) {
                    final old = pageIndex * perPage + oldI;
                    final neo =
                        pageIndex * perPage + (newI > oldI ? newI - 1 : newI);
                    _onReorder(old, neo);
                  },
                  children: List.generate(items.length, (i) {
                    final file = items[i];
                    final name = file
                        .replaceAll('.mp3', '')
                        .replaceAll('_', ' ');
                    final selected = currentPlaying == file;
                    return Card(
                      key: ValueKey(file),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: selected ? const Color(0xFFEDEBFF) : Colors.white,
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF8183D9),
                          child: Icon(Icons.music_note, color: Colors.white),
                        ),
                        title: Text(
                          name,
                          style: TextStyle(
                            fontWeight:
                                selected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        trailing: Icon(
                          selected && isPlaying
                              ? Icons.pause_circle
                              : Icons.play_circle,
                          size: 32,
                          color:
                              selected ? const Color(0xFF8183D9) : Colors.grey,
                        ),
                        onTap: () => _playSound(file),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: List.generate(pageCount, (i) {
                return OutlinedButton(
                  onPressed: () => controller.jumpToPage(i),
                  style: OutlinedButton.styleFrom(
                    backgroundColor:
                        currentPage == i
                            ? const Color(0xFF8183D9)
                            : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      color: currentPage == i ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }),
            ),
          ),
          if (currentPlaying != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: Row(
                children: [
                  const Icon(Icons.music_note, color: Color(0xFF8183D9)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      currentPlaying!
                          .replaceAll('.mp3', '')
                          .replaceAll('_', ' '),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    color: const Color(0xFF8183D9),
                    onPressed: () {
                      if (isPlaying)
                        player.pause();
                      else
                        player.play();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.stop),
                    color: Colors.redAccent,
                    onPressed: _stop,
                  ),
                ],
              ),
            ),
          CustomBottomNavBar(
            currentIndex: 2,
            onTap: (idx) {
              if (idx == 1)
                Navigator.pushReplacementNamed(context, '/dashboard');
              else if (idx == 3)
                Navigator.pushReplacementNamed(context, '/setting');
            },
          ),
        ],
      ),
    );
  }
}
