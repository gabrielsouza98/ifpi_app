import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'auth_screens.dart';
import 'dashboard_screens.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'empresa_produto_form.dart';
import 'empresa_meus_produtos.dart';
import 'empresa_produto_detalhes.dart';
import 'empresa_configuracoes.dart';
import 'usuario_configuracoes.dart';
import 'services/produto_service.dart';
import 'theme/premium_theme.dart';
import 'widgets/premium_button.dart';
import 'widgets/premium_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
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
            title: 'Descontaí',
            theme: ThemeService.lightTheme,
            darkTheme: ThemeService.darkTheme,
            themeMode: themeService.themeMode,
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            routes: {
              '/': (context) => const MyHomePage(title: 'Descontaí'),
              '/usuario': (context) => const UsuarioLoginScreen(),
              '/empresa': (context) => const EmpresaLoginScreen(),
              '/usuario/criar-conta': (context) => const UsuarioCriarContaScreen(),
              '/empresa/criar-conta': (context) => const EmpresaCriarContaScreen(),
              '/usuario/esqueci-senha': (context) => const UsuarioEsqueciSenhaScreen(),
              '/empresa/esqueci-senha': (context) => const EmpresaEsqueciSenhaScreen(),
              '/usuario/dashboard': (context) => UsuarioDashboardScreen(),
              '/empresa/dashboard': (context) => EmpresaDashboardScreen(),
              '/empresa/produto/novo': (context) => const EmpresaProdutoFormScreen(),
              '/empresa/produtos': (context) => EmpresaMeusProdutosScreen(),
              '/empresa/configuracoes': (context) => const EmpresaConfiguracoesScreen(),
              '/usuario/configuracoes': (context) => const UsuarioConfiguracoesScreen(),
              '/produto/editar': (context) {
                final args = ModalRoute.of(context)?.settings.arguments;
                if (args is Produto) {
                  return EmpresaProdutoFormScreen(produto: args);
                }
                return const EmpresaProdutoFormScreen();
              },
            },
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isHoveringUsuario = false;
  bool _isHoveringEmpresa = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Paleta de cores premium
    const Color primaryColor = Color(0xFF6366F1); // Indigo elegante
    const Color secondaryColor = Color(0xFF8B5CF6); // Roxo sofisticado
    const Color accentColor = Color(0xFFEC4899); // Rosa premium
    const Color backgroundColor = Color(0xFF0F172A); // Azul escuro profundo
    const Color surfaceColor = Color(0xFF1E293B); // Superfície escura
    const Color textPrimary = Color(0xFFF8FAFC); // Branco suave
    const Color textSecondary = Color(0xFFCBD5E1); // Cinza claro

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundColor,
              const Color(0xFF1E293B),
              const Color(0xFF0F172A),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Efeitos de fundo animados
              Positioned.fill(
                child: CustomPaint(
                  painter: _BackgroundPainter(_animationController),
                ),
              ),
              
              // Conteúdo principal
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      
                      // Logo Premium
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6B35).withOpacity(0.4),
                              blurRadius: 40,
                              spreadRadius: 0,
                              offset: const Offset(0, 20),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: -5,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/Orange E-commerce Online Store Logo.jpg',
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback caso a imagem não carregue
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFFFF6B35),
                                      const Color(0xFFFF8C42),
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  Icons.shopping_bag_rounded,
                                  size: 56,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 200.ms)
                          .scale(delay: 200.ms, duration: 600.ms, begin: const Offset(0.8, 0.8)),
                      
                      const SizedBox(height: 48),
                      
                      // Título Principal
                      Text(
                        'Descontaí',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.5,
                          color: textPrimary,
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 400.ms)
                          .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 400.ms),
                      
                      const SizedBox(height: 16),
                      
                      // Subtítulo Premium
                      Text(
                        'Plataforma premium de descontos e ofertas',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.2,
                          color: textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 600.ms)
                          .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 600.ms),
                      
                      const SizedBox(height: 64),
                      
                      // Card de Seleção com Glassmorphism
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 0,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Selecione seu perfil',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            // Botão Usuário Premium
                            _PremiumButton(
                              label: 'Comprador',
                              subtitle: 'Explore ofertas e descontos',
                              icon: Icons.person_rounded,
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor,
                                  primaryColor.withOpacity(0.8),
                                ],
                              ),
                              onPressed: () => Navigator.pushNamed(context, '/usuario'),
                              onHover: (hovering) {
                                setState(() => _isHoveringUsuario = hovering);
                              },
                              isHovering: _isHoveringUsuario,
                            )
                                .animate()
                                .fadeIn(duration: 500.ms, delay: 800.ms)
                                .slideX(begin: -0.2, end: 0, duration: 500.ms, delay: 800.ms),
                            
                            const SizedBox(height: 16),
                            
                            // Botão Empresa Premium
                            _PremiumButton(
                              label: 'Empresa',
                              subtitle: 'Gerencie produtos e ofertas',
                              icon: Icons.business_rounded,
                              gradient: LinearGradient(
                                colors: [
                                  accentColor,
                                  accentColor.withOpacity(0.8),
                                ],
                              ),
                              onPressed: () => Navigator.pushNamed(context, '/empresa'),
                              onHover: (hovering) {
                                setState(() => _isHoveringEmpresa = hovering);
                              },
                              isHovering: _isHoveringEmpresa,
                            )
                                .animate()
                                .fadeIn(duration: 500.ms, delay: 1000.ms)
                                .slideX(begin: 0.2, end: 0, duration: 500.ms, delay: 1000.ms),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 700.ms)
                          .scale(delay: 700.ms, duration: 600.ms, begin: const Offset(0.95, 0.95)),
                      
                      const SizedBox(height: 48),
                      
                      // Footer Premium
                      Text(
                        '© 2025 Descontaí. Todos os direitos reservados.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: textSecondary.withOpacity(0.6),
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 1200.ms),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Botão Premium com Glassmorphism e Microinterações
class _PremiumButton extends StatefulWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onPressed;
  final Function(bool) onHover;
  final bool isHovering;

  const _PremiumButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onPressed,
    required this.onHover,
    required this.isHovering,
  });

  @override
  State<_PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<_PremiumButton> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        widget.onHover(true);
        _scaleController.forward();
      },
      onExit: (_) {
        widget.onHover(false);
        _scaleController.reverse();
      },
      child: GestureDetector(
        onTapDown: (_) => _scaleController.forward(),
        onTapUp: (_) {
          _scaleController.reverse();
          widget.onPressed();
        },
        onTapCancel: () => _scaleController.reverse(),
        child: AnimatedBuilder(
          animation: _scaleController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 - (_scaleController.value * 0.05),
              child: Container(
                constraints: const BoxConstraints(minHeight: 80),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: widget.gradient,
                  boxShadow: [
                    BoxShadow(
                      color: (widget.gradient.colors.first as Color).withOpacity(0.4),
                      blurRadius: widget.isHovering ? 25 : 15,
                      spreadRadius: widget.isHovering ? 2 : 0,
                      offset: Offset(0, widget.isHovering ? 8 : 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onPressed,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              widget.icon,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.label,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.subtitle,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white.withOpacity(0.9),
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Pintor para efeitos de fundo animados
class _BackgroundPainter extends CustomPainter {
  final Animation<double> animation;

  _BackgroundPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);

    // Círculos animados de fundo
    final center1 = Offset(size.width * 0.2, size.height * 0.3);
    final radius1 = 150 + (animation.value * 50);
    paint.shader = LinearGradient(
      colors: [
        const Color(0xFF6366F1).withOpacity(0.15),
        const Color(0xFF6366F1).withOpacity(0.05),
      ],
    ).createShader(Rect.fromCircle(center: center1, radius: radius1));
    canvas.drawCircle(center1, radius1, paint);

    final center2 = Offset(size.width * 0.8, size.height * 0.7);
    final radius2 = 200 + (animation.value * 30);
    paint.shader = LinearGradient(
      colors: [
        const Color(0xFFEC4899).withOpacity(0.12),
        const Color(0xFFEC4899).withOpacity(0.03),
      ],
    ).createShader(Rect.fromCircle(center: center2, radius: radius2));
    canvas.drawCircle(center2, radius2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Tela de Login do Usuário
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
                      child: Icon(
                        Icons.person_rounded,
                        size: 48,
                        color: PremiumTheme.textPrimary,
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
                                  // recarrega tema para o usuário autenticado
                                  final themeService = Provider.of<ThemeService>(context, listen: false);
                                  await themeService.reloadTheme();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Acesso realizado com sucesso'),
                                      backgroundColor: PremiumTheme.successColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                  Navigator.pushReplacementNamed(context, '/usuario/dashboard');
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
                                          await themeService.reloadTheme();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: const Text('Acesso realizado com sucesso'),
                                              backgroundColor: PremiumTheme.successColor,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                          );
                                          Navigator.pushReplacementNamed(
                                              context, '/usuario/dashboard');
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
                                  await themeService.reloadTheme();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Acesso realizado com sucesso'),
                                      backgroundColor: PremiumTheme.successColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                  Navigator.pushReplacementNamed(context, '/empresa/dashboard');
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
                                          await themeService.reloadTheme();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: const Text('Acesso realizado com sucesso'),
                                              backgroundColor: PremiumTheme.successColor,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                          );
                                          Navigator.pushReplacementNamed(
                                              context, '/empresa/dashboard');
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
