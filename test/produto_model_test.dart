import 'package:app_ifpi/services/produto_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Produto.fromMap normaliza bucket antigo e cria fallback em imagensUrls', () {
    final produto = Produto.fromMap('p1', <String, dynamic>{
      'nome': 'Arroz',
      'preco': 10.5,
      'categoria': 'alimentos',
      'empresaId': 'empresa123',
      'criadoEm': Timestamp.fromDate(DateTime(2026, 2, 23)),
      'imagemUrl':
          'https://firebasestorage.googleapis.com/v0/b/ifpi-app.appspot.com/o/x.jpg',
      'descricao': 'Produto teste',
    });

    expect(produto.id, 'p1');
    expect(produto.imagemUrl, contains('ifpi-app.firebasestorage.app'));
    expect(produto.imagensUrls, hasLength(1));
    expect(produto.imagensUrls.first, produto.imagemUrl);
  });

  test('Produto.toMap inclui lista de imagens e campos esperados', () {
    final produto = Produto(
      id: 'p2',
      nome: 'Sabonete',
      preco: 3.99,
      categoria: 'beleza e cuidados pessoais',
      empresaId: 'empresa123',
      criadoEm: DateTime(2026, 2, 23),
      imagemUrl: 'https://exemplo/imagem.jpg',
      descricao: 'Cheiro suave',
      imagensUrls: const ['https://exemplo/imagem.jpg'],
    );

    final map = produto.toMap();

    expect(map['nome'], 'Sabonete');
    expect(map['preco'], 3.99);
    expect(map['empresaId'], 'empresa123');
    expect(map['imagemUrl'], 'https://exemplo/imagem.jpg');
    expect(map['imagensUrls'], isA<List<String>>());
    expect(map['criadoEm'], isA<Timestamp>());
  });
}
