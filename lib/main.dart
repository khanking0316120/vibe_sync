import 'dart:async';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/music_provider.dart';
import 'screens/splash_screen.dart';
import 'services/app_audio_handler.dart';
import 'services/music_library_service.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);

    debugPrint('========== FLUTTER ERROR ==========');
    debugPrint(details.exceptionAsString());
    debugPrintStack(stackTrace: details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('========== PLATFORM ERROR ==========');
    debugPrint(error.toString());
    debugPrintStack(stackTrace: stack);

    return true;
  };

  try {
    debugPrint('========== APP STARTING ==========');

    final AppAudioHandler audioHandler =
        await AudioService.init<AppAudioHandler>(
          builder: () => AppAudioHandler(),
          config: const AudioServiceConfig(
            androidNotificationChannelId: 'com.example.vibe_sync.audio',
            androidNotificationChannelName: 'Music playback',
            androidNotificationChannelDescription:
                'Local music playback controls',
            androidNotificationOngoing: false,
            androidStopForegroundOnPause: false,
          ),
        ).timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException('AudioService initialization timed out.');
          },
        );

    debugPrint('========== AUDIO SERVICE READY ==========');

    await audioHandler.configureAudioSession();

    debugPrint('========== AUDIO SESSION READY ==========');

    runApp(
      ChangeNotifierProvider(
        lazy: false,
        create: (_) {
          final provider = MusicProvider(
            audioHandler: audioHandler,
            libraryService: MusicLibraryService(),
          );

          provider.initialize();

          return provider;
        },
        child: const VibeSyncApp(),
      ),
    );
  } catch (error, stackTrace) {
    debugPrint('========== APP STARTUP FAILED ==========');
    debugPrint('Error: $error');
    debugPrintStack(stackTrace: stackTrace);

    runApp(StartupErrorApp(error: error.toString()));
  }
}

class VibeSyncApp extends StatelessWidget {
  const VibeSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VibeSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,

      // App starts from the animated splash screen.
      home: const SplashScreen(),
    );
  }
}

class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key, required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VibeSync',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.redAccent,
                      size: 70,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'App startup failed',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SelectableText(
                      error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
