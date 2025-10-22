import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'services/produto_service.dart';
import 'usuario_produto_detalhes.dart';

// Dashboard do Usuário (Home com busca, categorias e lista de produtos)
class UsuarioDashboardScreen extends StatefulWidget {
  UsuarioDashboardScreen({super.key});

  @override
  State<UsuarioDashboardScreen> createState() => _UsuarioDashboardScreenState();
}

class _UsuarioDashboardScreenState extends State<UsuarioDashboardScreen> {
  final AuthService _authService = AuthService();
  final ProdutoService _produtoService = ProdutoService();

  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = <String>[
    'alimentos',
    'limpeza',
    'eletrônicos',
    'vestuário',
  ];

  String _selectedCategory = '';


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Descontaí'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.teal.shade300,
              Colors.teal.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá guest',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Encontre o seu preço',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSearchField(context),
                    const SizedBox(height: 12),
                    _buildCategoryChips(),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: StreamBuilder<List<Produto>>(
                    stream: _produtoService.streamProdutos(
                      categoria: _selectedCategory.isEmpty ? null : _selectedCategory,
                    ),
                    builder: (BuildContext context, AsyncSnapshot<List<Produto>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Erro ao carregar produtos'));
                      }
                      final List<Produto> itensAll = snapshot.data ?? <Produto>[];
                      final String q = _searchController.text.toLowerCase().trim();
                      final List<Produto> itens = q.isEmpty
                          ? itensAll
                          : itensAll.where((Produto p) => p.nome.toLowerCase().contains(q)).toList();
                      if (itens.isEmpty) {
                        return const Center(child: Text('Nenhum produto encontrado'));
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        itemCount: itens.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Produto item = itens[index];
                          return _buildProdutoCardFromModel(context, item);
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Pesquisar',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
            color: Colors.grey.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length + 1,
        separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 12),
        itemBuilder: (BuildContext context, int index) {
          final bool isAll = index == 0;
          final String label = isAll ? 'todas' : _categories[index - 1];
          final bool selected = isAll ? _selectedCategory.isEmpty : _selectedCategory == label;
          return ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (bool value) {
              setState(() {
                _selectedCategory = isAll ? '' : label;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, _ProductItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, size: 28, color: Colors.grey.shade800),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'R\$ ${item.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProdutoCardFromModel(BuildContext context, Produto item) {
    // Determinar a imagem principal (primeira de imagensUrls ou imagemUrl)
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: imagemPrincipal != null && imagemPrincipal.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imagemPrincipal,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.teal.shade500,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                          return Icon(Icons.image_not_supported, size: 24, color: Colors.grey.shade600);
                        },
                      ),
                    )
                  : Icon(Icons.shopping_bag, size: 28, color: Colors.grey.shade800),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nome,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'R\$ ${item.preco.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.teal.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.categoria,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  
}

class _ProductItem {
  _ProductItem({
    required this.name,
    required this.price,
    required this.category,
    required this.icon,
  });

  final String name;
  final double price;
  final String category;
  final IconData icon;
}

// Dashboard da Empresa
class EmpresaDashboardScreen extends StatelessWidget {
  EmpresaDashboardScreen({super.key});
  
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard - Empresa'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Remove o botão voltar
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context, 
                  '/', 
                  (route) => false
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red.shade100,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card de boas-vindas
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.red.shade200,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Icon(
                              Icons.business,
                              size: 30,
                              color: Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bem-vindo de volta!',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Empresa logada com sucesso',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Título das funcionalidades
                Text(
                  'Funcionalidades Disponíveis',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Grid de funcionalidades
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildFeatureCard(
                        context,
                        'Cadastrar Produto',
                        Icons.add_circle,
                        Colors.green,
                        () {
                          Navigator.pushNamed(context, '/empresa/produto/novo');
                        },
                      ),
                      _buildFeatureCard(
                        context,
                        'Meus Produtos',
                        Icons.inventory_2,
                        Colors.orange,
                        () {
                          Navigator.pushNamed(context, '/empresa/produtos');
                        },
                      ),
                      _buildFeatureCard(
                        context,
                        'Analytics',
                        Icons.analytics,
                        Colors.purple,
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Funcionalidade em desenvolvimento'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        context,
                        'Configurações',
                        Icons.settings,
                        Colors.teal,
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Funcionalidade em desenvolvimento'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
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
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                icon,
                size: 25,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
