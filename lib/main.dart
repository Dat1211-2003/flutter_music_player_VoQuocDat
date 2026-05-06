import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/audio_provider.dart';
import 'providers/playlist_provider.dart';
import 'providers/theme_provider.dart';
import 'services/audio_player_service.dart';
import 'services/storage_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final audioService = AudioPlayerService();
    final storageService = StorageService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AudioProvider(audioService, storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => PlaylistProvider(storageService),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Offline Music Player',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: const Color(0xFF1DB954),
              scaffoldBackgroundColor: const Color(0xFF191414),
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF1DB954),
                secondary: Color(0xFF1DB954),
                surface: Color(0xFF282828),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF191414),
                elevation: 0,
              ),
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.white),
                bodyMedium: TextStyle(color: Colors.white),
              ),
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
