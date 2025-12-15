import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/premium_theme.dart';

class ThemeService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  ThemeMode _themeModeEmpresa = ThemeMode.dark;
  ThemeMode _themeModeUsuario = ThemeMode.dark;
  String? _currentUserType; // 'empresa' ou 'usuario'
  bool _isLoading = false;

  ThemeMode get themeMode {
    // Retorna o tema baseado no tipo de usuário atual
    if (_currentUserType == 'empresa') {
      return _themeModeEmpresa;
    } else if (_currentUserType == 'usuario') {
      return _themeModeUsuario;
    }
    return ThemeMode.dark; // Padrão
  }
  
  bool get isLoading => _isLoading;

  ThemeService() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Verificar se é empresa
        final empresaDoc = await _firestore
            .collection('empresas')
            .doc(user.uid)
            .get();

        if (empresaDoc.exists) {
          _currentUserType = 'empresa';
          final data = empresaDoc.data() as Map<String, dynamic>;
          final tema = data['tema'] as String?;
          
          if (tema == 'light') {
            _themeModeEmpresa = ThemeMode.light;
          } else {
            _themeModeEmpresa = ThemeMode.dark;
          }
        } else {
          // Verificar se é usuário
          final usuarioDoc = await _firestore
              .collection('usuarios')
              .doc(user.uid)
              .get();

          if (usuarioDoc.exists) {
            _currentUserType = 'usuario';
            final data = usuarioDoc.data() as Map<String, dynamic>;
            final tema = data['tema'] as String?;
            
            if (tema == 'light') {
              _themeModeUsuario = ThemeMode.light;
            } else {
              _themeModeUsuario = ThemeMode.dark;
            }
          }
        }
      }
    } catch (e) {
      // Erro silencioso, mantém tema padrão
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTheme(String tema, {required String userType}) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final collection = userType == 'empresa' ? 'empresas' : 'usuarios';
        await _firestore
            .collection(collection)
            .doc(user.uid)
            .update({'tema': tema});

        if (userType == 'empresa') {
          _themeModeEmpresa = tema == 'light' ? ThemeMode.light : ThemeMode.dark;
          _currentUserType = 'empresa';
        } else {
          _themeModeUsuario = tema == 'light' ? ThemeMode.light : ThemeMode.dark;
          _currentUserType = 'usuario';
        }
        notifyListeners();
      }
    } catch (e) {
      // Erro silencioso
    }
  }
  
  // Método para recarregar o tema quando o usuário fizer login
  Future<void> reloadTheme() async {
    await _loadTheme();
  }

  // Tema escuro
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: PremiumTheme.backgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: PremiumTheme.primaryColor,
        secondary: PremiumTheme.secondaryColor,
        error: PremiumTheme.errorColor,
        surface: PremiumTheme.surfaceColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: PremiumTheme.textPrimary),
      ),
    );
  }

  // Tema claro
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF1F5F9), // Cinza muito claro
      colorScheme: const ColorScheme.light(
        primary: PremiumTheme.primaryColor,
        secondary: PremiumTheme.secondaryColor,
        error: PremiumTheme.errorColor,
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF0F172A), // Texto escuro para contraste
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF0F172A)),
      ),
    );
  }
}

