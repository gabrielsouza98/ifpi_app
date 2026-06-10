import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final GoogleSignIn _googleSignIn = kIsWeb
      ? GoogleSignIn(
          scopes: const ['email', 'profile'],
        )
      : GoogleSignIn(
          scopes: const ['email', 'profile'],
          serverClientId:
              '560636982577-fqbtomhsojqde2lf7ild99gohbef1qmq.apps.googleusercontent.com',
        );

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInUsuario(String email, String password) async {
    var stage = 'inicio';
    try {
      debugPrint('[AuthService][usuario] Iniciando autenticacao para $email');

      stage = 'App Check token';
      await _checkAppCheckToken('usuario');

      stage = 'FirebaseAuth.signInWithEmailAndPassword';
      final authResult = await _runAuthStep(
        'usuario',
        stage,
        () => _auth
            .signInWithEmailAndPassword(
              email: email,
              password: password,
            ),
        timeout: const Duration(seconds: 60),
      );
      debugPrint('[AuthService][usuario] FirebaseAuth OK uid=${authResult.user?.uid}');

      stage = 'Firestore get usuarios/${authResult.user!.uid}';
      final userDoc = await _runAuthStep(
        'usuario',
        stage,
        () => _firestore
            .collection('usuarios')
            .doc(authResult.user!.uid)
            .get(),
        timeout: const Duration(seconds: 20),
      );
      debugPrint('[AuthService][usuario] Firestore usuarios.exists=${userDoc.exists}');

      if (!userDoc.exists) {
        await _auth.signOut();
        throw Exception('Usuario nao encontrado na base de usuarios');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      if (userData['tipo'] != 'usuario') {
        await _auth.signOut();
        throw Exception('Este login e apenas para usuarios');
      }

      return authResult;
    } on TimeoutException catch (e, stackTrace) {
      _logAuthFailure('usuario', stage, e, stackTrace);
      final restDiagnostic = await _diagnoseFirebaseAuthRestSignIn(
        email: email,
        password: password,
      );
      throw 'Timeout na etapa "$stage". O app ficou aguardando resposta do Firebase nessa etapa. $restDiagnostic';
    } on FirebaseAuthException catch (e, stackTrace) {
      _logAuthFailure('usuario', stage, e, stackTrace);
      throw _diagnosticFirebaseAuthException(stage, e);
    } on FirebaseException catch (e, stackTrace) {
      _logAuthFailure('usuario', stage, e, stackTrace);
      throw _diagnosticFirebaseException(stage, e);
    } on PlatformException catch (e, stackTrace) {
      _logAuthFailure('usuario', stage, e, stackTrace);
      throw _diagnosticPlatformException(stage, e);
    } catch (e, stackTrace) {
      _logAuthFailure('usuario', stage, e, stackTrace);
      throw 'Erro na etapa "$stage": $e';
    }
  }

  Future<UserCredential?> signInEmpresa(String email, String password) async {
    var stage = 'inicio';
    try {
      debugPrint('[AuthService][empresa] Iniciando autenticacao para $email');

      stage = 'App Check token';
      await _checkAppCheckToken('empresa');

      stage = 'FirebaseAuth.signInWithEmailAndPassword';
      final authResult = await _runAuthStep(
        'empresa',
        stage,
        () => _auth
            .signInWithEmailAndPassword(
              email: email,
              password: password,
            ),
        timeout: const Duration(seconds: 60),
      );
      debugPrint('[AuthService][empresa] FirebaseAuth OK uid=${authResult.user?.uid}');

      stage = 'Firestore get empresas/${authResult.user!.uid}';
      final userDoc = await _runAuthStep(
        'empresa',
        stage,
        () => _firestore
            .collection('empresas')
            .doc(authResult.user!.uid)
            .get(),
        timeout: const Duration(seconds: 20),
      );
      debugPrint('[AuthService][empresa] Firestore empresas.exists=${userDoc.exists}');

      if (!userDoc.exists) {
        await _auth.signOut();
        throw Exception('Empresa nao encontrada na base de empresas');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      if (userData['tipo'] != 'empresa') {
        await _auth.signOut();
        throw Exception('Este login e apenas para empresas');
      }

      return authResult;
    } on TimeoutException catch (e, stackTrace) {
      _logAuthFailure('empresa', stage, e, stackTrace);
      final restDiagnostic = await _diagnoseFirebaseAuthRestSignIn(
        email: email,
        password: password,
      );
      throw 'Timeout na etapa "$stage". O app ficou aguardando resposta do Firebase nessa etapa. $restDiagnostic';
    } on FirebaseAuthException catch (e, stackTrace) {
      _logAuthFailure('empresa', stage, e, stackTrace);
      throw _diagnosticFirebaseAuthException(stage, e);
    } on FirebaseException catch (e, stackTrace) {
      _logAuthFailure('empresa', stage, e, stackTrace);
      throw _diagnosticFirebaseException(stage, e);
    } on PlatformException catch (e, stackTrace) {
      _logAuthFailure('empresa', stage, e, stackTrace);
      throw _diagnosticPlatformException(stage, e);
    } catch (e, stackTrace) {
      _logAuthFailure('empresa', stage, e, stackTrace);
      throw 'Erro na etapa "$stage": $e';
    }
  }

  Future<UserCredential?> signUpUsuario({
    required String nome,
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('usuarios').doc(result.user!.uid).set({
        'nome': nome,
        'email': email,
        'tipo': 'usuario',
        'dataCriacao': FieldValue.serverTimestamp(),
        'ativo': true,
      });

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential?> signUpEmpresa({
    required String nomeEmpresa,
    required String cnpj,
    required String email,
    required String password,
    required String whatsapp,
    required String endereco,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final empresaData = <String, dynamic>{
        'nomeEmpresa': nomeEmpresa,
        'email': email,
        'whatsapp': whatsapp,
        'endereco': endereco,
        'latitude': latitude,
        'longitude': longitude,
        'tipo': 'empresa',
        'dataCriacao': FieldValue.serverTimestamp(),
        'ativo': true,
      };

      if (cnpj.isNotEmpty) {
        empresaData['cnpj'] = cnpj;
      }

      await _firestore.collection('empresas').doc(result.user!.uid).set(empresaData);

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> atualizarDadosEmpresa({
    String? endereco,
    double? latitude,
    double? longitude,
    String? tema,
    String? whatsapp,
  }) async {
    if (currentUser == null) {
      throw Exception('Usuario nao autenticado');
    }

    try {
      final updateData = <String, dynamic>{};

      if (endereco != null) updateData['endereco'] = endereco;
      if (latitude != null) updateData['latitude'] = latitude;
      if (longitude != null) updateData['longitude'] = longitude;
      if (tema != null) updateData['tema'] = tema;
      if (whatsapp != null) updateData['whatsapp'] = whatsapp;

      if (updateData.isNotEmpty) {
        await _firestore
            .collection('empresas')
            .doc(currentUser!.uid)
            .update(updateData);
      }
    } catch (_) {
      throw Exception('Nao foi possivel atualizar os dados da empresa. Tente novamente em alguns instantes.');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
  }

  Future<UserCredential?> signInWithGoogleUsuario() async {
    try {
      final result = await _signInWithGoogle();
      if (result == null) return null;

      final userDoc = await _firestore
          .collection('usuarios')
          .doc(result.user!.uid)
          .get()
          .timeout(const Duration(seconds: 15));

      if (!userDoc.exists) {
        await _firestore
            .collection('usuarios')
            .doc(result.user!.uid)
            .set({
              'nome': result.user!.displayName ?? 'Usuario Google',
              'email': result.user!.email,
              'tipo': 'usuario',
              'dataCriacao': FieldValue.serverTimestamp(),
              'ativo': true,
              'fotoUrl': result.user!.photoURL,
            })
            .timeout(const Duration(seconds: 15));
      } else {
        final userData = userDoc.data() as Map<String, dynamic>;
        if (userData['tipo'] != 'usuario') {
          await _auth.signOut();
          await _clearGoogleSession();
          throw Exception('Este login e apenas para usuarios');
        }
      }

      return result;
    } on TimeoutException {
      await _clearGoogleSession();
      throw Exception(
        'A conexao demorou muito para responder durante o login com Google. '
        'Verifique sua internet, o Google Play Services e as configuracoes do Firebase para Android.',
      );
    } on FirebaseAuthException catch (e) {
      await _clearGoogleSession();
      throw Exception(_handleAuthException(e));
    } on PlatformException catch (e) {
      await _clearGoogleSession();
      throw Exception(_handleGoogleSignInException(e));
    } on FirebaseException catch (e) {
      await _clearGoogleSession();
      throw Exception('Nao foi possivel salvar ou validar a conta no servidor (${e.code}).');
    } catch (e) {
      await _clearGoogleSession();
      throw Exception('Nao foi possivel concluir o login com Google. Detalhes: $e');
    }
  }

  Future<UserCredential?> signInWithGoogleEmpresa() async {
    try {
      final result = await _signInWithGoogle();
      if (result == null) return null;

      final userDoc = await _firestore
          .collection('empresas')
          .doc(result.user!.uid)
          .get()
          .timeout(const Duration(seconds: 15));

      if (!userDoc.exists) {
        await _firestore
            .collection('empresas')
            .doc(result.user!.uid)
            .set({
              'nomeEmpresa': result.user!.displayName ?? 'Empresa Google',
              'email': result.user!.email,
              'tipo': 'empresa',
              'dataCriacao': FieldValue.serverTimestamp(),
              'ativo': true,
              'fotoUrl': result.user!.photoURL,
            })
            .timeout(const Duration(seconds: 15));
      } else {
        final userData = userDoc.data() as Map<String, dynamic>;
        if (userData['tipo'] != 'empresa') {
          await _auth.signOut();
          await _clearGoogleSession();
          throw Exception('Este login e apenas para empresas');
        }
      }

      return result;
    } on TimeoutException {
      await _clearGoogleSession();
      throw Exception(
        'A conexao demorou muito para responder durante o login com Google. '
        'Verifique sua internet, o Google Play Services e as configuracoes do Firebase para Android.',
      );
    } on FirebaseAuthException catch (e) {
      await _clearGoogleSession();
      throw Exception(_handleAuthException(e));
    } on PlatformException catch (e) {
      await _clearGoogleSession();
      throw Exception(_handleGoogleSignInException(e));
    } on FirebaseException catch (e) {
      await _clearGoogleSession();
      throw Exception('Nao foi possivel salvar ou validar a conta no servidor (${e.code}).');
    } catch (e) {
      await _clearGoogleSession();
      throw Exception('Nao foi possivel concluir o login com Google. Detalhes: $e');
    }
  }

  Future<UserCredential?> _signInWithGoogle() async {
    if (kIsWeb) {
      final googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      return _auth
          .signInWithPopup(googleProvider)
          .timeout(const Duration(seconds: 30));
    }

    final silentUser = await _googleSignIn
        .signInSilently()
        .timeout(const Duration(seconds: 8), onTimeout: () => null);
    final googleUser = silentUser ??
        await _googleSignIn.signIn().timeout(const Duration(seconds: 30));

    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication.timeout(
      const Duration(seconds: 15),
    );

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return _auth
        .signInWithCredential(credential)
        .timeout(const Duration(seconds: 20));
  }

  Future<void> _clearGoogleSession() async {
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
  }

  Future<bool> isUsuario() async {
    if (currentUser == null) return false;

    try {
      final userDoc = await _firestore
          .collection('usuarios')
          .doc(currentUser!.uid)
          .get()
          .timeout(const Duration(seconds: 10));
      return userDoc.exists;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isEmpresa() async {
    if (currentUser == null) return false;

    try {
      final userDoc = await _firestore
          .collection('empresas')
          .doc(currentUser!.uid)
          .get()
          .timeout(const Duration(seconds: 10));
      return userDoc.exists;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    if (currentUser == null) return null;

    final userDoc = await _firestore
        .collection('usuarios')
        .doc(currentUser!.uid)
        .get();

    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>;
    }

    final empresaDoc = await _firestore
        .collection('empresas')
        .doc(currentUser!.uid)
        .get();

    if (empresaDoc.exists) {
      return empresaDoc.data() as Map<String, dynamic>;
    }

    return null;
  }

  Future<Map<String, dynamic>?> getEmpresaData(String empresaId) async {
    try {
      final empresaDoc = await _firestore.collection('empresas').doc(empresaId).get();

      if (empresaDoc.exists) {
        return empresaDoc.data() as Map<String, dynamic>;
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _checkAppCheckToken(String scope) async {
    debugPrint(
      '[AuthService][$scope][App Check token] desativado temporariamente para diagnostico Android',
    );
  }

  Future<T> _runAuthStep<T>(
    String scope,
    String stage,
    Future<T> Function() action, {
    required Duration timeout,
  }) async {
    final stopwatch = Stopwatch()..start();
    debugPrint('[AuthService][$scope][$stage] inicio');

    try {
      final result = await action().timeout(timeout);
      debugPrint(
        '[AuthService][$scope][$stage] OK em ${stopwatch.elapsedMilliseconds}ms',
      );
      return result;
    } catch (e, stackTrace) {
      debugPrint(
        '[AuthService][$scope][$stage] ERRO em ${stopwatch.elapsedMilliseconds}ms: ${_describeError(e)}',
      );
      Error.throwWithStackTrace(e, stackTrace);
    }
  }

  void _logAuthFailure(
    String scope,
    String stage,
    Object error,
    StackTrace? stackTrace,
  ) {
    debugPrint('[AuthService][$scope][FALHA] etapa=$stage');
    debugPrint('[AuthService][$scope][FALHA] ${_describeError(error)}');
    if (stackTrace != null) {
      debugPrintStack(
        label: '[AuthService][$scope][FALHA] stack',
        stackTrace: stackTrace,
      );
    }
  }

  String _describeError(Object error) {
    if (error is FirebaseAuthException) {
      return 'FirebaseAuthException(code=${error.code}, plugin=${error.plugin}, message=${error.message})';
    }
    if (error is FirebaseException) {
      return 'FirebaseException(code=${error.code}, plugin=${error.plugin}, message=${error.message})';
    }
    if (error is PlatformException) {
      return 'PlatformException(code=${error.code}, message=${error.message}, details=${error.details})';
    }
    if (error is TimeoutException) {
      return 'TimeoutException(message=${error.message}, duration=${error.duration})';
    }
    return '${error.runtimeType}: $error';
  }

  Future<String> _diagnoseFirebaseAuthRestSignIn({
    required String email,
    required String password,
  }) async {
    if (kIsWeb) {
      return 'Diagnostico REST ignorado no Web.';
    }

    const stage = 'Diagnostico REST Identity Toolkit';
    debugPrint('[AuthService][diagnostico][$stage] inicio');

    try {
      final apiKey = Firebase.app().options.apiKey;
      final uri = Uri.https(
        'identitytoolkit.googleapis.com',
        '/v1/accounts:signInWithPassword',
        {'key': apiKey},
      );

      final response = await http
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
              'returnSecureToken': true,
            }),
          )
          .timeout(const Duration(seconds: 20));

      debugPrint(
        '[AuthService][diagnostico][$stage] status=${response.statusCode} body=${response.body}',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return 'Diagnostico REST: a API REST do Firebase Auth respondeu OK. Isso indica problema no SDK nativo/App Check/Google Play Services, nao na senha nem na API key.';
      }

      return 'Diagnostico REST: Firebase Auth HTTP ${response.statusCode}: ${response.body}';
    } on TimeoutException catch (e) {
      debugPrint('[AuthService][diagnostico][$stage] timeout: $e');
      return 'Diagnostico REST tambem deu timeout. Isso aponta para rede, DNS, bloqueio do aparelho/emulador ou servicos Google indisponiveis.';
    } catch (e) {
      debugPrint('[AuthService][diagnostico][$stage] erro: ${_describeError(e)}');
      return 'Diagnostico REST falhou antes de receber resposta: ${_describeError(e)}';
    }
  }

  String _diagnosticFirebaseAuthException(
    String stage,
    FirebaseAuthException e,
  ) {
    return 'Erro Firebase Auth na etapa "$stage"\n'
        'code: ${e.code}\n'
        'plugin: ${e.plugin}\n'
        'message: ${e.message ?? 'sem mensagem'}\n'
        'traducao: ${_handleAuthException(e)}';
  }

  String _diagnosticFirebaseException(String stage, FirebaseException e) {
    return 'Erro Firebase na etapa "$stage"\n'
        'code: ${e.code}\n'
        'plugin: ${e.plugin}\n'
        'message: ${e.message ?? 'sem mensagem'}';
  }

  String _diagnosticPlatformException(String stage, PlatformException e) {
    return 'Erro nativo Android na etapa "$stage"\n'
        'code: ${e.code}\n'
        'message: ${e.message ?? 'sem mensagem'}\n'
        'details: ${e.details ?? 'sem detalhes'}';
  }

  String _handleAuthException(FirebaseAuthException e) {
    final message = e.message?.toLowerCase() ?? '';

    if (message.contains('identitytoolkit') ||
        message.contains('signinwithpassword') ||
        message.contains('requests to this api') ||
        message.contains('are blocked')) {
      return 'O login foi bloqueado pela configuracao da chave do Firebase no Android. '
          'Verifique as restricoes da API key no Google Cloud/Firebase Console.';
    }

    switch (e.code) {
      case 'user-not-found':
        return 'Nenhum usuario encontrado com este email.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'email-already-in-use':
        return 'Este email ja esta sendo usado.';
      case 'weak-password':
        return 'A senha e muito fraca.';
      case 'invalid-email':
        return 'Email invalido.';
      case 'user-disabled':
        return 'Esta conta foi desabilitada.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      case 'operation-not-allowed':
        return 'Operacao nao permitida.';
      case 'invalid-credential':
      case 'invalid-verification-code':
      case 'invalid-verification-id':
        return 'Nao foi possivel validar a credencial de acesso. Tente fazer login novamente.';
      default:
        return 'Nao foi possivel concluir a autenticacao (${e.code}). Tente novamente em alguns instantes.';
    }
  }

  String _handleGoogleSignInException(PlatformException e) {
    final details = e.message ?? e.details?.toString() ?? '';

    if (e.code == 'sign_in_failed' || details.contains('ApiException: 10')) {
      return 'Falha na configuracao do Google Sign-In no Android. '
          'Confira se o package name e o SHA1/SHA256 do app estao cadastrados no Firebase.';
    }

    if (e.code == 'network_error') {
      return 'Nao foi possivel conectar ao Google para fazer login. Verifique sua internet.';
    }

    return 'Nao foi possivel abrir o Google Sign-In (${e.code}). $details';
  }
}
