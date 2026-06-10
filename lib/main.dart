import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'app_routes.dart';
import 'firebase_options.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _FirebaseBootstrap.init();

  runApp(const MyApp());
}

class _FirebaseBootstrap {
  static Future<void>? _initFuture;

  static Future<void> init() {
    // Condição de corrida: em debug/hot-restart a inicialização pode ser chamada
    // duas vezes antes da primeira terminar. Usar um Future compartilhado garante
    // que apenas uma inicialização ocorra.
    _initFuture ??= _init();
    return _initFuture!;
  }

  static Future<void> _init() async {
    try {
      if (Firebase.apps.isEmpty) {
        if (kIsWeb) {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        } else {
          // No Android/iOS/macOS nativo, usar arquivos de configuração da
          // plataforma (google-services.json / GoogleService-Info.plist).
          await Firebase.initializeApp();
        }
      }
    } catch (e) {
      // Caso o FirebaseCore dispare o duplicate-app mesmo assim, tratamos
      // para não quebrar o app (inicialização já foi feita em outro caminho).
      if (!e.toString().contains('duplicate-app')) {
        rethrow;
      }
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeService(),
      child: Consumer<ThemeService>(
        builder: (context, themeService, _) {
          return MaterialApp(
            title: 'Descontai',
            theme: ThemeService.lightTheme,
            darkTheme: ThemeService.darkTheme,
            themeMode: themeService.themeMode,
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            routes: buildAppRoutes(),
          );
        },
      ),
    );
  }
}
