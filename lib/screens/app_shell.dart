import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'library_screen.dart';
import 'placeholder_screen.dart';
import 'search_screen.dart';
import '../widgets/mini_player.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _pages = <Widget>[
    HomeScreen(),
    PlaceholderScreen(
      icon: Icons.play_circle_outline_rounded,
      title: 'Samples',
      message: 'Samples are not available in local-only mode.',
    ),
    SearchScreen(),
    LibraryScreen(),
    PlaceholderScreen(
      icon: Icons.workspace_premium_outlined,
      title: 'Upgrade',
      message: 'This local player has no subscriptions or online account.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    print("hellooooo");
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.play_arrow_outlined),
                selectedIcon: Icon(Icons.play_arrow_rounded),
                label: 'Samples',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_rounded),
                label: 'Search',
              ),
              NavigationDestination(
                icon: Icon(Icons.bookmark_border_rounded),
                selectedIcon: Icon(Icons.bookmark_rounded),
                label: 'Library',
              ),
              NavigationDestination(
                icon: Icon(Icons.play_circle_outline_rounded),
                selectedIcon: Icon(Icons.play_circle_rounded),
                label: 'Upgrade',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
