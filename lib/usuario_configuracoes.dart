import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'theme/premium_theme.dart';
import 'widgets/premium_background.dart';
import 'widgets/premium_button.dart';

class UsuarioConfiguracoesScreen extends StatefulWidget {
  const UsuarioConfiguracoesScreen({super.key});

  @override
  State<UsuarioConfiguracoesScreen> createState() => _UsuarioConfiguracoesScreenState();
}

class _UsuarioConfiguracoesScreenState extends State<UsuarioConfiguracoesScreen> {
  final _authService = AuthService();
  String? _temaAtual;
  Map<String, dynamic>? _usuarioData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    setState(() => _isLoading = true);
    try {
      final userId = _authService.currentUser?.uid;
      if (userId != null) {
        final doc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userId)
            .get();
        
        if (doc.exists) {
          setState(() {
            _usuarioData = doc.data() as Map<String, dynamic>;
            _temaAtual = _usuarioData?['tema'] as String? ?? 'dark';
          });
        }
      }
    } catch (e) {
      // Erro silencioso
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _salvarConfiguracoes() async {
    setState(() => _isLoading = true);
    try {
      final userId = _authService.currentUser?.uid;
      if (userId != null && _temaAtual != null) {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userId)
            .update({'tema': _temaAtual});

        // Atualizar tema via ThemeService
        final themeService = Provider.of<ThemeService>(context, listen: false);
        await themeService.updateTheme(_temaAtual!, userType: 'usuario');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Configurações salvas com sucesso'),
              backgroundColor: PremiumTheme.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: ${e.toString()}'),
            backgroundColor: PremiumTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = PremiumTheme.getTextPrimary(isDark);
    final backgroundColor = PremiumTheme.getBackgroundColor(isDark);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Configurações',
          style: PremiumTheme.titleLarge.copyWith(color: textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PremiumBackground(
        child: SafeArea(
          child: _isLoading && _usuarioData == null
              ? Center(
                  child: CircularProgressIndicator(
                    color: PremiumTheme.primaryColor,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Card de Configurações
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: PremiumTheme.glassmorphism(context: context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Título
                            Text(
                              'Configurações do Usuário',
                              style: PremiumTheme.headlineSmall.copyWith(color: textPrimary),
                              textAlign: TextAlign.center,
                            )
                                .animate()
                                .fadeIn(duration: 500.ms, delay: 200.ms)
                                .slideY(begin: -0.1, end: 0, duration: 500.ms, delay: 200.ms),
                            
                            const SizedBox(height: 32),
                            
                            // Toggle Modo Escuro/Claro
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _temaAtual == 'light' ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                        color: PremiumTheme.primaryColor,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Modo Escuro/Claro',
                                            style: PremiumTheme.bodyLarge.copyWith(
                                              color: textPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _temaAtual == 'light' ? 'Modo claro ativado' : 'Modo escuro ativado',
                                            style: PremiumTheme.bodySmall.copyWith(
                                              color: PremiumTheme.getTextSecondary(isDark),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Switch(
                                    value: _temaAtual == 'light',
                                    onChanged: (value) {
                                      setState(() {
                                        _temaAtual = value ? 'light' : 'dark';
                                      });
                                      _salvarConfiguracoes();
                                    },
                                    activeColor: PremiumTheme.primaryColor,
                                    activeTrackColor: PremiumTheme.primaryColor.withOpacity(0.5),
                                  ),
                                ],
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 500.ms, delay: 400.ms)
                                .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 400.ms),
                            
                            const SizedBox(height: 24),
                            
                            // Botão Salvar
                            PremiumButton(
                              label: 'Salvar Configurações',
                              icon: Icons.save_rounded,
                              gradient: PremiumTheme.primaryGradient,
                              isLoading: _isLoading,
                              onPressed: _salvarConfiguracoes,
                            )
                                .animate()
                                .fadeIn(duration: 500.ms, delay: 600.ms)
                                .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 600.ms),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 300.ms)
                          .scale(delay: 300.ms, duration: 600.ms, begin: const Offset(0.95, 0.95)),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

