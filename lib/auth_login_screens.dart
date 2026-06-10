import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'theme/premium_theme.dart';
import 'widgets/premium_button.dart';
import 'widgets/premium_background.dart';
import 'widgets/app_snackbar.dart';

class UsuarioLoginScreen extends StatefulWidget {
  const UsuarioLoginScreen({super.key});

  @override
  State<UsuarioLoginScreen> createState() => _UsuarioLoginScreenState();
}

class _UsuarioLoginScreenState extends State<UsuarioLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _authService = AuthService();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = PremiumTheme.getBackgroundColor(isDark);
    final textPrimary = PremiumTheme.getTextPrimary(isDark);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Acesso Comprador',
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  
                  // Logo Premium
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: PremiumTheme.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: PremiumTheme.primaryColor.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 0,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/usuario.png',
                          width: 48,
                          height: 48,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 200.ms)
                      .scale(delay: 200.ms, duration: 600.ms, begin: const Offset(0.8, 0.8)),
                  
                  const SizedBox(height: 40),
                  
                  // Título
                  Text(
                    'Bem-vindo de volta',
                    style: PremiumTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 400.ms)
                      .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 400.ms),
                  
                  const SizedBox(height: 12),
                  
                  // Subtítulo
                  Text(
                    'Acesse sua conta para continuar explorando ofertas exclusivas',
                    style: PremiumTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 600.ms)
                      .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 600.ms),
                  
                  const SizedBox(height: 48),
                  
                  // Card de Formulário com Glassmorphism
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: PremiumTheme.glassmorphism(context: context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Campo Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: textPrimary),
                          decoration: PremiumTheme.premiumInput(
                            label: 'Endereço de email',
                            prefixIcon: Icons.email_rounded,
                            context: context,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe seu email';
                            }
                            if (!value.contains('@')) {
                              return 'Email inválido';
                            }
                            return null;
                          },
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 800.ms)
                            .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 800.ms),
                        
                        const SizedBox(height: 20),
                        
                        // Campo Senha
                        TextFormField(
                          controller: _senhaController,
                          obscureText: _obscurePassword,
                          style: TextStyle(color: textPrimary),
                          decoration: PremiumTheme.premiumInput(
                            label: 'Senha',
                            prefixIcon: Icons.lock_rounded,
                            context: context,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                color: PremiumTheme.getTextSecondary(isDark),
                              ),
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe sua senha';
                            }
                            if (value.length < 6) {
                              return 'Mínimo de 6 caracteres';
                            }
                            return null;
                          },
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 900.ms)
                            .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 900.ms),
                        
                        const SizedBox(height: 12),
                        
                        // Link Recuperar Senha
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/usuario/esqueci-senha');
                            },
                            child: Text(
                              'Esqueceu a senha?',
                              style: PremiumTheme.bodyMedium.copyWith(
                                color: PremiumTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Botão Login
                        PremiumButton(
                          label: 'Entrar',
                          icon: Icons.login_rounded,
                          gradient: PremiumTheme.primaryGradient,
                          isLoading: _isLoading,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);
                              try {
                                await _authService.signInUsuario(
                                  _emailController.text.trim(),
                                  _senhaController.text,
                                );
                                if (mounted) {
                                  AppSnackBar.success(context, 'Acesso realizado com sucesso');
                                  Navigator.pushReplacementNamed(context, '/usuario/dashboard');
                                }
                              } catch (e) {
                                if (mounted) {
                                  // Mostra o erro técnico real na tela para facilitar diagnóstico.
                                  final detail = e is String ? e : e.toString();
                                  AppSnackBar.error(
                                    context,
                                    'Ops, algo deu errado.\n$detail',
                                  );
                                }
                              } finally {
                                if (mounted) setState(() => _isLoading = false);
                              }
                            }
                          },
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 1000.ms)
                            .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 1000.ms),
                        
                        const SizedBox(height: 24),
                        
                        // Divisor
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.white.withOpacity(0.2),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'ou',
                                style: PremiumTheme.bodyMedium.copyWith(
                                  color: PremiumTheme.textTertiary,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.white.withOpacity(0.2),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Botão Google
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.5,
                            ),
                            color: Colors.white.withOpacity(0.05),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _isLoading
                                  ? null
                                  : () async {
                                      setState(() => _isLoading = true);
                                      try {
                                        final result =
                                            await _authService.signInWithGoogleUsuario();
                                        if (result != null && mounted) {
                                          final themeService = Provider.of<ThemeService>(context, listen: false);
                                          themeService.reloadTheme();
                                          AppSnackBar.success(
                                            context,
                                            'Acesso realizado com sucesso',
                                          );
                                          Navigator.pushReplacementNamed(
                                              context, '/usuario/dashboard');
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          // Mostra o erro técnico real na tela para facilitar diagnóstico.
                                          final detail = e is String ? e : e.toString();
                                          AppSnackBar.error(
                                            context,
                                            'Ops, algo deu errado.\n$detail',
                                          );
                                        }
                                      } finally {
                                        if (mounted) setState(() => _isLoading = false);
                                      }
                                    },
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/google_logo.png',
                                      height: 24,
                                      width: 24,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.login_rounded,
                                          color: PremiumTheme.textPrimary,
                                          size: 24,
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Continuar com Google',
                                      style: PremiumTheme.bodyLarge.copyWith(
                                        color: PremiumTheme.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 1100.ms)
                            .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 1100.ms),
                        
                        const SizedBox(height: 24),
                        
                        // Link Criar Conta
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/usuario/criar-conta');
                          },
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: PremiumTheme.bodyMedium,
                              children: [
                                TextSpan(
                                  text: 'Não possui conta? ',
                                  style: TextStyle(color: PremiumTheme.textSecondary),
                                ),
                                TextSpan(
                                  text: 'Criar conta',
                                  style: TextStyle(
                                    color: PremiumTheme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 1200.ms),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 700.ms)
                      .scale(delay: 700.ms, duration: 600.ms, begin: const Offset(0.95, 0.95)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Tela de Login da Empresa
class EmpresaLoginScreen extends StatefulWidget {
  const EmpresaLoginScreen({super.key});

  @override
  State<EmpresaLoginScreen> createState() => _EmpresaLoginScreenState();
}

class _EmpresaLoginScreenState extends State<EmpresaLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _authService = AuthService();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
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
          'Acesso Empresa',
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  
                  // Logo Premium
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: PremiumTheme.accentGradient,
                      boxShadow: [
                        BoxShadow(
                          color: PremiumTheme.accentColor.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 0,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
                          width: 2,
                        ),
                      ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/empresa.png',
                        width: 48,
                        height: 48,
                        fit: BoxFit.contain,
                      ),
                    ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 200.ms)
                      .scale(delay: 200.ms, duration: 600.ms, begin: const Offset(0.8, 0.8)),
                  
                  const SizedBox(height: 40),
                  
                  // Título
                  Text(
                    'Bem-vindo de volta',
                    style: PremiumTheme.headlineMedium.copyWith(color: textPrimary),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 400.ms)
                      .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 400.ms),
                  
                  const SizedBox(height: 12),
                  
                  // Subtítulo
                  Text(
                    'Acesse sua conta empresarial para gerenciar produtos e ofertas',
                    style: PremiumTheme.bodyLarge.copyWith(color: PremiumTheme.getTextSecondary(isDark)),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 600.ms)
                      .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 600.ms),
                  
                  const SizedBox(height: 48),
                  
                  // Card de Formulário com Glassmorphism
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: PremiumTheme.glassmorphism(context: context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Campo Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: textPrimary),
                          decoration: PremiumTheme.premiumInput(
                            label: 'Endereço de email',
                            prefixIcon: Icons.email_rounded,
                            context: context,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe seu email';
                            }
                            if (!value.contains('@')) {
                              return 'Email inválido';
                            }
                            return null;
                          },
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 800.ms)
                            .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 800.ms),
                        
                        const SizedBox(height: 20),
                        
                        // Campo Senha
                        TextFormField(
                          controller: _senhaController,
                          obscureText: _obscurePassword,
                          style: TextStyle(color: textPrimary),
                          decoration: PremiumTheme.premiumInput(
                            label: 'Senha',
                            prefixIcon: Icons.lock_rounded,
                            context: context,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                color: PremiumTheme.getTextSecondary(isDark),
                              ),
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe sua senha';
                            }
                            if (value.length < 6) {
                              return 'Mínimo de 6 caracteres';
                            }
                            return null;
                          },
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 900.ms)
                            .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 900.ms),
                        
                        const SizedBox(height: 12),
                        
                        // Link Recuperar Senha
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/empresa/esqueci-senha');
                            },
                            child: Text(
                              'Esqueceu a senha?',
                              style: PremiumTheme.bodyMedium.copyWith(
                                color: PremiumTheme.accentColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Botão Login
                        PremiumButton(
                          label: 'Entrar',
                          icon: Icons.login_rounded,
                          gradient: PremiumTheme.accentGradient,
                          isLoading: _isLoading,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);
                              try {
                                await _authService.signInEmpresa(
                                  _emailController.text.trim(),
                                  _senhaController.text,
                                );
                                if (mounted) {
                                  final themeService =
                                      Provider.of<ThemeService>(context, listen: false);
                                  themeService.reloadTheme();
                                  AppSnackBar.success(context, 'Acesso realizado com sucesso');
                                  Navigator.pushReplacementNamed(context, '/empresa/dashboard');
                                }
                              } catch (e) {
                                if (mounted) {
                                  // Mostra o erro técnico real na tela para facilitar diagnóstico.
                                  final detail = e is String ? e : e.toString();
                                  AppSnackBar.error(
                                    context,
                                    'Ops, algo deu errado.\n$detail',
                                  );
                                }
                              } finally {
                                if (mounted) setState(() => _isLoading = false);
                              }
                            }
                          },
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 1000.ms)
                            .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 1000.ms),
                        
                        const SizedBox(height: 24),
                        
                        // Divisor
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'ou',
                                style: PremiumTheme.bodyMedium.copyWith(
                                  color: PremiumTheme.getTextTertiary(isDark),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Botão Google
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
                              width: 1.5,
                            ),
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _isLoading
                                  ? null
                                  : () async {
                                      setState(() => _isLoading = true);
                                      try {
                                        final result =
                                            await _authService.signInWithGoogleEmpresa();
                                        if (result != null && mounted) {
                                          final themeService = Provider.of<ThemeService>(context, listen: false);
                                          themeService.reloadTheme();
                                          AppSnackBar.success(
                                            context,
                                            'Acesso realizado com sucesso',
                                          );
                                          Navigator.pushReplacementNamed(
                                              context, '/empresa/dashboard');
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          // Mostra o erro técnico real na tela para facilitar diagnóstico.
                                          final detail = e is String ? e : e.toString();
                                          AppSnackBar.error(
                                            context,
                                            'Ops, algo deu errado.\n$detail',
                                          );
                                        }
                                      } finally {
                                        if (mounted) setState(() => _isLoading = false);
                                      }
                                    },
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/google_logo.png',
                                      height: 24,
                                      width: 24,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.login_rounded,
                                          color: textPrimary,
                                          size: 24,
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Continuar com Google',
                                      style: PremiumTheme.bodyLarge.copyWith(
                                        color: textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 1100.ms)
                            .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 1100.ms),
                        
                        const SizedBox(height: 24),
                        
                        // Link Criar Conta
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/empresa/criar-conta');
                          },
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: PremiumTheme.bodyMedium,
                              children: [
                                TextSpan(
                                  text: 'Não possui conta? ',
                                  style: TextStyle(color: PremiumTheme.getTextSecondary(isDark)),
                                ),
                                TextSpan(
                                  text: 'Criar conta',
                                  style: TextStyle(
                                    color: PremiumTheme.accentColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 1200.ms),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 700.ms)
                      .scale(delay: 700.ms, duration: 600.ms, begin: const Offset(0.95, 0.95)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
