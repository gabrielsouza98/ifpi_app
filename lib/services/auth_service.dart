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
          clientId: '560636982577-6f74592625a48a8789ac10.apps.googleusercontent.com',
          scopes: const ['email', 'profile'],
          serverClientId: '560636982577-6f74592625a48a8789ac10.apps.googleusercontent.com',
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
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Salvar dados da empresa no Firestore
      await _firestore.collection('empresas').doc(result.user!.uid).set({
        'nomeEmpresa': nomeEmpresa,
        'cnpj': cnpj,
        'email': email,
        'tipo': 'empresa',
        'dataCriacao': FieldValue.serverTimestamp(),
        'ativo': true,
      });

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Recuperação de senha
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
      // Primeiro, tentar fazer login silencioso
      GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
      
      // Se não conseguir login silencioso, fazer login normal
      if (googleUser == null) {
        googleUser = await _googleSignIn.signIn();
      }
      
      if (googleUser == null) {
        return null; // Usuário cancelou o login
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      UserCredential result = await _auth.signInWithCredential(credential);

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
          await _googleSignIn.signOut();
          throw Exception('Este login é apenas para usuários');
        }
      }

      return result;
    } catch (e) {
      await _googleSignIn.signOut();
      throw Exception('Erro no login com Google: ${e.toString()}');
    }
  }

  // Login com Google para Empresa
  Future<UserCredential?> signInWithGoogleEmpresa() async {
    try {
      // Primeiro, tentar fazer login silencioso
      GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
      
      // Se não conseguir login silencioso, fazer login normal
      if (googleUser == null) {
        googleUser = await _googleSignIn.signIn();
      }
      
      if (googleUser == null) {
        return null; // Usuário cancelou o login
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      UserCredential result = await _auth.signInWithCredential(credential);

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
          await _googleSignIn.signOut();
          throw Exception('Este login é apenas para empresas');
        }
      }

      return result;
    } catch (e) {
      await _googleSignIn.signOut();
      throw Exception('Erro no login com Google: ${e.toString()}');
    }
  }

  // Verificar se é usuário
  Future<bool> isUsuario() async {
    if (currentUser == null) return false;
    
    DocumentSnapshot userDoc = await _firestore
        .collection('usuarios')
        .doc(currentUser!.uid)
        .get();
    
    return userDoc.exists;
  }

  // Verificar se é empresa
  Future<bool> isEmpresa() async {
    if (currentUser == null) return false;
    
    DocumentSnapshot userDoc = await _firestore
        .collection('empresas')
        .doc(currentUser!.uid)
        .get();
    
    return userDoc.exists;
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

  // Tratamento de exceções do Firebase Auth
  String _handleAuthException(FirebaseAuthException e) {
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
      default:
        return 'Erro de autenticação: ${e.message}';
    }
  }
}
