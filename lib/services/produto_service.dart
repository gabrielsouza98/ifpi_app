import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'dart:async';

class ProdutoService {
  ProdutoService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('produtos');

  Stream<List<Produto>> streamProdutos({String? categoria, String? busca}) {
    // Para compatibilidade com Web/Hot Reload, mantemos um único listener na coleção
    // e aplicamos filtros no cliente.
    final Query<Map<String, dynamic>> query = _col.orderBy('criadoEm', descending: true);
    return query.snapshots().map((QuerySnapshot<Map<String, dynamic>> snap) {
      final List<Produto> itens = snap.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> d) => Produto.fromMap(d.id, d.data()))
          .toList();
      List<Produto> result = itens;
      if (categoria != null && categoria.isNotEmpty) {
        result = result.where((Produto p) => p.categoria == categoria).toList();
      }
      if (busca != null && busca.trim().isNotEmpty) {
        final String q = busca.toLowerCase().trim();
        result = result.where((Produto p) => p.nome.toLowerCase().contains(q)).toList();
      }
      return result;
    });
  }

  Future<void> criarProduto(Produto produto) async {
    await _col.add(produto.toMap());
  }

  Future<void> atualizarProduto(Produto produto) async {
    await _col.doc(produto.id).update(produto.toMap());
  }

  Future<void> deletarProduto(String id) async {
    await _col.doc(id).delete();
  }
}

class Produto {
  Produto({
    required this.id,
    required this.nome,
    required this.preco,
    required this.categoria,
    required this.empresaId,
    required this.criadoEm,
    this.imagemUrl,
    this.descricao,
    List<String>? imagensUrls,
  }) : imagensUrls = imagensUrls ?? const <String>[];

  final String id;
  final String nome;
  final double preco;
  final String categoria;
  final String empresaId;
  final DateTime criadoEm;
  final String? imagemUrl;
  final String? descricao;
  final List<String> imagensUrls;

  factory Produto.fromMap(String id, Map<String, dynamic> map) {
    String? url = map['imagemUrl'] as String?;
    if (url != null && url.isNotEmpty) {
      // Normaliza URLs antigas do bucket para o bucket atual do projeto
      // Seu bucket padrão (conforme Console) é ifpi-app.firebasestorage.app
      url = url.replaceAll('ifpi-app.appspot.com', 'ifpi-app.firebasestorage.app');
    }
    final List<dynamic>? imagensRaw = map['imagensUrls'] as List<dynamic>?;
    List<String> imagens = imagensRaw == null
        ? <String>[]
        : imagensRaw.map((dynamic e) => (e as String)).toList();
    if ((imagens.isEmpty) && url != null && url.isNotEmpty) {
      imagens = <String>[url];
    }
    final String? desc = map['descricao'] as String?;
    return Produto(
      id: id,
      nome: map['nome'] as String? ?? '',
      preco: (map['preco'] as num?)?.toDouble() ?? 0,
      categoria: map['categoria'] as String? ?? '',
      empresaId: map['empresaId'] as String? ?? '',
      criadoEm: (map['criadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imagemUrl: url,
      descricao: desc,
      imagensUrls: imagens,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'nome': nome,
      'preco': preco,
      'categoria': categoria,
      'empresaId': empresaId,
      'criadoEm': Timestamp.fromDate(criadoEm),
      'imagemUrl': imagemUrl,
      'descricao': descricao,
      'imagensUrls': imagensUrls,
    };
  }
}

extension ProdutoUploads on ProdutoService {
  Future<String> uploadImagemProduto({
    required String empresaId,
    required String fileName,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final Reference ref = storage.ref().child('produtos').child(empresaId).child(fileName);
    final SettableMetadata meta = SettableMetadata(contentType: contentType);
    // Upload com timeout mais generoso para redes lentas
    await ref.putData(bytes, meta).timeout(const Duration(minutes: 2));
    return ref.getDownloadURL().timeout(const Duration(seconds: 30));
  }
}


