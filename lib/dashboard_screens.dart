import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'services/auth_service.dart';
import 'services/produto_service.dart';
import 'usuario_produto_detalhes.dart';
import 'theme/premium_theme.dart';
import 'widgets/premium_background.dart';

// Dashboard do Usuário (Home com busca, categorias e lista de produtos)
class UsuarioDashboardScreen extends StatefulWidget {
  const UsuarioDashboardScreen({super.key});

  @override
  State<UsuarioDashboardScreen> createState() => _UsuarioDashboardScreenState();
}

class _UsuarioDashboardScreenState extends State<UsuarioDashboardScreen> {
  final AuthService _authService = AuthService();
  final ProdutoService _produtoService = ProdutoService();

  final TextEditingController _searchController = TextEditingController();
  bool _checandoTipoUsuario = true;

  /// Mesma lista de categorias do cadastro de produtos (empresa)
  static const List<String> _categories = <String>[
    'alimentos',
    'limpeza',
    'eletrônicos',
    'vestuário',
    'calçados',
    'acessórios',
    'beleza e cuidados pessoais',
    'perfumaria',
    'farmácia',
    'bebidas',
    'pet shop',
    'papelaria',
    'brinquedos',
    'esporte e lazer',
    'móveis',
    'decoração',
    'cama, mesa e banho',
    'informática',
    'telefonia',
    'automotivo',
    'ferramentas',
    'construção',
    'jardim',
    'livros',
    'instrumentos musicais',
    'outros',
  ];

  String _selectedCategory = '';

  final ScrollController _categoryScrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Garante que apenas contas do tipo "usuario" acessem este dashboard
    Future.microtask(_validarTipoUsuario);
  }

  Future<void> _validarTipoUsuario() async {
    try {
      final bool isUsuario = await _authService.isUsuario();
      if (!mounted) return;
      if (!isUsuario) {
        await _authService.signOut();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Este acesso é exclusivo para compradores. Entre com uma conta de comprador.',
            ),
            backgroundColor: PremiumTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } else {
        setState(() => _checandoTipoUsuario = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _checandoTipoUsuario = false);
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
          'Descontaí',
          style: PremiumTheme.titleLarge.copyWith(color: textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Configurações',
            icon: Icon(Icons.settings_rounded, color: textPrimary),
            onPressed: () {
              Navigator.pushNamed(context, '/usuario/configuracoes');
            },
          ),
          IconButton(
            tooltip: 'Sair',
            icon: Icon(Icons.logout_rounded, color: textPrimary),
            onPressed: () async {
              await _authService.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              }
            },
          ),
        ],
      ),
      body: PremiumBackground(
        child: SafeArea(
          child: _checandoTipoUsuario
              ? Center(
                  child: CircularProgressIndicator(
                    color: PremiumTheme.primaryColor,
                  ),
                )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipOval(
                          child: Image.asset(
                            'assets/images/usuario.png',
                            width: 56,
                            height: 56,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Olá, bem-vindo',
                                style: PremiumTheme.headlineSmall.copyWith(
                                  color: textPrimary,
                                ),
                              )
                                  .animate()
                                  .fadeIn(duration: 600.ms, delay: 200.ms)
                                  .slideX(
                                    begin: -0.1,
                                    end: 0,
                                    duration: 600.ms,
                                    delay: 200.ms,
                                  ),
                              const SizedBox(height: 8),
                              Text(
                                'Explore ofertas exclusivas e encontre os melhores preços',
                                style: PremiumTheme.bodyLarge.copyWith(
                                  color: PremiumTheme.getTextSecondary(isDark),
                                ),
                              )
                                  .animate()
                                  .fadeIn(duration: 600.ms, delay: 400.ms)
                                  .slideX(
                                    begin: -0.1,
                                    end: 0,
                                    duration: 600.ms,
                                    delay: 400.ms,
                                  ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSearchField(context)
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 600.ms)
                        .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 600.ms),
                    const SizedBox(height: 16),
                    _buildCategoryChips(context)
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 800.ms)
                        .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 800.ms),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: PremiumTheme.surfaceColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: StreamBuilder<List<Produto>>(
                    stream: _produtoService.streamProdutos(
                      categoria: _selectedCategory.isEmpty ? null : _selectedCategory,
                    ),
                    builder: (BuildContext context, AsyncSnapshot<List<Produto>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: PremiumTheme.primaryColor,
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                size: 56,
                                color: PremiumTheme.errorColor,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Ops, algo deu errado.',
                                style: PremiumTheme.bodyLarge.copyWith(
                                  color: PremiumTheme.errorColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Não foi possível carregar os produtos. Tente novamente em alguns instantes.',
                                style: PremiumTheme.bodyMedium.copyWith(
                                  color: PremiumTheme.getTextSecondary(isDark),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }
                      final List<Produto> itensAll = snapshot.data ?? <Produto>[];
                      final String q = _searchController.text.toLowerCase().trim();
                      final List<Produto> itens = q.isEmpty
                          ? itensAll
                          : itensAll
                              .where((Produto p) => p.nome.toLowerCase().contains(q))
                              .toList();
                      if (itens.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 64,
                                color: PremiumTheme.getTextTertiary(isDark),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhum produto encontrado',
                                style: PremiumTheme.bodyLarge.copyWith(
                                  color: PremiumTheme.getTextSecondary(isDark),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                        itemCount: itens.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Produto item = itens[index];
                          return _buildProdutoCardFromModel(context, item)
                              .animate()
                              .fadeIn(
                                duration: 400.ms,
                                delay: (index * 50).ms,
                              )
                              .slideX(
                                begin: 0.1,
                                end: 0,
                                duration: 400.ms,
                                delay: (index * 50).ms,
                              );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = PremiumTheme.getTextPrimary(isDark);
    
    return Container(
      decoration: PremiumTheme.glassmorphism(borderRadius: 20, context: context),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: textPrimary),
              decoration: InputDecoration(
                hintText: 'Buscar produtos...',
                hintStyle: PremiumTheme.bodyMedium.copyWith(
                  color: PremiumTheme.getTextTertiary(isDark),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: PremiumTheme.getTextSecondary(isDark),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = PremiumTheme.getTextPrimary(isDark);
    
    return SizedBox(
      height: 58,
      child: Scrollbar(
        controller: _categoryScrollController,
        thumbVisibility: true,
        trackVisibility: true,
        child: ListView.separated(
          controller: _categoryScrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(left: 4, right: 4, top: 2, bottom: 14),
          itemCount: _categories.length + 1,
          separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 12),
          itemBuilder: (BuildContext context, int index) {
            final bool isAll = index == 0;
            final String label = isAll ? 'Todas' : _categories[index - 1];
            final bool selected = isAll ? _selectedCategory.isEmpty : _selectedCategory == label;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = isAll ? '' : label;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: selected ? PremiumTheme.primaryGradient : null,
                  color: selected
                      ? null
                      : PremiumTheme.getSurfaceColor(isDark).withOpacity(isDark ? 0.4 : 1.0),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: selected
                        ? Colors.transparent
                        : (isDark
                            ? Colors.white.withOpacity(0.2)
                            : Colors.black.withOpacity(0.08)),
                    width: 1.5,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: PremiumTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  label,
                  style: PremiumTheme.bodyMedium.copyWith(
                    color: selected ? Colors.white : textPrimary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProdutoCardFromModel(BuildContext context, Produto item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = PremiumTheme.getTextPrimary(isDark);
    final String? imagemPrincipal = item.imagensUrls.isNotEmpty
        ? item.imagensUrls.first
        : item.imagemUrl;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => UsuarioProdutoDetalhesScreen(produto: item),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: PremiumTheme.glassmorphism(borderRadius: 20, context: context),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: PremiumTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: imagemPrincipal != null && imagemPrincipal.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        imagemPrincipal,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: PremiumTheme.primaryColor,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object error,
                            StackTrace? stackTrace) {
                          return Icon(
                            Icons.image_not_supported_rounded,
                            size: 32,
                            color: PremiumTheme.getTextTertiary(isDark),
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.shopping_bag_rounded,
                      size: 36,
                      color: PremiumTheme.getTextTertiary(isDark),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nome,
                    style: PremiumTheme.titleLarge.copyWith(
                      color: textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: PremiumTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'R\$ ${item.preco.toStringAsFixed(2)}',
                      style: PremiumTheme.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.category_rounded,
                        size: 14,
                        color: PremiumTheme.getTextTertiary(isDark),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.categoria,
                        style: PremiumTheme.bodySmall.copyWith(
                          color: PremiumTheme.getTextTertiary(isDark),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: PremiumTheme.getTextSecondary(isDark),
            ),
          ],
        ),
      ),
    );
  }

  
}

// Dashboard da Empresa
class EmpresaDashboardScreen extends StatefulWidget {
  const EmpresaDashboardScreen({super.key});

  @override
  State<EmpresaDashboardScreen> createState() => _EmpresaDashboardScreenState();
}

class _EmpresaDashboardScreenState extends State<EmpresaDashboardScreen> {
  final AuthService _authService = AuthService();
  bool _checandoTipoEmpresa = true;

  @override
  void initState() {
    super.initState();
    // Garante que apenas contas do tipo "empresa" acessem este dashboard
    Future.microtask(_validarTipoEmpresa);
  }

  Future<void> _validarTipoEmpresa() async {
    try {
      final bool isEmpresa = await _authService.isEmpresa();
      if (!mounted) return;
      if (!isEmpresa) {
        await _authService.signOut();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Este acesso é exclusivo para empresas. Entre com uma conta empresarial.',
            ),
            backgroundColor: PremiumTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } else {
        setState(() => _checandoTipoEmpresa = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _checandoTipoEmpresa = false);
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
          'Painel Empresarial',
          style: PremiumTheme.titleLarge.copyWith(color: textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded, color: textPrimary),
            onPressed: () async {
              await _authService.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              }
            },
          ),
        ],
      ),
      body: PremiumBackground(
        child: SafeArea(
          child: _checandoTipoEmpresa
              ? Center(
                  child: CircularProgressIndicator(
                    color: PremiumTheme.primaryColor,
                  ),
                )
              : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card de boas-vindas
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: PremiumTheme.glassmorphism(borderRadius: 24, context: context),
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: PremiumTheme.accentGradient,
                          boxShadow: [
                            BoxShadow(
                              color: PremiumTheme.accentColor.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 0,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/empresa.png',
                            width: 36,
                            height: 36,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bem-vindo de volta',
                              style: PremiumTheme.headlineSmall.copyWith(
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Gerencie seus produtos e ofertas',
                              style: PremiumTheme.bodyMedium.copyWith(
                                color: PremiumTheme.getTextSecondary(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 200.ms)
                    .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 200.ms),
                const SizedBox(height: 32),
                Text(
                  'Funcionalidades',
                  style: PremiumTheme.headlineSmall.copyWith(
                    color: textPrimary,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 400.ms)
                    .slideX(begin: -0.1, end: 0, duration: 600.ms, delay: 400.ms),
                const SizedBox(height: 20),
                // Grid de funcionalidades
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildFeatureCard(
                      context,
                      'Cadastrar Produto',
                      Icons.add_circle_rounded,
                      PremiumTheme.successColor,
                      () {
                        Navigator.pushNamed(context, '/empresa/produto/novo');
                      },
                      0,
                    ),
                    _buildFeatureCard(
                      context,
                      'Meus Produtos',
                      Icons.inventory_2_rounded,
                      PremiumTheme.accentColor,
                      () {
                        Navigator.pushNamed(context, '/empresa/produtos');
                      },
                      1,
                    ),
                    _buildFeatureCard(
                      context,
                      'Analytics',
                      Icons.analytics_rounded,
                      PremiumTheme.secondaryColor,
                      () {
                        Navigator.pushNamed(context, '/empresa/analytics');
                      },
                      2,
                    ),
                    _buildFeatureCard(
                      context,
                      'Configurações',
                      Icons.settings_rounded,
                      PremiumTheme.primaryColor,
                      () {
                        Navigator.pushNamed(context, '/empresa/configuracoes');
                      },
                      3,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
    int index,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = PremiumTheme.getTextPrimary(isDark);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: PremiumTheme.glassmorphism(borderRadius: 20, context: context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color,
                    color.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 0,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 32,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: PremiumTheme.bodyLarge.copyWith(
                color: textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 500.ms, delay: (600 + index * 100).ms)
          .scale(delay: (600 + index * 100).ms, duration: 500.ms, begin: const Offset(0.9, 0.9)),
    );
  }
}
