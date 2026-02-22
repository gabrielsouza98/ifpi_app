import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'services/produto_service.dart';
import 'theme/premium_theme.dart';
import 'widgets/premium_button.dart';
import 'widgets/premium_background.dart';

class EmpresaProdutoDetalhesScreen extends StatefulWidget {
  const EmpresaProdutoDetalhesScreen({super.key, required this.produto});

  final Produto produto;

  @override
  State<EmpresaProdutoDetalhesScreen> createState() =>
      _EmpresaProdutoDetalhesScreenState();
}

class _EmpresaProdutoDetalhesScreenState
    extends State<EmpresaProdutoDetalhesScreen> {
  late Produto produto;

  @override
  void initState() {
    super.initState();
    produto = widget.produto;
  }

  List<String> _buildImageList(Produto p) {
    if (p.imagensUrls.isNotEmpty) return p.imagensUrls;
    if (p.imagemUrl != null && p.imagemUrl!.isNotEmpty) return <String>[p.imagemUrl!];
    return const <String>[];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = PremiumTheme.getTextPrimary(isDark);
    final backgroundColor = PremiumTheme.getBackgroundColor(isDark);
    final List<String> imagens = _buildImageList(produto);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Detalhes do Produto',
          style: PremiumTheme.titleLarge.copyWith(color: textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: PremiumTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            onPressed: () async {
              final resultado = await Navigator.of(context)
                  .pushNamed('/produto/editar', arguments: produto);

              if (resultado is Produto && mounted) {
                setState(() {
                  produto = resultado;
                });
              }
            },
          ),
        ],
      ),
      body: PremiumBackground(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              // Galeria de imagens principal
          if (imagens.isNotEmpty)
                _Galeria(imagens: imagens)
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 200.ms)
                    .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 200.ms)
              else
                Container(
                  height: 300,
                  width: double.infinity,
                  margin: const EdgeInsets.all(20),
                  decoration: PremiumTheme.glassmorphism(borderRadius: 24, context: context),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported_rounded,
                        size: 80,
                        color: PremiumTheme.getTextTertiary(isDark),
                      ),
          const SizedBox(height: 16),
                      Text(
                        'Sem imagens',
                        style: PremiumTheme.bodyLarge.copyWith(
                          color: PremiumTheme.getTextSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 200.ms)
                    .scale(delay: 200.ms, duration: 600.ms, begin: const Offset(0.95, 0.95)),
              
              // Informações do produto
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome do produto em destaque
                    Text(
                      produto.nome,
                      style: PremiumTheme.headlineMedium.copyWith(
                        color: textPrimary,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 400.ms)
                        .slideX(begin: -0.1, end: 0, duration: 600.ms, delay: 400.ms),
                    
                    const SizedBox(height: 20),
                    
                    // Preço em destaque
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: PremiumTheme.accentGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: PremiumTheme.accentColor.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 0,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        'R\$ ${produto.preco.toStringAsFixed(2)}',
                        style: PremiumTheme.headlineSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 500.ms)
                        .scale(delay: 500.ms, duration: 600.ms, begin: const Offset(0.9, 0.9)),
                    
                    const SizedBox(height: 24),
                    
                    // Categoria
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: PremiumTheme.glassmorphism(borderRadius: 16, context: context),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: PremiumTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.category_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Categoria',
                                  style: PremiumTheme.bodySmall.copyWith(
                                    color: PremiumTheme.getTextTertiary(isDark),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  produto.categoria,
                                  style: PremiumTheme.bodyLarge.copyWith(
                                    color: textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 600.ms)
                        .slideX(begin: -0.1, end: 0, duration: 600.ms, delay: 600.ms),
                    
                    const SizedBox(height: 24),
                    
                    // Descrição
          Text(
                      'Descrição',
                      style: PremiumTheme.titleLarge.copyWith(
                        color: textPrimary,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 700.ms)
                        .slideX(begin: -0.1, end: 0, duration: 600.ms, delay: 700.ms),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: PremiumTheme.glassmorphism(borderRadius: 20, context: context),
                      child: Text(
            (produto.descricao == null || produto.descricao!.trim().isEmpty)
                            ? 'Este produto não possui descrição.'
                : produto.descricao!,
                        style: PremiumTheme.bodyLarge.copyWith(
                          color: PremiumTheme.getTextSecondary(isDark),
                          height: 1.6,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 800.ms)
                        .scale(delay: 800.ms, duration: 600.ms, begin: const Offset(0.95, 0.95)),
                    
                    const SizedBox(height: 32),
                    
                    // Botão de exclusão
                    PremiumButton(
                      label: 'Excluir produto',
                      icon: Icons.delete_rounded,
                      gradient: LinearGradient(
                        colors: [
                          PremiumTheme.errorColor,
                          PremiumTheme.errorColor.withOpacity(0.8),
                        ],
                      ),
            onPressed: () async {
              final bool? confirmar = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  final textPrimary = PremiumTheme.getTextPrimary(isDark);
                  
                  return AlertDialog(
                              backgroundColor: PremiumTheme.getSurfaceColor(isDark),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              title: Text(
                                'Confirmar exclusão',
                                style: PremiumTheme.titleLarge.copyWith(
                                  color: textPrimary,
                                ),
                              ),
                              content: Text(
                                'Esta ação não pode ser desfeita. Deseja realmente excluir este produto?',
                                style: PremiumTheme.bodyMedium.copyWith(
                                  color: PremiumTheme.getTextSecondary(isDark),
                                ),
                              ),
                    actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text(
                                    'Cancelar',
                                    style: TextStyle(color: PremiumTheme.getTextSecondary(isDark)),
                                  ),
                                ),
                                PremiumButton(
                                  label: 'Excluir',
                                  icon: Icons.delete_rounded,
                                  gradient: LinearGradient(
                                    colors: [
                                      PremiumTheme.errorColor,
                                      PremiumTheme.errorColor.withOpacity(0.8),
                                    ],
                                  ),
                                  height: 40,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  onPressed: () => Navigator.pop(context, true),
                                ),
                    ],
                  );
                },
              );
              if (confirmar == true) {
                await ProdutoService().deletarProduto(produto.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Produto excluído com sucesso'),
                                backgroundColor: PremiumTheme.successColor,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        }
                      },
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 900.ms)
                        .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 900.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Galeria extends StatefulWidget {
  const _Galeria({required this.imagens});
  final List<String> imagens;

  @override
  State<_Galeria> createState() => _GaleriaState();
}

class _GaleriaState extends State<_Galeria> {
  int _index = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextImage() {
    if (_index < widget.imagens.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousImage() {
    if (_index > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: PremiumTheme.glassmorphism(borderRadius: 24, context: context),
      child: Column(
        children: [
          // Imagem principal
          Container(
            height: 300,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: widget.imagens.length,
                    onPageChanged: (int i) => setState(() => _index = i),
                    itemBuilder: (BuildContext context, int i) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      
                      return Container(
                        color: PremiumTheme.getSurfaceColor(isDark),
                        child: Image.network(
                          widget.imagens[i],
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: PremiumTheme.accentColor,
                                strokeWidth: 3,
                              ),
                            );
                          },
                          errorBuilder: (BuildContext context, Object error,
                              StackTrace? stackTrace) {
                            final isDark = Theme.of(context).brightness == Brightness.dark;
                            
                            return Container(
                              color: PremiumTheme.getSurfaceColor(isDark),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported_rounded,
                                      size: 64,
                                      color: PremiumTheme.getTextTertiary(isDark),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Erro ao carregar imagem',
                                      style: PremiumTheme.bodyMedium.copyWith(
                                        color: PremiumTheme.getTextSecondary(isDark),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  
                  // Botões de navegação
                  if (widget.imagens.length > 1) ...[
                    // Botão anterior
                    Positioned(
                      left: 12,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: _previousImage,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: PremiumTheme.primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: PremiumTheme.primaryColor.withOpacity(0.4),
                                  blurRadius: 12,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.chevron_left_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Botão próximo
                    Positioned(
                      right: 12,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: _nextImage,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: PremiumTheme.primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: PremiumTheme.primaryColor.withOpacity(0.4),
                                  blurRadius: 12,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Contador de imagens e indicadores
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Contador de imagens
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: PremiumTheme.accentGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_index + 1} / ${widget.imagens.length}',
                    style: PremiumTheme.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                // Indicadores
                Row(
                  children: List<Widget>.generate(widget.imagens.length, (int i) {
                    final bool active = i == _index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 32 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: active ? PremiumTheme.primaryGradient : null,
                        color: active ? null : (isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: active
                            ? [
                                BoxShadow(
                                  color: PremiumTheme.primaryColor.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


