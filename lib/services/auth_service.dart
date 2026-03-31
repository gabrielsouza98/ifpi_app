import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // No Web, não usar serverClientId (não suportado). Em mobile/desktop, manter configuração completa.
  late final GoogleSignIn _googleSignIn = kIsWeb
      ? GoogleSignIn(
          scopes: const ['email', 'profile'],
        )
      : GoogleSignIn(
          scopes: const ['email', 'profile'],
          // Cliente Web (type 3) do Firebase, usado para emitir o ID token
          // aceito pelo Firebase Auth no Android.
          serverClientId:
              '560636982577-fqbtomhsojqde2lf7ild99gohbef1qmq.apps.googleusercontent.com',
        );

  // Stream do usuário atual
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuário atual
  User? get currentUser => _auth.currentUser;

  // Login do usuário
  Future<UserCredential?> signInUsuario(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verificar se o usuário é do tipo "usuario"
      DocumentSnapshot userDoc = await _firestore
          .collection('usuarios')
          .doc(result.user!.uid)
          .get();

      if (!userDoc.exists) {
        // Se não existe na coleção de usuários, fazer logout
        await _auth.signOut();
        throw Exception('Usuário não encontrado na base de usuários');
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      if (userData['tipo'] != 'usuario') {
        await _auth.signOut();
        throw Exception('Este login é apenas para usuários');
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Login da empresa
  Future<UserCredential?> signInEmpresa(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verificar se o usuário é do tipo "empresa"
      DocumentSnapshot userDoc = await _firestore
          .collection('empresas')
          .doc(result.user!.uid)
          .get();

      if (!userDoc.exists) {
        // Se não existe na coleção de empresas, fazer logout
        await _auth.signOut();
        throw Exception('Empresa não encontrada na base de empresas');
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      if (userData['tipo'] != 'empresa') {
        await _auth.signOut();
        throw Exception('Este login é apenas para empresas');
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Registro do usuário
  Future<UserCredential?> signUpUsuario({
    required String nome,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Salvar dados do usuário no Firestore
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

  // Registro da empresa
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
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Salvar dados da empresa no Firestore
      Map<String, dynamic> empresaData = {
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
      
      // Adicionar CNPJ apenas se fornecido
      if (cnpj.isNotEmpty) {
        empresaData['cnpj'] = cnpj;
      }

      await _firestore.collection('empresas').doc(result.user!.uid).set(empresaData);

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // Atualizar dados da empresa
  Future<void> atualizarDadosEmpresa({
    String? endereco,
    double? latitude,
    double? longitude,
    String? tema, // 'dark' ou 'light'
    String? whatsapp,
  }) async {
    if (currentUser == null) {
      throw Exception('Usuário não autenticado');
    }

    try {
      Map<String, dynamic> updateData = {};
      
      if (endereco != null) {
        updateData['endereco'] = endereco;
      }
      if (latitude != null) {
        updateData['latitude'] = latitude;
      }
      if (longitude != null) {
        updateData['longitude'] = longitude;
      }
      if (tema != null) {
        updateData['tema'] = tema;
      }
      if (whatsapp != null) {
        updateData['whatsapp'] = whatsapp;
      }
      
      if (updateData.isNotEmpty) {
        await _firestore
            .collection('empresas')
            .doc(currentUser!.uid)
            .update(updateData);
      }
    } catch (e) {
      throw Exception('Não foi possível atualizar os dados da empresa. Tente novamente em alguns instantes.');
    }
  }

  // Recuperação de senha (genérico).
  // Importante: quando o usuário está deslogado, as regras do Firestore
  // não permitem fazer consultas para verificar tipo de conta.
  // Por isso, a validação é feita apenas pelo Firebase Auth:
  // - Se o email não existir em nenhuma conta -> Firebase retorna user-not-found.
  // - A mensagem exibida nas telas orienta o usuário sobre tipo de conta.
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
  }

  // Login com Google para Usuário
  Future<UserCredential?> signInWithGoogleUsuario() async {
    try {
      UserCredential result;

      if (kIsWeb) {
        // No Web, usar diretamente o Firebase Auth com o provedor Google,
        // pois o plugin google_sign_in para web está migrando para FedCM
        // e o método signIn tradicional é desaconselhado.
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');

        result = await _auth.signInWithPopup(googleProvider);
      } else {
        // Primeiro, tentar fazer login silencioso
        GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
        
        // Se não conseguir login silencioso, fazer login normal
        googleUser ??= await _googleSignIn.signIn();
        
        if (googleUser == null) {
          return null; // Usuário cancelou o login
        }

        // Obter os dados de autenticação do Google
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        // Criar credencial do Firebase a partir das credenciais do Google
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Login no Firebase com as credenciais do Google
        result = await _auth.signInWithCredential(credential);
      }

      // Verificar se o usuário já existe na coleção de usuários
      DocumentSnapshot userDoc = await _firestore
          .collection('usuarios')
          .doc(result.user!.uid)
          .get();

      if (!userDoc.exists) {
        // Se não existe, criar o documento do usuário
        await _firestore.collection('usuarios').doc(result.user!.uid).set({
          'nome': result.user!.displayName ?? 'Usuário Google',
          'email': result.user!.email,
          'tipo': 'usuario',
          'dataCriacao': FieldValue.serverTimestamp(),
          'ativo': true,
          'fotoUrl': result.user!.photoURL,
        });
      } else {
        // Verificar se é realmente um usuário
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        if (userData['tipo'] != 'usuario') {
          await _auth.signOut();
          if (!kIsWeb) {
            await _googleSignIn.signOut();
          }
          throw Exception('Este login é apenas para usuários');
        }
      }

      return result;
    } on FirebaseAuthException catch (e) {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      // Traduz erros do Firebase Auth para mensagens amigáveis em português
      throw Exception(_handleAuthException(e));
    } catch (e) {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      throw Exception('Não foi possível concluir o login com Google. Tente novamente em alguns instantes.');
    }
  }

  // Login com Google para Empresa
  Future<UserCredential?> signInWithGoogleEmpresa() async {
    try {
      UserCredential result;

      if (kIsWeb) {
        // No Web, usar diretamente o Firebase Auth com o provedor Google
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');

        result = await _auth.signInWithPopup(googleProvider);
      } else {
        // Primeiro, tentar fazer login silencioso
        GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
        
        // Se não conseguir login silencioso, fazer login normal
        googleUser ??= await _googleSignIn.signIn();
        
        if (googleUser == null) {
          return null; // Usuário cancelou o login
        }

        // Obter os dados de autenticação do Google
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        // Criar credencial do Firebase a partir das credenciais do Google
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Login no Firebase com as credenciais do Google
        result = await _auth.signInWithCredential(credential);
      }

      // Verificar se o usuário já existe na coleção de empresas
      DocumentSnapshot userDoc = await _firestore
          .collection('empresas')
          .doc(result.user!.uid)
          .get();

      if (!userDoc.exists) {
        // Se não existe, criar o documento da empresa
        await _firestore.collection('empresas').doc(result.user!.uid).set({
          'nomeEmpresa': result.user!.displayName ?? 'Empresa Google',
          'email': result.user!.email,
          'tipo': 'empresa',
          'dataCriacao': FieldValue.serverTimestamp(),
          'ativo': true,
          'fotoUrl': result.user!.photoURL,
        });
      } else {
        // Verificar se é realmente uma empresa
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        if (userData['tipo'] != 'empresa') {
          await _auth.signOut();
          if (!kIsWeb) {
            await _googleSignIn.signOut();
          }
          throw Exception('Este login é apenas para empresas');
        }
      }

      return result;
    } on FirebaseAuthException catch (e) {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      // Traduz erros do Firebase Auth para mensagens amigáveis em português
      throw Exception(_handleAuthException(e));
    } catch (e) {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      throw Exception('Não foi possível concluir o login com Google. Tente novamente em alguns instantes.');
    }
  }

  // Verificar se é usuário
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

  // Verificar se é empresa
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

  // Obter dados do usuário
  Future<Map<String, dynamic>?> getUserData() async {
    if (currentUser == null) return null;

    // Tentar buscar como usuário primeiro
    DocumentSnapshot userDoc = await _firestore
        .collection('usuarios')
        .doc(currentUser!.uid)
        .get();

    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>;
    }

    // Se não encontrou como usuário, tentar como empresa
    DocumentSnapshot empresaDoc = await _firestore
        .collection('empresas')
        .doc(currentUser!.uid)
        .get();

    if (empresaDoc.exists) {
      return empresaDoc.data() as Map<String, dynamic>;
    }

    return null;
  }

  // Obter dados da empresa pelo ID
  Future<Map<String, dynamic>?> getEmpresaData(String empresaId) async {
    try {
      DocumentSnapshot empresaDoc = await _firestore
          .collection('empresas')
          .doc(empresaId)
          .get();

      if (empresaDoc.exists) {
        return empresaDoc.data() as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Tratamento de exceções do Firebase Auth
  String _handleAuthException(FirebaseAuthException e) {
    final message = e.message?.toLowerCase() ?? '';

    if (message.contains('identitytoolkit')
        || message.contains('signinwithpassword')
        || message.contains('requests to this api')
        || message.contains('are blocked')) {
      return 'O login foi bloqueado pela configuracao da chave do Firebase no Android. '
          'Verifique as restricoes da API key no Google Cloud/Firebase Console.';
    }

    switch (e.code) {
      case 'user-not-found':
        return 'Nenhum usuário encontrado com este email.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'email-already-in-use':
        return 'Este email já está sendo usado.';
      case 'weak-password':
        return 'A senha é muito fraca.';
      case 'invalid-email':
        return 'Email inválido.';
      case 'user-disabled':
        return 'Esta conta foi desabilitada.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      case 'operation-not-allowed':
        return 'Operação não permitida.';
      case 'invalid-credential':
      case 'invalid-verification-code':
      case 'invalid-verification-id':
        return 'Não foi possível validar a credencial de acesso. Tente fazer login novamente.';
      default:
        // Mensagem genérica em português, mas incluindo o código do FirebaseAuth
        // para facilitar diagnóstico (debug).
        return 'Não foi possível concluir a autenticação (${e.code}). Tente novamente em alguns instantes.';
    }
  }
}
