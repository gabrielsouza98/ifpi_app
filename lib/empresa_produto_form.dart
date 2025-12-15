import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'services/produto_service.dart';
import 'services/auth_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'dart:async';
import 'theme/premium_theme.dart';
import 'widgets/premium_button.dart';
import 'widgets/premium_background.dart';

class EmpresaProdutoFormScreen extends StatefulWidget {
  const EmpresaProdutoFormScreen({super.key, this.produto});

  final Produto? produto;

  @override
  State<EmpresaProdutoFormScreen> createState() => _EmpresaProdutoFormScreenState();
}

class _EmpresaProdutoFormScreenState extends State<EmpresaProdutoFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  String _categoria = 'alimentos';
  Produto? _editingProduto;

  final ProdutoService _produtoService = ProdutoService();
  final AuthService _authService = AuthService();
  bool _isSaving = false;
  final List<Uint8List> _imageBytesList = <Uint8List>[];
  final List<String> _imageFileNames = <String>[];
  final List<String> _existingImageUrls = <String>[]; // imagens já salvas

  final List<String> _categorias = <String>[
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

  @override
  void initState() {
    super.initState();
    _editingProduto = widget.produto;
    if (_editingProduto != null) {
      _nomeController.text = _editingProduto!.nome;
      _precoController.text = _editingProduto!.preco.toStringAsFixed(2);
      _categoria = _editingProduto!.categoria;
      _descricaoController.text = _editingProduto!.descricao ?? '';
      final List<String> urls = _editingProduto!.imagensUrls.isNotEmpty
          ? _editingProduto!.imagensUrls
          : (_editingProduto!.imagemUrl != null && _editingProduto!.imagemUrl!.isNotEmpty
              ? <String>[_editingProduto!.imagemUrl!]
              : <String>[]);
      _existingImageUrls.addAll(urls.take(4));
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _precoController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = PremiumTheme.getTextPrimary(isDark);
    final backgroundColor = PremiumTheme.getBackgroundColor(isDark);
    
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: Text(
            _editingProduto == null ? 'Cadastrar Produto' : 'Editar Produto',
            style: PremiumTheme.titleLarge.copyWith(color: textPrimary),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  gradient: PremiumTheme.accentGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: PremiumTheme.getTextSecondary(isDark),
                tabs: const [
                  Tab(text: 'Dados'),
                  Tab(text: 'Descrição'),
                  Tab(text: 'Fotos'),
                ],
              ),
            ),
          ),
        ),
        body: PremiumBackground(
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: TabBarView(children: [
                      _buildDadosTab(),
                      _buildDescricaoTab(),
                      _buildFotosTab(context),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: PremiumButton(
                      label: _editingProduto == null ? 'Salvar produto' : 'Salvar alterações',
                      icon: Icons.save_rounded,
                      gradient: PremiumTheme.accentGradient,
                      isLoading: _isSaving,
                      onPressed: _onSalvar,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDadosTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = PremiumTheme.getTextPrimary(isDark);
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: PremiumTheme.glassmorphism(borderRadius: 24, context: context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nomeController,
                  style: TextStyle(color: textPrimary),
                  decoration: PremiumTheme.premiumInput(
                    label: 'Nome do produto',
                    prefixIcon: Icons.shopping_bag_rounded,
                    context: context,
                  ),
                  validator: (String? v) {
                    if (v == null || v.trim().isEmpty) return 'Informe o nome';
                    return null;
                  },
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 200.ms)
                    .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 200.ms),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _precoController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: textPrimary),
                  decoration: PremiumTheme.premiumInput(
                    label: 'Preço (ex: 19.90)',
                    prefixIcon: Icons.attach_money_rounded,
                    context: context,
                  ),
                  validator: (String? v) {
                    if (v == null || v.trim().isEmpty) return 'Informe o preço';
                    final double? val = double.tryParse(v.replaceAll(',', '.'));
                    if (val == null) return 'Preço inválido';
                    if (val < 0) return 'Preço deve ser positivo';
                    return null;
                  },
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 300.ms)
                    .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 300.ms),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
                      width: 1.5,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _categoria,
                      dropdownColor: PremiumTheme.getSurfaceColor(isDark),
                      style: TextStyle(color: textPrimary),
                      icon: Icon(Icons.keyboard_arrow_down_rounded,
                          color: PremiumTheme.getTextSecondary(isDark)),
                      items: _categorias
                          .map((String c) => DropdownMenuItem<String>(
                                value: c,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    c,
                                    style: PremiumTheme.bodyMedium,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (String? v) => setState(() => _categoria = v ?? _categoria),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 400.ms)
                    .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 400.ms),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 100.ms)
              .scale(delay: 100.ms, duration: 600.ms, begin: const Offset(0.95, 0.95)),
        ],
      ),
    );
  }

  Widget _buildDescricaoTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = PremiumTheme.getTextPrimary(isDark);
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: PremiumTheme.glassmorphism(borderRadius: 24, context: context),
            child: TextFormField(
              controller: _descricaoController,
              maxLines: 12,
              style: TextStyle(color: textPrimary),
              decoration: PremiumTheme.premiumInput(
                label: 'Descrição do produto',
                prefixIcon: Icons.description_rounded,
                context: context,
              ).copyWith(
                alignLabelWithHint: true,
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .scale(delay: 200.ms, duration: 600.ms, begin: const Offset(0.95, 0.95)),
        ],
      ),
    );
  }

  Widget _buildFotosTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = PremiumTheme.getTextPrimary(isDark);
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: PremiumTheme.glassmorphism(borderRadius: 24, context: context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Imagens do produto',
                      style: PremiumTheme.titleLarge.copyWith(
                        color: textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: PremiumTheme.accentGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_imageBytesList.length + _existingImageUrls.length}/4',
                        style: PremiumTheme.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    final bool showExisting = index < _existingImageUrls.length;
                    final bool showNew = !showExisting &&
                        (index - _existingImageUrls.length) < _imageBytesList.length;
                    if (!showExisting && !showNew) {
                      return GestureDetector(
                        onTap: (_imageBytesList.length + _existingImageUrls.length) >= 4
                            ? null
                            : _pickImages,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_rounded,
                                size: 40,
                                color: PremiumTheme.getTextSecondary(isDark),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Adicionar',
                                style: PremiumTheme.bodySmall.copyWith(
                                  color: PremiumTheme.getTextTertiary(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              color: PremiumTheme.getSurfaceColor(isDark),
                              child: showExisting
                                  ? Image.network(
                                      _existingImageUrls[index],
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
                                      errorBuilder: (context, error, stackTrace) {
                                        final isDark = Theme.of(context).brightness == Brightness.dark;
                                        return Icon(
                                          Icons.image_not_supported_rounded,
                                          size: 32,
                                          color: PremiumTheme.getTextTertiary(isDark),
                                        );
                                      },
                                    )
                                  : Image.memory(
                                      _imageBytesList[index - _existingImageUrls.length],
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (showExisting) {
                                  _existingImageUrls.removeAt(index);
                                } else {
                                  final int newIdx = index - _existingImageUrls.length;
                                  _imageBytesList.removeAt(newIdx);
                                  _imageFileNames.removeAt(newIdx);
                                }
                              });
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    PremiumTheme.errorColor,
                                    PremiumTheme.errorColor.withOpacity(0.8),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: PremiumTheme.errorColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                if ((_imageBytesList.length + _existingImageUrls.length) < 4) ...[
                  const SizedBox(height: 20),
                  PremiumButton(
                    label: 'Adicionar imagens',
                    icon: Icons.add_photo_alternate_rounded,
                    gradient: PremiumTheme.accentGradient,
                    onPressed: _pickImages,
                  ),
                ],
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .scale(delay: 200.ms, duration: 600.ms, begin: const Offset(0.95, 0.95)),
        ],
      ),
    );
  }

  Future<void> _pickImages() async {
    final int remaining = 4 - (_imageBytesList.length + _existingImageUrls.length);
    if (remaining <= 0) return;
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
      allowMultiple: true,
    );
    if (result == null) return;
    final List<PlatformFile> files = result.files.where((PlatformFile f) => f.bytes != null).toList();
    if (files.isEmpty) return;
    final int maxBytes = 5 * 1024 * 1024; // 5MB
    final List<Uint8List> newBytes = <Uint8List>[];
    final List<String> newNames = <String>[];
    for (final PlatformFile f in files) {
      if (newBytes.length >= remaining) break;
      final Uint8List b = f.bytes!;
      if (b.lengthInBytes > maxBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Imagem ${f.name} maior que 5MB'), backgroundColor: Colors.orange),
          );
        }
        continue;
      }
      newBytes.add(b);
      newNames.add(f.name);
    }
    if (newBytes.isEmpty) return;
    setState(() {
      _imageBytesList.addAll(newBytes);
      _imageFileNames.addAll(newNames);
      if (_imageBytesList.length > 4) {
        _imageBytesList.removeRange(4, _imageBytesList.length);
        _imageFileNames.removeRange(4, _imageFileNames.length);
      }
    });
  }

  Future<void> _onSalvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final String? empresaId = _authService.currentUser?.uid;
      if (empresaId == null) {
        throw Exception('Usuário não autenticado');
      }
      final double preco = double.parse(_precoController.text.replaceAll(',', '.'));
      List<String> imagensUrls = <String>[];
      imagensUrls.addAll(_existingImageUrls);
      if (_imageBytesList.isNotEmpty) {
        for (int i = 0; i < _imageBytesList.length; i++) {
          final String rawName = _imageFileNames[i];
          final String nameLower = rawName.toLowerCase();
          String ext = '.jpg';
          String contentType = 'image/jpeg';
          if (nameLower.endsWith('.png')) { ext = '.png'; contentType = 'image/png'; }
          if (nameLower.endsWith('.webp')) { ext = '.webp'; contentType = 'image/webp'; }
          final String uniqueName = 'prod_${DateTime.now().millisecondsSinceEpoch}_$i$ext';
          try {
            final String url = await _produtoService.uploadImagemProduto(
              empresaId: empresaId,
              fileName: uniqueName,
              bytes: _imageBytesList[i],
              contentType: contentType,
            );
            imagensUrls.add(url);
          } on TimeoutException {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Upload demorou demais. Tente novamente.'), backgroundColor: Colors.red),
              );
            }
            return;
          }
        }
      }
      if (_editingProduto == null) {
        await _produtoService.criarProduto(
          Produto(
            id: '',
            nome: _nomeController.text.trim(),
            preco: preco,
            categoria: _categoria,
            empresaId: empresaId,
            criadoEm: DateTime.now(),
            imagemUrl: imagensUrls.isNotEmpty ? imagensUrls.first : null,
            descricao: _descricaoController.text.trim().isEmpty ? null : _descricaoController.text.trim(),
            imagensUrls: imagensUrls,
          ),
        );
      } else {
        await _produtoService.atualizarProduto(
          Produto(
            id: _editingProduto!.id,
            nome: _nomeController.text.trim(),
            preco: preco,
            categoria: _categoria,
            empresaId: _editingProduto!.empresaId,
            criadoEm: _editingProduto!.criadoEm,
            imagemUrl: imagensUrls.isNotEmpty ? imagensUrls.first : null,
            descricao: _descricaoController.text.trim().isEmpty ? null : _descricaoController.text.trim(),
            imagensUrls: imagensUrls,
          ),
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto cadastrado!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showImagePreviewAt(int index) {
    if (index < 0 || index >= _imageBytesList.length) return;
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 5,
                child: Center(
                  child: Image.memory(
                    _imageBytesList[index],
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


