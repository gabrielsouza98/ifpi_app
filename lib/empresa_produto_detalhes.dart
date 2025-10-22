import 'package:flutter/material.dart';
import 'services/produto_service.dart';

class EmpresaProdutoDetalhesScreen extends StatelessWidget {
  const EmpresaProdutoDetalhesScreen({super.key, required this.produto});

  final Produto produto;

  List<String> _buildImageList(Produto p) {
    if (p.imagensUrls.isNotEmpty) return p.imagensUrls;
    if (p.imagemUrl != null && p.imagemUrl!.isNotEmpty) return <String>[p.imagemUrl!];
    return const <String>[];
  }

  @override
  Widget build(BuildContext context) {
    final List<String> imagens = _buildImageList(produto);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Produto'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.of(context).pushNamed('/produto/editar', arguments: produto);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Galeria de imagens principal
            if (imagens.isNotEmpty)
              _Galeria(imagens: imagens)
            else
              Container(
                height: 250,
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Sem imagens', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            
            // Informações do produto
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome do produto em destaque
                  Text(
                    produto.nome,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Preço em destaque
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Text(
                      'R\$ ${produto.preco.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Categoria
                  Row(
                    children: [
                      Icon(Icons.category, size: 20, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Categoria: ',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        produto.categoria,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Descrição
                  Text(
                    'Descrição',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      (produto.descricao == null || produto.descricao!.trim().isEmpty)
                          ? 'Este produto não possui descrição.'
                          : produto.descricao!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Botão de exclusão
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        final bool? confirmar = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Excluir produto?'),
                              content: const Text('Esta ação não pode ser desfeita.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false), 
                                  child: const Text('Cancelar')
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true), 
                                  child: const Text('Excluir')
                                ),
                              ],
                            );
                          },
                        );
                        if (confirmar == true) {
                          await ProdutoService().deletarProduto(produto.id);
                          if (context.mounted) Navigator.pop(context);
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.delete),
                      label: const Text('Excluir produto'),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Imagem principal
          Container(
            height: 250,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: widget.imagens.length,
                    onPageChanged: (int i) => setState(() => _index = i),
                    itemBuilder: (BuildContext context, int i) {
                      return Container(
                        color: Colors.grey.shade100,
                        child: Image.network(
                          widget.imagens[i],
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Colors.red.shade700,
                              ),
                            );
                          },
                          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('Erro ao carregar imagem', style: TextStyle(color: Colors.grey)),
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
                      left: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: _previousImage,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chevron_left,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Botão próximo
                    Positioned(
                      right: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: _nextImage,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                              size: 24,
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
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Contador de imagens
                Text(
                  '${_index + 1} de ${widget.imagens.length}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                // Indicadores
                Row(
                  children: List<Widget>.generate(widget.imagens.length, (int i) {
                    final bool active = i == _index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active ? Colors.red.shade700 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
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


