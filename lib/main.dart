import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kDebugMode, kIsWeb, TargetPlatform;
import 'package:firebase_app_check/firebase_app_check.dart';

import 'app_routes.dart';
import 'firebase_options.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _FirebaseBootstrap.init();
  // O App Check é necessário quando o Firebase Authentication está protegido.
  // Ativamos apenas em Android (evita quebrar web, já que precisa de site key).
  // Para debug local (flutter run), desativar evita bloqueios por token/attestation.
  if (!kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android &&
      !kDebugMode) {
    await FirebaseAppCheck.instance.activate(
      // Em release (Play Store), usamos Play Integrity.
      androidProvider: AndroidProvider.playIntegrity,
    );
  }
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
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
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
