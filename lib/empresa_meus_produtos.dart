import 'package:flutter/material.dart';
import 'services/produto_service.dart';
import 'services/auth_service.dart';
import 'empresa_produto_detalhes.dart';

class EmpresaMeusProdutosScreen extends StatelessWidget {
  EmpresaMeusProdutosScreen({super.key});

  final ProdutoService _produtoService = ProdutoService();
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final String? empresaId = _auth.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Produtos'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: empresaId == null
          ? const Center(child: Text('Empresa não autenticada'))
          : StreamBuilder<List<Produto>>(
              stream: _produtoService.streamProdutos(),
              builder: (BuildContext context, AsyncSnapshot<List<Produto>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar'));
                }
                final List<Produto> itens =
                    (snapshot.data ?? <Produto>[]).where((Produto p) => p.empresaId == empresaId).toList();
                if (itens.isEmpty) {
                  return const Center(child: Text('Nenhum produto cadastrado'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: itens.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Produto p = itens[index];
                    return Card(
                      child: ListTile(
                        leading: (p.imagensUrls.isNotEmpty ? p.imagensUrls.first : p.imagemUrl) != null &&
                                ((p.imagensUrls.isNotEmpty ? p.imagensUrls.first : p.imagemUrl)!).isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  p.imagensUrls.isNotEmpty ? p.imagensUrls.first : (p.imagemUrl ?? ''),
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                    return const Icon(Icons.image_not_supported);
                                  },
                                ),
                              )
                            : const Icon(Icons.shopping_bag),
                        title: Text(p.nome),
                        subtitle: Text('R\$ ${p.preco.toStringAsFixed(2)} • ${p.categoria}'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) => EmpresaProdutoDetalhesScreen(produto: p),
                            ),
                          );
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await _produtoService.deletarProduto(p.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Produto excluído'), backgroundColor: Colors.red),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}



