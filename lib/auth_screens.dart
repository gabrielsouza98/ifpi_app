import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'services/auth_service.dart';
import 'services/geocoding_service.dart';
import 'theme/premium_theme.dart';
import 'widgets/premium_button.dart';
import 'widgets/premium_background.dart';

// Tela de Criar Conta do Usuário
class UsuarioCriarContaScreen extends StatefulWidget {
  const UsuarioCriarContaScreen({super.key});

  @override
  State<UsuarioCriarContaScreen> createState() => _UsuarioCriarContaScreenState();
}

class _UsuarioCriarContaScreenState extends State<UsuarioCriarContaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _authService = AuthService();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
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
          'Criar Conta',
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
                      child: Icon(
                        Icons.person_add_rounded,
                        size: 48,
                        color: textPrimary,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 200.ms)
                      .scale(delay: 200.ms, duration: 600.ms, begin: const Offset(0.8, 0.8)),
                  
                  const SizedBox(height: 40),
                  
                  // Título
                  Text(
                    'Criar nova conta',
                    style: PremiumTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 400.ms)
                      .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 400.ms),
                  
                  const SizedBox(height: 12),
                  
                  // Subtítulo
                  Text(
                    'Preencha seus dados para começar a explorar ofertas exclusivas',
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
                        // Campo Nome
                        TextFormField(
                          controller: _nomeController,
                          style: TextStyle(color: textPrimary),
                          decoration: PremiumTheme.premiumInput(
                            label: 'Nome completo',
                            prefixIcon: Icons.person_rounded,
                            context: context,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe seu nome';
                            }
                            if (value.length < 2) {
                              return 'Mínimo de 2 caracteres';
                            }
                            return null;
                          },
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 800.ms)
                            .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 800.ms),
                        
                        const SizedBox(height: 20),
                        
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
                            .fadeIn(duration: 500.ms, delay: 900.ms)
                            .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 900.ms),
                        
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
                            .fadeIn(duration: 500.ms, delay: 1000.ms)
                            .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 1000.ms),
                        
                        const SizedBox(height: 20),
                        
                        // Campo Confirmar Senha
                        TextFormField(
                          controller: _confirmarSenhaController,
                          obscureText: _obscureConfirmPassword,
                          style: TextStyle(color: textPrimary),
                          decoration: PremiumTheme.premiumInput(
                            label: 'Confirmar senha',
                            prefixIcon: Icons.lock_outline_rounded,
                            context: context,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                color: PremiumTheme.getTextSecondary(isDark),
                              ),
                              onPressed: () {
                                setState(() =>
                                    _obscureConfirmPassword = !_obscureConfirmPassword);
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirme sua senha';
                            }
                            if (value != _senhaController.text) {
                              return 'Senhas não coincidem';
                            }
                            return null;
                          },
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 1100.ms)
                            .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 1100.ms),
                        
                        const SizedBox(height: 32),
                        
                        // Botão Criar Conta
                        PremiumButton(
                          label: 'Criar conta',
                          icon: Icons.person_add_rounded,
                          gradient: PremiumTheme.primaryGradient,
                          isLoading: _isLoading,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);
                              try {
                                await _authService.signUpUsuario(
                                  nome: _nomeController.text.trim(),
                                  email: _emailController.text.trim(),
                                  password: _senhaController.text,
                                );
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Conta criada com sucesso'),
                                      backgroundColor: PremiumTheme.successColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                  Navigator.pop(context);
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(e.toString()),
                                      backgroundColor: PremiumTheme.errorColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) setState(() => _isLoading = false);
                              }
                            }
                          },
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 1200.ms)
                            .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 1200.ms),
                        
                        const SizedBox(height: 24),
                        
                        // Link Login
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: PremiumTheme.bodyMedium,
                              children: [
                                TextSpan(
                                  text: 'Já possui conta? ',
                                  style: TextStyle(color: PremiumTheme.getTextSecondary(isDark)),
                                ),
                                TextSpan(
                                  text: 'Fazer login',
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
                            .fadeIn(duration: 500.ms, delay: 1300.ms),
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

// Tela de Criar Conta da Empresa
class EmpresaCriarContaScreen extends StatefulWidget {
  const EmpresaCriarContaScreen({super.key});

  @override
  State<EmpresaCriarContaScreen> createState() => _EmpresaCriarContaScreenState();
}

class _EmpresaCriarContaScreenState extends State<EmpresaCriarContaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeEmpresaController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _authService = AuthService();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _buscandoEndereco = false;
  List<Map<String, dynamic>> _sugestoesEndereco = [];
  double? _latitude;
  double? _longitude;
  String? _enderecoCompleto;

  @override
  void dispose() {
    _nomeEmpresaController.dispose();
    _cnpjController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    _whatsappController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }

  Future<void> _buscarEnderecos(String query) async {
    if (query.length < 3) {
      setState(() {
        _sugestoesEndereco = [];
      });
      return;
    }

    setState(() {
      _buscandoEndereco = true;
    });

    try {
      final sugestoes = await GeocodingService.buscarEnderecos(query);
      if (mounted) {
        setState(() {
          _sugestoesEndereco = sugestoes;
          _buscandoEndereco = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _buscandoEndereco = false;
        });
      }
    }
  }

  Future<void> _selecionarEndereco(String placeId, String descricao) async {
    setState(() {
      _enderecoController.text = descricao;
      _sugestoesEndereco = [];
      _buscandoEndereco = true;
    });

    try {
      final coordenadas = await GeocodingService.obterCoordenadas(placeId);
      if (mounted && coordenadas != null) {
        setState(() {
          _latitude = coordenadas['latitude'];
          _longitude = coordenadas['longitude'];
          _enderecoCompleto = descricao;
          _buscandoEndereco = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _buscandoEndereco = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Não foi possível obter as coordenadas do endereço'),
              backgroundColor: PremiumTheme.errorColor,
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
        setState(() {
          _buscandoEndereco = false;
        });
      }
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
          'Criar Conta Empresarial',
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
                          color: Colors.white.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.business_rounded,
                        size: 48,
                        color: textPrimary,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 200.ms)
                      .scale(delay: 200.ms, duration: 600.ms, begin: const Offset(0.8, 0.8)),
                  
                  const SizedBox(height: 40),
                  
                  // Título
                  Text(
                    'Criar conta empresarial',
                    style: PremiumTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 400.ms)
                      .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 400.ms),
                  
                  const SizedBox(height: 12),
                  
                  // Subtítulo
                  Text(
                    'Cadastre sua empresa e comece a gerenciar produtos e ofertas',
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
                        // Campo Nome Empresa
                        TextFormField(
                          controller: _nomeEmpresaController,
                          style: TextStyle(color: PremiumTheme.getTextPrimary(Theme.of(context).brightness == Brightness.dark)),
                          decoration: PremiumTheme.premiumInput(
                            label: 'Nome da empresa',
                            prefixIcon: Icons.business_rounded,
                            context: context,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe o nome da empresa';
                            }
                            if (value.length < 2) {
                              return 'Mínimo de 2 caracteres';
                            }
                            return null;
                          },
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 800.ms)
                            .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 800.ms),
                        
                        const SizedBox(height: 20),
                        
                        // Campo CNPJ (Opcional)
                        TextFormField(
                          controller: _cnpjController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: PremiumTheme.getTextPrimary(Theme.of(context).brightness == Brightness.dark)),
                          decoration: PremiumTheme.premiumInput(
                            label: 'CNPJ (Opcional)',
                            prefixIcon: Icons.badge_rounded,
                            hintText: '00.000.000/0000-00',
                            context: context,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(14),
                            _CnpjInputFormatter(),
                          ],
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final apenasNumeros = value.replaceAll(RegExp(r'[^0-9]'), '');
                              if (apenasNumeros.length != 14) {
                                return 'CNPJ deve ter 14 dígitos';
                              }
                            }
                            return null;
                          },
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 900.ms)
                            .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 900.ms),
                        
                        const SizedBox(height: 20),
                        
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
                            .fadeIn(duration: 500.ms, delay: 1000.ms)
                            .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 1000.ms),
                        
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
                            .fadeIn(duration: 500.ms, delay: 1100.ms)
                            .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 1100.ms),
                        
                        const SizedBox(height: 20),
                        
                        // Campo Confirmar Senha
                        TextFormField(
                          controller: _confirmarSenhaController,
                          obscureText: _obscureConfirmPassword,
                          style: TextStyle(color: textPrimary),
                          decoration: PremiumTheme.premiumInput(
                            label: 'Confirmar senha',
                            prefixIcon: Icons.lock_outline_rounded,
                            context: context,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                color: PremiumTheme.getTextSecondary(isDark),
                              ),
                              onPressed: () {
                                setState(() =>
                                    _obscureConfirmPassword = !_obscureConfirmPassword);
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirme sua senha';
                            }
                            if (value != _senhaController.text) {
                              return 'Senhas não coincidem';
                            }
                            return null;
                          },
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 1200.ms)
                            .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 1200.ms),
                        
                        const SizedBox(height: 20),
                        
                        // Campo WhatsApp
                        TextFormField(
                          controller: _whatsappController,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(color: textPrimary),
                          decoration: PremiumTheme.premiumInput(
                            label: 'WhatsApp (com DDD, apenas números)',
                            prefixIcon: Icons.phone_rounded,
                            hintText: 'Ex: 86999999999',
                            context: context,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe o número do WhatsApp';
                            }
                            // Remove caracteres não numéricos para validação
                            final apenasNumeros = value.replaceAll(RegExp(r'[^0-9]'), '');
                            if (apenasNumeros.length < 10 || apenasNumeros.length > 11) {
                              return 'Número inválido (deve ter 10 ou 11 dígitos)';
                            }
                            return null;
                          },
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 1300.ms)
                            .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 1300.ms),
                        
                        const SizedBox(height: 20),
                        
                        // Campo Endereço com Autocomplete
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _enderecoController,
                              style: TextStyle(color: textPrimary),
                              decoration: PremiumTheme.premiumInput(
                                label: 'Endereço da empresa',
                                prefixIcon: Icons.location_on_rounded,
                                hintText: 'Digite o endereço para buscar...',
                                suffixIcon: _buscandoEndereco
                                    ? Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: PremiumTheme.primaryColor,
                                          ),
                                        ),
                                      )
                                    : _enderecoController.text.isNotEmpty && _latitude != null && _longitude != null
                                        ? Icon(
                                            Icons.check_circle_rounded,
                                            color: PremiumTheme.successColor,
                                            size: 22,
                                          )
                                        : null,
                              ),
                              onChanged: (value) {
                                _buscarEnderecos(value);
                                if (value.isEmpty) {
                                  setState(() {
                                    _latitude = null;
                                    _longitude = null;
                                    _enderecoCompleto = null;
                                  });
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Informe o endereço';
                                }
                                if (_latitude == null || _longitude == null) {
                                  return 'Selecione um endereço da lista';
                                }
                                return null;
                              },
                            ),
                            
                            // Lista de sugestões
                            if (_sugestoesEndereco.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                decoration: PremiumTheme.glassmorphism(borderRadius: 12, context: context),
                                constraints: const BoxConstraints(maxHeight: 200),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _sugestoesEndereco.length,
                                  itemBuilder: (context, index) {
                                    final sugestao = _sugestoesEndereco[index];
                                    return InkWell(
                                      onTap: () => _selecionarEndereco(
                                        sugestao['placeId'],
                                        sugestao['description'],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.place_rounded,
                                              color: PremiumTheme.primaryColor,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                sugestao['description'],
                                                style: PremiumTheme.bodyMedium.copyWith(
                                                  color: textPrimary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            
                            // Indicador de endereço selecionado
                            if (_latitude != null && _longitude != null && _enderecoCompleto != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: PremiumTheme.successColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Endereço selecionado: $_enderecoCompleto',
                                        style: PremiumTheme.bodySmall.copyWith(
                                          color: PremiumTheme.successColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 1400.ms)
                            .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 1400.ms),
                        
                        const SizedBox(height: 32),
                        
                        // Botão Criar Conta
                        PremiumButton(
                          label: 'Criar conta',
                          icon: Icons.business_rounded,
                          gradient: PremiumTheme.accentGradient,
                          isLoading: _isLoading,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);
                              try {
                                // Limpar formatação do WhatsApp (apenas números)
                                final whatsappLimpo = _whatsappController.text.replaceAll(RegExp(r'[^0-9]'), '');
                                
                                if (_latitude == null || _longitude == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Por favor, selecione um endereço da lista'),
                                      backgroundColor: PremiumTheme.errorColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                
                                final cnpjLimpo = _cnpjController.text.replaceAll(RegExp(r'[^0-9]'), '');
                                
                                await _authService.signUpEmpresa(
                                  nomeEmpresa: _nomeEmpresaController.text.trim(),
                                  cnpj: cnpjLimpo.isEmpty ? '' : cnpjLimpo,
                                  email: _emailController.text.trim(),
                                  password: _senhaController.text,
                                  whatsapp: whatsappLimpo,
                                  endereco: _enderecoCompleto ?? _enderecoController.text.trim(),
                                  latitude: _latitude!,
                                  longitude: _longitude!,
                                );
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Conta empresarial criada com sucesso'),
                                      backgroundColor: PremiumTheme.successColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                  Navigator.pop(context);
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(e.toString()),
                                      backgroundColor: PremiumTheme.errorColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) setState(() => _isLoading = false);
                              }
                            }
                          },
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 1300.ms)
                            .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 1300.ms),
                        
                        const SizedBox(height: 24),
                        
                        // Link Login
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: PremiumTheme.bodyMedium,
                              children: [
                                TextSpan(
                                  text: 'Já possui conta? ',
                                  style: TextStyle(color: PremiumTheme.getTextSecondary(isDark)),
                                ),
                                TextSpan(
                                  text: 'Fazer login',
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
                            .fadeIn(duration: 500.ms, delay: 1400.ms),
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

// Tela de Esqueci Senha do Usuário
class UsuarioEsqueciSenhaScreen extends StatefulWidget {
  const UsuarioEsqueciSenhaScreen({super.key});

  @override
  State<UsuarioEsqueciSenhaScreen> createState() => _UsuarioEsqueciSenhaScreenState();
}

class _UsuarioEsqueciSenhaScreenState extends State<UsuarioEsqueciSenhaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
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
          'Recuperar Senha',
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
                  const SizedBox(height: 40),
                  
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
                      child: Icon(
                        Icons.lock_reset_rounded,
                        size: 48,
                        color: textPrimary,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 200.ms)
                      .scale(delay: 200.ms, duration: 600.ms, begin: const Offset(0.8, 0.8)),
                  
                  const SizedBox(height: 40),
                  
                  // Título
                  Text(
                    'Recuperar senha',
                    style: PremiumTheme.headlineMedium.copyWith(color: textPrimary),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 400.ms)
                      .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 400.ms),
                  
                  const SizedBox(height: 12),
                  
                  // Subtítulo
                  Text(
                    'Informe seu email e enviaremos um link para redefinir sua senha',
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
                        
                        const SizedBox(height: 32),
                        
                        // Botão Enviar
                        PremiumButton(
                          label: 'Enviar link de recuperação',
                          icon: Icons.send_rounded,
                          gradient: PremiumTheme.primaryGradient,
                          isLoading: _isLoading,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);
                              try {
                                await _authService.resetPassword(_emailController.text.trim());
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Email de recuperação enviado'),
                                      backgroundColor: PremiumTheme.successColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                  Navigator.pop(context);
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(e.toString()),
                                      backgroundColor: PremiumTheme.errorColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) setState(() => _isLoading = false);
                              }
                            }
                          },
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 900.ms)
                            .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 900.ms),
                        
                        const SizedBox(height: 24),
                        
                        // Link Voltar
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: PremiumTheme.bodyMedium,
                              children: [
                                TextSpan(
                                  text: 'Lembrou a senha? ',
                                  style: TextStyle(color: PremiumTheme.getTextSecondary(isDark)),
                                ),
                                TextSpan(
                                  text: 'Voltar ao login',
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
                            .fadeIn(duration: 500.ms, delay: 1000.ms),
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

// Tela de Esqueci Senha da Empresa
class EmpresaEsqueciSenhaScreen extends StatefulWidget {
  const EmpresaEsqueciSenhaScreen({super.key});

  @override
  State<EmpresaEsqueciSenhaScreen> createState() => _EmpresaEsqueciSenhaScreenState();
}

class _EmpresaEsqueciSenhaScreenState extends State<EmpresaEsqueciSenhaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
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
          'Recuperar Senha',
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
                  const SizedBox(height: 40),
                  
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
                          color: Colors.white.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.lock_reset_rounded,
                        size: 48,
                        color: textPrimary,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 200.ms)
                      .scale(delay: 200.ms, duration: 600.ms, begin: const Offset(0.8, 0.8)),
                  
                  const SizedBox(height: 40),
                  
                  // Título
                  Text(
                    'Recuperar senha',
                    style: PremiumTheme.headlineMedium.copyWith(color: textPrimary),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 400.ms)
                      .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 400.ms),
                  
                  const SizedBox(height: 12),
                  
                  // Subtítulo
                  Text(
                    'Informe seu email e enviaremos um link para redefinir sua senha',
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
                        
                        const SizedBox(height: 32),
                        
                        // Botão Enviar
                        PremiumButton(
                          label: 'Enviar link de recuperação',
                          icon: Icons.send_rounded,
                          gradient: PremiumTheme.accentGradient,
                          isLoading: _isLoading,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);
                              try {
                                await _authService.resetPassword(_emailController.text.trim());
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Email de recuperação enviado'),
                                      backgroundColor: PremiumTheme.successColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                  Navigator.pop(context);
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(e.toString()),
                                      backgroundColor: PremiumTheme.errorColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) setState(() => _isLoading = false);
                              }
                            }
                          },
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 900.ms)
                            .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 900.ms),
                        
                        const SizedBox(height: 24),
                        
                        // Link Voltar
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: PremiumTheme.bodyMedium,
                              children: [
                                TextSpan(
                                  text: 'Lembrou a senha? ',
                                  style: TextStyle(color: PremiumTheme.getTextSecondary(isDark)),
                                ),
                                TextSpan(
                                  text: 'Voltar ao login',
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
                            .fadeIn(duration: 500.ms, delay: 1000.ms),
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

// Formatador de CNPJ
class _CnpjInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 2) {
        formatted += '.';
      } else if (i == 5) {
        formatted += '.';
      } else if (i == 8) {
        formatted += '/';
      } else if (i == 12) {
        formatted += '-';
      }
      formatted += text[i];
    }
    
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
