import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'services/produto_service.dart';
import 'services/auth_service.dart';
import 'empresa_produto_detalhes.dart';
import 'theme/premium_theme.dart';
import 'widgets/premium_background.dart';
import 'widgets/premium_button.dart';

class EmpresaMeusProdutosScreen extends StatelessWidget {
  EmpresaMeusProdutosScreen({super.key});

  final ProdutoService _produtoService = ProdutoService();
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = PremiumTheme.getTextPrimary(isDark);
    final backgroundColor = PremiumTheme.getBackgroundColor(isDark);
    final String? empresaId = _auth.currentUser?.uid;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Meus Produtos',
          style: PremiumTheme.titleLarge.copyWith(color: textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: empresaId == null
          ? PremiumBackground(
              child: Center(
                child: Text(
                  'Empresa não autenticada',
                  style: PremiumTheme.bodyLarge.copyWith(color: PremiumTheme.errorColor),
                ),
              ),
            )
          : PremiumBackground(
              child: StreamBuilder<List<Produto>>(
                stream: _produtoService.streamProdutos(),
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
                            size: 64,
                            color: PremiumTheme.errorColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Erro ao carregar produtos',
                            style: PremiumTheme.bodyLarge.copyWith(
                              color: PremiumTheme.errorColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  final List<Produto> itens = (snapshot.data ?? <Produto>[])
                      .where((Produto p) => p.empresaId == empresaId)
                      .toList();
                  if (itens.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 80,
                            color: PremiumTheme.getTextTertiary(isDark),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Nenhum produto cadastrado',
                            style: PremiumTheme.headlineSmall.copyWith(
                              color: PremiumTheme.getTextSecondary(isDark),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Comece cadastrando seu primeiro produto',
                            style: PremiumTheme.bodyMedium.copyWith(
                              color: PremiumTheme.getTextTertiary(isDark),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    itemCount: itens.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Produto p = itens[index];
                      final String? imagemPrincipal = p.imagensUrls.isNotEmpty
                          ? p.imagensUrls.first
                          : p.imagemUrl;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: PremiumTheme.glassmorphism(borderRadius: 20, context: context),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(20),
                          leading: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: PremiumTheme.getSurfaceColor(isDark),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
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
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: PremiumTheme.primaryColor,
                                          ),
                                        );
                                      },
                                      errorBuilder: (BuildContext context, Object error,
                                          StackTrace? stackTrace) {
                                        return Icon(
                                          Icons.image_not_supported_rounded,
                                          color: PremiumTheme.getTextTertiary(isDark),
                                        );
                                      },
                                    ),
                                  )
                                : Icon(
                                    Icons.shopping_bag_rounded,
                                    color: PremiumTheme.getTextTertiary(isDark),
                                  ),
                          ),
                          title: Text(
                            p.nome,
                            style: PremiumTheme.titleLarge.copyWith(
                              color: textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: PremiumTheme.accentGradient,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'R\$ ${p.preco.toStringAsFixed(2)}',
                                    style: PremiumTheme.bodyMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.category_rounded,
                                      size: 14,
                                      color: PremiumTheme.getTextTertiary(isDark),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      p.categoria,
                                      style: PremiumTheme.bodySmall.copyWith(
                                        color: PremiumTheme.getTextTertiary(isDark),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          trailing: IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    PremiumTheme.errorColor,
                                    PremiumTheme.errorColor.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.delete_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            onPressed: () async {
                              final bool? confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: PremiumTheme.getSurfaceColor(isDark),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: Text(
                                    'Confirmar exclusão',
                                    style: PremiumTheme.titleLarge.copyWith(
                                      color: textPrimary,
                                    ),
                                  ),
                                  content: Text(
                                    'Deseja realmente excluir este produto?',
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
                                ),
                              );
                              if (confirm == true) {
                                await _produtoService.deletarProduto(p.id);
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
                                }
                              }
                            },
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    EmpresaProdutoDetalhesScreen(produto: p),
                              ),
                            );
                          },
                        ),
                      )
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
    );
  }
}



