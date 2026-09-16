import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/music_provider.dart';
import '../widgets/speed_dial_grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final music = context.watch<MusicProvider>();

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.center,
          colors: [Color(0xFF5B4B12), Color(0xFF151515), Color(0xFF090909)],
          stops: [0, 0.35, 0.8],
        ),
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: music.refreshLibrary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Top app header
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF0033),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 8),

                      const Text(
                        'Music',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),

                      const Spacer(),

                      // Account icon
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFFEEEEEE),
                        child: Icon(
                          Icons.person_rounded,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Offline local music information
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF154B82), Color(0xFF0F345E)],
                      ),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your music. Offline.',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),

                              SizedBox(height: 5),

                              Text(
                                'Everything here comes from audio stored on this device.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),

                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white12,
                          child: Icon(Icons.music_note_rounded, size: 30),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Speed Dial header
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0xFFE7E7E7),
                        child: Icon(
                          Icons.graphic_eq_rounded,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(width: 14),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LOCAL LIBRARY',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            SizedBox(height: 2),

                            Text(
                              'Speed dial',
                              style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (!music.isLoading)
                        IconButton(
                          tooltip: 'Refresh local music',
                          onPressed: music.refreshLibrary,
                          icon: const Icon(Icons.refresh_rounded),
                        ),
                    ],
                  ),
                ),
              ),

              // Loading state
              if (music.isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              // Permission state
              else if (music.permissionDenied)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _MessageState(
                    icon: Icons.folder_off_outlined,
                    title: 'Music permission required',
                    message:
                        'Allow audio access so the app can scan songs stored on your device.',
                    actionLabel: 'Try again',
                    onAction: music.refreshLibrary,
                  ),
                )
              // Error state
              else if (music.errorMessage != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _MessageState(
                    icon: Icons.error_outline_rounded,
                    title: 'Could not load music',
                    message: music.errorMessage!,
                    actionLabel: 'Retry',
                    onAction: music.refreshLibrary,
                  ),
                )
              // Local songs
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverToBoxAdapter(
                    child: SpeedDialGrid(songs: music.speedDialSongs),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.white54),

          const SizedBox(height: 18),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 8),

          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white60, height: 1.4),
          ),

          const SizedBox(height: 18),

          FilledButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
