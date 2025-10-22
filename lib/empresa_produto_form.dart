import 'package:flutter/material.dart';
import 'services/produto_service.dart';
import 'services/auth_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'dart:async';

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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_editingProduto == null ? 'Cadastrar Produto' : 'Editar Produto'),
          backgroundColor: Colors.red.shade700,
          foregroundColor: Colors.white,
          bottom: const TabBar(tabs: [
            Tab(text: 'Dados'),
            Tab(text: 'Descrição'),
            Tab(text: 'Fotos'),
          ]),
        ),
        body: SafeArea(
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
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _onSalvar,
                      icon: const Icon(Icons.save),
                      label: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(_editingProduto == null ? 'Salvar produto' : 'Salvar alterações'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDadosTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nomeController,
            decoration: const InputDecoration(
              labelText: 'Nome do produto',
              border: OutlineInputBorder(),
            ),
            validator: (String? v) {
              if (v == null || v.trim().isEmpty) return 'Informe o nome';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _precoController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Preço (ex: 19.90)',
              border: OutlineInputBorder(),
            ),
            validator: (String? v) {
              if (v == null || v.trim().isEmpty) return 'Informe o preço';
              final double? val = double.tryParse(v.replaceAll(',', '.'));
              if (val == null) return 'Preço inválido';
              if (val < 0) return 'Preço deve ser positivo';
              return null;
            },
          ),
          const SizedBox(height: 16),
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Categoria',
              border: OutlineInputBorder(),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _categoria,
                items: _categorias
                    .map((String c) => DropdownMenuItem<String>(value: c, child: Text(c)))
                    .toList(),
                onChanged: (String? v) => setState(() => _categoria = v ?? _categoria),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescricaoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _descricaoController,
            maxLines: 8,
            decoration: const InputDecoration(
              labelText: 'Descrição do produto',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFotosTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Até 4 fotos', style: Theme.of(context).textTheme.bodyLarge),
              TextButton.icon(
                onPressed: (_imageBytesList.length + _existingImageUrls.length) >= 4 ? null : _pickImages,
                icon: const Icon(Icons.add_a_photo),
                label: const Text('Adicionar'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 4 / 3,
            ),
            itemBuilder: (BuildContext context, int index) {
              final bool showExisting = index < _existingImageUrls.length;
              final bool showNew = !showExisting && (index - _existingImageUrls.length) < _imageBytesList.length;
              if (!showExisting && !showNew) {
                return InkWell(
                  onTap: (_imageBytesList.length + _existingImageUrls.length) >= 4 ? null : _pickImages,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Center(
                      child: Icon(Icons.add_photo_alternate, color: Colors.grey, size: 32),
                    ),
                  ),
                );
              }
              return Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        color: Colors.white,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: showExisting
                              ? Image.network(_existingImageUrls[index])
                              : Image.memory(_imageBytesList[index - _existingImageUrls.length]),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: InkWell(
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
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
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


