import 'package:flutter/material.dart';

import 'auth_login_screens.dart';
import 'auth_screens.dart';
import 'dashboard_screens.dart';
import 'empresa_configuracoes.dart';
import 'empresa_meus_produtos.dart';
import 'empresa_produto_form.dart';
import 'home_landing_screen.dart';
import 'services/auth_service.dart';
import 'services/produto_service.dart';
import 'usuario_configuracoes.dart';

Map<String, WidgetBuilder> buildAppRoutes() {
  return <String, WidgetBuilder>{
    '/': (context) => const MyHomePage(title: 'Descontai'),
    '/usuario': (context) => const UsuarioLoginScreen(),
    '/empresa': (context) => const EmpresaLoginScreen(),
    '/usuario/criar-conta': (context) => const UsuarioCriarContaScreen(),
    '/empresa/criar-conta': (context) => const EmpresaCriarContaScreen(),
    '/usuario/esqueci-senha': (context) => const UsuarioEsqueciSenhaScreen(),
    '/empresa/esqueci-senha': (context) => const EmpresaEsqueciSenhaScreen(),
    '/usuario/dashboard': (context) => const _RoleGuard(
      role: _UserRole.usuario,
      child: UsuarioDashboardScreen(),
    ),
    '/empresa/dashboard': (context) => const _RoleGuard(
      role: _UserRole.empresa,
      child: EmpresaDashboardScreen(),
    ),
    '/empresa/produto/novo': (context) => const _RoleGuard(
      role: _UserRole.empresa,
      child: EmpresaProdutoFormScreen(),
    ),
    '/empresa/produtos': (context) => _RoleGuard(
      role: _UserRole.empresa,
      child: EmpresaMeusProdutosScreen(),
    ),
    '/empresa/analytics': (context) => _RoleGuard(
      role: _UserRole.empresa,
      child: EmpresaMeusProdutosScreen(
        apenasVisualizar: true,
        modoAnalytics: true,
      ),
    ),
    '/empresa/configuracoes': (context) => const _RoleGuard(
      role: _UserRole.empresa,
      child: EmpresaConfiguracoesScreen(),
    ),
    '/usuario/configuracoes': (context) => const _RoleGuard(
      role: _UserRole.usuario,
      child: UsuarioConfiguracoesScreen(),
    ),
    '/produto/editar': (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Produto) {
        return _RoleGuard(
          role: _UserRole.empresa,
          child: EmpresaProdutoFormScreen(produto: args),
        );
      }
      return const _RoleGuard(
        role: _UserRole.empresa,
        child: EmpresaProdutoFormScreen(),
      );
    },
  };
}

enum _UserRole { usuario, empresa }

class _RoleGuard extends StatefulWidget {
  const _RoleGuard({
    required this.role,
    required this.child,
  });

  final _UserRole role;
  final Widget child;

  @override
  State<_RoleGuard> createState() => _RoleGuardState();
}

class _RoleGuardState extends State<_RoleGuard> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _allowed = false;
  bool _redirected = false;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    try {
      if (_authService.currentUser == null) {
        _allowed = false;
      } else if (widget.role == _UserRole.usuario) {
        // Em release/produção a validação pode ficar bloqueada por App Check/Firestore.
        // Garantimos que o loading não fique infinito.
        _allowed = await _authService
            .isUsuario()
            .timeout(const Duration(seconds: 10));
      } else {
        _allowed = await _authService
            .isEmpresa()
            .timeout(const Duration(seconds: 10));
      }
    } catch (_) {
      _allowed = false;
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  void _redirectToHome() {
    if (_redirected || !mounted) return;
    _redirected = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_allowed) {
      _redirectToHome();
      return const Scaffold(
        body: SizedBox.shrink(),
      );
    }

    return widget.child;
  }
}
