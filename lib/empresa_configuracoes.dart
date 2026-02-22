import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/geocoding_service.dart';
import 'services/theme_service.dart';
import 'theme/premium_theme.dart';
import 'widgets/premium_button.dart';
import 'widgets/premium_background.dart';

class EmpresaConfiguracoesScreen extends StatefulWidget {
  const EmpresaConfiguracoesScreen({super.key});

  @override
  State<EmpresaConfiguracoesScreen> createState() => _EmpresaConfiguracoesScreenState();
}

class _EmpresaConfiguracoesScreenState extends State<EmpresaConfiguracoesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _enderecoController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _buscandoEndereco = false;
  List<Map<String, dynamic>> _sugestoesEndereco = [];
  double? _latitude;
  double? _longitude;
  String? _enderecoCompleto;
  String? _temaAtual;
  Map<String, dynamic>? _empresaData;

  @override
  void initState() {
    super.initState();
    _carregarDadosEmpresa();
  }

  @override
  void dispose() {
    _enderecoController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _carregarDadosEmpresa() async {
    setState(() => _isLoading = true);
    try {
      _empresaData = await _authService.getUserData();
      if (_empresaData != null) {
        _enderecoController.text = _empresaData!['endereco'] ?? '';
        _whatsappController.text = _empresaData!['whatsapp'] ?? '';
        _latitude = _empresaData!['latitude']?.toDouble();
        _longitude = _empresaData!['longitude']?.toDouble();
        _enderecoCompleto = _empresaData!['endereco'];
        _temaAtual = _empresaData!['tema'] ?? 'dark';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: ${e.toString()}'),
            backgroundColor: PremiumTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
          _sugestoesEndereco = [];
        });
      }
    }
  }

  Future<void> _selecionarEndereco(String placeId, String description) async {
    setState(() {
      _enderecoController.text = description;
      _sugestoesEndereco = [];
    });

    try {
      final coordenadas = await GeocodingService.obterCoordenadas(placeId);
      if (coordenadas != null && mounted) {
        setState(() {
          _latitude = coordenadas['latitude'];
          _longitude = coordenadas['longitude'];
          _enderecoCompleto = description;
        });
      }
    } catch (e) {
      // Erro silencioso
    }
  }

  Future<void> _salvarConfiguracoes() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_enderecoController.text.isNotEmpty && (_latitude == null || _longitude == null)) {
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

    setState(() => _isLoading = true);

    try {
      final whatsappLimpo = _whatsappController.text.replaceAll(RegExp(r'[^0-9]'), '');
      
      await _authService.atualizarDadosEmpresa(
        endereco: _enderecoController.text.isNotEmpty
            ? (_enderecoCompleto ?? _enderecoController.text.trim())
            : null,
        latitude: _latitude,
        longitude: _longitude,
        tema: _temaAtual,
        whatsapp: whatsappLimpo.isNotEmpty ? whatsappLimpo : null,
      );

      // Atualizar tema via ThemeService
      if (_temaAtual != null) {
        final themeService = Provider.of<ThemeService>(context, listen: false);
        await themeService.updateTheme(_temaAtual!, userType: 'empresa');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Configurações salvas com sucesso'),
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
            content: Text('Erro ao salvar: ${e.toString()}'),
            backgroundColor: PremiumTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
          'Configurações',
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
          child: _isLoading && _empresaData == null
              ? Center(
                  child: CircularProgressIndicator(
                    color: PremiumTheme.primaryColor,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Card de Configurações
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: PremiumTheme.glassmorphism(context: context),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Título
                              Text(
                                'Configurações da Empresa',
                                style: PremiumTheme.headlineSmall.copyWith(color: textPrimary),
                                textAlign: TextAlign.center,
                              )
                                  .animate()
                                  .fadeIn(duration: 500.ms, delay: 200.ms)
                                  .slideY(begin: -0.1, end: 0, duration: 500.ms, delay: 200.ms),
                              
                              const SizedBox(height: 32),
                              
                              // Campo Endereço
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Endereço',
                                    style: PremiumTheme.bodyMedium.copyWith(
                                      color: textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _enderecoController,
                                    style: TextStyle(color: textPrimary),
                                    decoration: PremiumTheme.premiumInput(
                                      label: 'Endereço da empresa',
                                      prefixIcon: Icons.location_on_rounded,
                                      hintText: 'Digite o endereço para buscar...',
                                      context: context,
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
                                          : _enderecoController.text.isNotEmpty &&
                                                  _latitude != null &&
                                                  _longitude != null
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
                                      if (value != null && value.isNotEmpty) {
                                        if (_latitude == null || _longitude == null) {
                                          return 'Selecione um endereço da lista';
                                        }
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
                                  if (_latitude != null &&
                                      _longitude != null &&
                                      _enderecoCompleto != null)
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
                                  .fadeIn(duration: 500.ms, delay: 400.ms)
                                  .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 400.ms),
                              
                              const SizedBox(height: 32),
                              
                              // Campo WhatsApp
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'WhatsApp',
                                    style: PremiumTheme.bodyMedium.copyWith(
                                      color: textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _whatsappController,
                                    keyboardType: TextInputType.phone,
                                    style: TextStyle(color: textPrimary),
                                    decoration: PremiumTheme.premiumInput(
                                      label: 'Número do WhatsApp',
                                      prefixIcon: Icons.phone_rounded,
                                      hintText: 'Ex: 86999999999',
                                      context: context,
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(11),
                                    ],
                                    validator: (value) {
                                      if (value != null && value.isNotEmpty) {
                                        final apenasNumeros = value.replaceAll(RegExp(r'[^0-9]'), '');
                                        if (apenasNumeros.length < 10 || apenasNumeros.length > 11) {
                                          return 'Número inválido (deve ter 10 ou 11 dígitos)';
                                        }
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              )
                                  .animate()
                                  .fadeIn(duration: 500.ms, delay: 500.ms)
                                  .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 500.ms),
                              
                              const SizedBox(height: 32),
                              
                              // Modo Escuro/Claro
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tema',
                                    style: PremiumTheme.bodyMedium.copyWith(
                                      color: textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    decoration: PremiumTheme.glassmorphism(borderRadius: 16, context: context),
                                    padding: const EdgeInsets.all(4),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _temaAtual = 'dark';
                                              });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                gradient: _temaAtual == 'dark'
                                                    ? PremiumTheme.primaryGradient
                                                    : null,
                                                color: _temaAtual == 'dark'
                                                    ? null
                                                    : Colors.transparent,
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.dark_mode_rounded,
                                                    color: _temaAtual == 'dark'
                                                        ? Colors.white
                                                        : PremiumTheme.getTextSecondary(isDark),
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Escuro',
                                                    style: PremiumTheme.bodyMedium.copyWith(
                                                      color: _temaAtual == 'dark'
                                                          ? Colors.white
                                                          : PremiumTheme.getTextSecondary(isDark),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _temaAtual = 'light';
                                              });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                gradient: _temaAtual == 'light'
                                                    ? PremiumTheme.primaryGradient
                                                    : null,
                                                color: _temaAtual == 'light'
                                                    ? null
                                                    : Colors.transparent,
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.light_mode_rounded,
                                                    color: _temaAtual == 'light'
                                                        ? Colors.white
                                                        : PremiumTheme.getTextSecondary(isDark),
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Claro',
                                                    style: PremiumTheme.bodyMedium.copyWith(
                                                      color: _temaAtual == 'light'
                                                          ? Colors.white
                                                          : PremiumTheme.getTextSecondary(isDark),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                                  .animate()
                                  .fadeIn(duration: 500.ms, delay: 700.ms)
                                  .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 700.ms),
                              
                              const SizedBox(height: 32),
                              
                              // Botão Salvar
                              PremiumButton(
                                label: 'Salvar Configurações',
                                icon: Icons.save_rounded,
                                gradient: PremiumTheme.accentGradient,
                                isLoading: _isLoading,
                                onPressed: _salvarConfiguracoes,
                              )
                                  .animate()
                                  .fadeIn(duration: 500.ms, delay: 900.ms)
                                  .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 900.ms),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 200.ms)
                            .scale(delay: 200.ms, duration: 600.ms, begin: const Offset(0.95, 0.95)),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

