import 'package:cloud_firestore/cloud_firestore.dart';

/// Tipos de evento de analytics por produto.
enum TipoEventoAnalytics {
  view('view'),
  whatsapp('whatsapp'),
  rotas('rotas');

  const TipoEventoAnalytics(this.value);
  final String value;
}

/// Resumo de analytics de um produto para a empresa.
class ProdutoAnalytics {
  const ProdutoAnalytics({
    required this.totalVisualizacoes,
    required this.totalWhatsApp,
    required this.totalRotas,
    required this.ultimasVisualizacoes,
    required this.ultimosEventosWhatsApp,
    required this.ultimosEventosRotas,
  });

  final int totalVisualizacoes;
  final int totalWhatsApp;
  final int totalRotas;
  final List<DateTime> ultimasVisualizacoes;
  final List<DateTime> ultimosEventosWhatsApp;
  final List<DateTime> ultimosEventosRotas;

  static const String _collection = 'analytics_eventos';

  static CollectionReference<Map<String, dynamic>> _col() =>
      FirebaseFirestore.instance.collection(_collection);

  /// Registra uma visualização do produto (tela aberta pelo usuário).
  static Future<void> registrarVisualizacao(String produtoId, String empresaId) async {
    await _col().add(<String, dynamic>{
      'produtoId': produtoId,
      'empresaId': empresaId,
      'tipo': TipoEventoAnalytics.view.value,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Registra clique no botão WhatsApp.
  static Future<void> registrarCliqueWhatsApp(String produtoId, String empresaId) async {
    await _col().add(<String, dynamic>{
      'produtoId': produtoId,
      'empresaId': empresaId,
      'tipo': TipoEventoAnalytics.whatsapp.value,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Registra clique no botão "Ver rota" (Google Maps).
  static Future<void> registrarCliqueRota(String produtoId, String empresaId) async {
    await _col().add(<String, dynamic>{
      'produtoId': produtoId,
      'empresaId': empresaId,
      'tipo': TipoEventoAnalytics.rotas.value,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Busca analytics agregados e últimas datas para um produto.
  /// Usa apenas where (sem orderBy) para não exigir índice composto no Firestore.
  static Future<ProdutoAnalytics> getAnalyticsProduto(String produtoId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _col()
        .where('produtoId', isEqualTo: produtoId)
        .limit(500)
        .get();

    final List<_EventoItem> itens = [];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final tipo = data['tipo'] as String? ?? '';
      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
      if (createdAt != null) itens.add(_EventoItem(tipo: tipo, createdAt: createdAt));
    }
    itens.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    int views = 0;
    int whatsapp = 0;
    int rotas = 0;
    final List<DateTime> ultimasViews = [];
    final List<DateTime> ultimosWa = [];
    final List<DateTime> ultimasRotas = [];

    for (final e in itens) {
      switch (e.tipo) {
        case 'view':
          views++;
          if (ultimasViews.length < 30) ultimasViews.add(e.createdAt);
          break;
        case 'whatsapp':
          whatsapp++;
          if (ultimosWa.length < 20) ultimosWa.add(e.createdAt);
          break;
        case 'rotas':
          rotas++;
          if (ultimasRotas.length < 20) ultimasRotas.add(e.createdAt);
          break;
      }
    }

    return ProdutoAnalytics(
      totalVisualizacoes: views,
      totalWhatsApp: whatsapp,
      totalRotas: rotas,
      ultimasVisualizacoes: ultimasViews,
      ultimosEventosWhatsApp: ultimosWa,
      ultimosEventosRotas: ultimasRotas,
    );
  }

  /// Stream de analytics do produto para atualização em tempo real na tela da empresa.
  /// Usa apenas where (sem orderBy) para não exigir índice composto.
  static Stream<ProdutoAnalytics> streamAnalyticsProduto(String produtoId) {
    return _col()
        .where('produtoId', isEqualTo: produtoId)
        .limit(500)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
          final List<_EventoItem> itens = [];
          for (final doc in snapshot.docs) {
            final data = doc.data();
            final tipo = data['tipo'] as String? ?? '';
            final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
            if (createdAt != null) itens.add(_EventoItem(tipo: tipo, createdAt: createdAt));
          }
          itens.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          int views = 0;
          int whatsapp = 0;
          int rotas = 0;
          final List<DateTime> ultimasViews = [];
          final List<DateTime> ultimosWa = [];
          final List<DateTime> ultimasRotas = [];

          for (final e in itens) {
            switch (e.tipo) {
              case 'view':
                views++;
                if (ultimasViews.length < 30) ultimasViews.add(e.createdAt);
                break;
              case 'whatsapp':
                whatsapp++;
                if (ultimosWa.length < 20) ultimosWa.add(e.createdAt);
                break;
              case 'rotas':
                rotas++;
                if (ultimasRotas.length < 20) ultimasRotas.add(e.createdAt);
                break;
            }
          }

          return ProdutoAnalytics(
            totalVisualizacoes: views,
            totalWhatsApp: whatsapp,
            totalRotas: rotas,
            ultimasVisualizacoes: ultimasViews,
            ultimosEventosWhatsApp: ultimosWa,
            ultimosEventosRotas: ultimasRotas,
          );
        });
  }
}

class _EventoItem {
  const _EventoItem({required this.tipo, required this.createdAt});
  final String tipo;
  final DateTime createdAt;
}
