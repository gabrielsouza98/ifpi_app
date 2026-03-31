import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode, kIsWeb;

class GeocodingService {
  static String get _keySuffix {
    if (_apiKey.length <= 6) return _apiKey;
    return _apiKey.substring(_apiKey.length - 6);
  }

  // Chaves obtidas preferencialmente via --dart-define,
  // mas com fallback para valores padrao para evitar ter
  // que passar parametros no comando de execucao.
  static const String _webApiKeyEnv = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY_WEB',
    defaultValue: '',
  );
  static const String _mobileApiKeyEnv = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY_MOBILE',
    defaultValue: '',
  );

  // Fallbacks:
  // - Web: Browser key (Places/Geocoding habilitados)
  // - Mobile: Android/iOS key com Places/Geocoding habilitados
  static const String _webApiKeyFallback =
      'AIzaSyDuZI8NRDMKMnj-Hv1ENBBu6va4NqN69Ng';
  static const String _mobileApiKeyFallback =
      'AIzaSyBlSMVVhB8Kmqof7Q8-mgjxUviggVFAzco';

  // Web: Browser key, Mobile: Android/iOS key via --dart-define
  static String get _apiKey {
    if (kIsWeb) {
      final key = _webApiKeyEnv.isNotEmpty
          ? _webApiKeyEnv
          : (kDebugMode ? _webApiKeyFallback : '');
      if (key.isEmpty) {
        throw Exception(
          'GOOGLE_MAPS_API_KEY_WEB nao configurada para release. Passe via --dart-define.',
        );
      }
      return key;
    } else {
      final key = _mobileApiKeyEnv.isNotEmpty
          ? _mobileApiKeyEnv
          : (kDebugMode ? _mobileApiKeyFallback : '');
      if (key.isEmpty) {
        throw Exception(
          'GOOGLE_MAPS_API_KEY_MOBILE nao configurada para release. Passe via --dart-define.',
        );
      }
      return key;
    }
  }

  static Future<List<Map<String, dynamic>>> buscarEnderecos(String query) async {
    if (kIsWeb) {
      return _buscarEnderecosNewApi(query);
    }
    return _buscarEnderecosLegacyApiMobile(query);
  }

  static Future<List<Map<String, dynamic>>> _buscarEnderecosNewApi(String query) async {
    final url = Uri.parse('https://places.googleapis.com/v1/places:autocomplete');

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': _apiKey,
      'X-Goog-FieldMask':
          'suggestions.placePrediction.placeId,suggestions.placePrediction.text',
    };

    final body = json.encode({
      'input': query,
      'includedRegionCodes': ['BR'],
      'languageCode': 'pt-BR',
    });

    final response = await http
        .post(url, headers: headers, body: body)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      try {
        final data = json.decode(response.body);
        final message = data['error']?['message'] as String?;
        if (message != null && message.trim().isNotEmpty) {
          throw Exception(message.trim());
        }
      } catch (_) {
        // Ignora falha de parse e usa mensagem generica abaixo.
      }
      throw Exception('Nao foi possivel buscar enderecos agora. (HTTP ${response.statusCode})');
    }

    final data = json.decode(response.body);
    final List<dynamic> suggestions =
        (data['suggestions'] as List<dynamic>?) ?? const [];
    return suggestions.map((s) {
      final placePrediction = s['placePrediction'];
      if (placePrediction != null) {
        final text = placePrediction['text'] ?? {};
        return {
          'description': (text['text'] as String?) ?? '',
          'placeId': (placePrediction['placeId'] as String?) ?? '',
        };
      }
      return {'description': '', 'placeId': ''};
    }).where((p) => (p['description'] as String).isNotEmpty).toList();
  }

  static Future<List<Map<String, dynamic>>> _buscarEnderecosLegacyApiMobile(
    String query,
  ) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json'
      '?input=${Uri.encodeComponent(query)}'
      '&key=$_apiKey'
      '&language=pt-BR'
      '&components=country:br',
    );

    final response = await http.get(url).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Nao foi possivel buscar enderecos agora. (HTTP ${response.statusCode})');
    }

    final data = json.decode(response.body);
    final status = data['status'] as String?;
    if (status != 'OK') {
      final errorMessage = (data['error_message'] as String?)?.trim();
      debugPrint(
        '[MapsAutocomplete][mobile] status=$status error="$errorMessage" keySuffix=$_keySuffix',
      );
      final msg = errorMessage?.isNotEmpty == true
          ? errorMessage!
          : 'Nao foi possivel buscar enderecos agora. ($status)';
      if (status == 'REQUEST_DENIED') {
        throw Exception(
          '$msg. Verifique restricoes da chave no Google Cloud (Android app/web service) e APIs Places/Geocoding habilitadas.',
        );
      }
      throw Exception(msg);
    }

    final List<dynamic> predictions =
        (data['predictions'] as List<dynamic>?) ?? const [];
    return predictions.map((prediction) {
      return {
        'description': prediction['description'] as String? ?? '',
        'placeId': prediction['place_id'] as String? ?? '',
      };
    }).where((p) => (p['description'] as String).isNotEmpty).toList();
  }

  static Future<Map<String, double>?> obterCoordenadas(String placeId) async {
    if (kIsWeb) {
      return _obterCoordenadasNewApi(placeId);
    }
    return _obterCoordenadasLegacyApiMobile(placeId);
  }

  static Future<Map<String, double>?> _obterCoordenadasNewApi(String placeId) async {
    final url = Uri.parse('https://places.googleapis.com/v1/places/$placeId');

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': _apiKey,
      'X-Goog-FieldMask': 'location',
    };

    final response =
        await http.get(url, headers: headers).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      try {
        final data = json.decode(response.body);
        final message = data['error']?['message'] as String?;
        if (message != null && message.trim().isNotEmpty) {
          throw Exception(message.trim());
        }
      } catch (_) {
        // Ignora falha de parse e usa mensagem generica abaixo.
      }
      throw Exception(
        'Nao foi possivel obter as coordenadas agora. (HTTP ${response.statusCode})',
      );
    }

    final data = json.decode(response.body);
    final location = data['location'];
    if (location == null) return null;
    return {
      'latitude': (location['latitude'] as num).toDouble(),
      'longitude': (location['longitude'] as num).toDouble(),
    };
  }

  static Future<Map<String, double>?> _obterCoordenadasLegacyApiMobile(
    String placeId,
  ) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=$placeId'
      '&fields=geometry'
      '&key=$_apiKey'
      '&language=pt-BR',
    );

    final response = await http.get(url).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Nao foi possivel obter as coordenadas agora. (HTTP ${response.statusCode})',
      );
    }

    final data = json.decode(response.body);
    final status = data['status'] as String?;
    if (status != 'OK') {
      final errorMessage = (data['error_message'] as String?)?.trim();
      debugPrint(
        '[MapsPlaceDetails][mobile] status=$status error="$errorMessage" keySuffix=$_keySuffix',
      );
      final msg = errorMessage?.isNotEmpty == true
          ? errorMessage!
          : 'Nao foi possivel obter as coordenadas agora. ($status)';
      throw Exception(msg);
    }

    final result = data['result'];
    final geometry = result?['geometry'];
    final location = geometry?['location'];
    if (location == null) return null;

    return {
      'latitude': (location['lat'] as num).toDouble(),
      'longitude': (location['lng'] as num).toDouble(),
    };
  }

  static Future<Map<String, dynamic>?> geocodificarEndereco(String endereco) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?address=${Uri.encodeComponent(endereco)}'
        '&key=$_apiKey'
        '&language=pt-BR'
        '&region=br',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' &&
            data['results'] != null &&
            data['results'].isNotEmpty) {
          final result = data['results'][0];
          final location = result['geometry']['location'];
          final formattedAddress = result['formatted_address'] as String;

          return {
            'endereco': formattedAddress,
            'latitude': (location['lat'] as num).toDouble(),
            'longitude': (location['lng'] as num).toDouble(),
          };
        }
      }

      return null;
    } catch (_) {
      return null;
    }
  }
}
