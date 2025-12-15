import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class GeocodingService {
  // Use a API key do Google Maps - você pode criar uma variável de ambiente ou configurar
  // Para produção, configure isso de forma segura (variáveis de ambiente, etc)
  // Web: Browser key, Mobile: Android/iOS key
  static String get _apiKey {
    // Para web, usar Browser key; para mobile, usar Android key
    return kIsWeb 
        ? 'AIzaSyAqPyjZP-DOAzC_4SUb-M8DfP9UfRY72QY' // Browser key
        : 'AIzaSyDkqbEZ-q020wOXE--9HvLRD0wwlfMfbmc'; // Android key
  }
  
  // Buscar sugestões de endereços (Autocomplete)
  static Future<List<Map<String, dynamic>>> buscarEnderecos(String query) async {
    try {
      // Para web, usar o serviço JavaScript do Google Places (via script no HTML)
      // Para mobile, usar chamada HTTP direta
      if (kIsWeb) {
        return await _buscarEnderecosWeb(query);
      } else {
        return await _buscarEnderecosMobile(query);
      }
    } catch (e) {
      return [];
    }
  }
  
  // Busca para mobile (HTTP direto)
  static Future<List<Map<String, dynamic>>> _buscarEnderecosMobile(String query) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(query)}'
        '&key=$_apiKey'
        '&language=pt-BR'
        '&components=country:br',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['predictions'] != null) {
          final List<dynamic> predictions = data['predictions'];
          return predictions.map((prediction) {
            return {
              'description': prediction['description'] as String,
              'placeId': prediction['place_id'] as String,
            };
          }).toList();
        }
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }
  
  // Busca para web (usando Places API New via REST)
  static Future<List<Map<String, dynamic>>> _buscarEnderecosWeb(String query) async {
    try {
      if (!kIsWeb) return [];
      
      // Usar a nova Places API (New) via REST
      // Esta API não tem problemas de CORS quando configurada corretamente
      final url = Uri.parse(
        'https://places.googleapis.com/v1/places:autocomplete',
      );
      
      final headers = {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': _apiKey,
        'X-Goog-FieldMask': 'suggestions.placePrediction.placeId,suggestions.placePrediction.text',
      };
      
      final body = json.encode({
        'input': query,
        'includedRegionCodes': ['BR'],
        'languageCode': 'pt-BR',
      });
      
      final response = await http.post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['suggestions'] != null) {
          final List<dynamic> suggestions = data['suggestions'];
          return suggestions.map((s) {
            final placePrediction = s['placePrediction'];
            if (placePrediction != null) {
              final text = placePrediction['text'] ?? {};
              return {
                'description': text['text'] ?? '',
                'placeId': placePrediction['placeId'] ?? '',
              };
            }
            return {
              'description': '',
              'placeId': '',
            };
          }).where((p) => p['description'].isNotEmpty).toList();
        }
      }
      
      return [];
    } catch (e) {
      // Se falhar, retornar lista vazia
      return [];
    }
  }

  // Obter coordenadas (latitude e longitude) a partir de um place_id
  static Future<Map<String, double>?> obterCoordenadas(String placeId) async {
    try {
      if (kIsWeb) {
        return await _obterCoordenadasWeb(placeId);
      } else {
        return await _obterCoordenadasMobile(placeId);
      }
    } catch (e) {
      return null;
    }
  }
  
  // Obter coordenadas para mobile
  static Future<Map<String, double>?> _obterCoordenadasMobile(String placeId) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&fields=geometry'
        '&key=$_apiKey'
        '&language=pt-BR',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['result'] != null) {
          final result = data['result'];
          if (result['geometry'] != null) {
            final location = result['geometry']['location'];
            
            return {
              'latitude': (location['lat'] as num).toDouble(),
              'longitude': (location['lng'] as num).toDouble(),
            };
          }
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Obter coordenadas para web (usando Places API New via REST)
  static Future<Map<String, double>?> _obterCoordenadasWeb(String placeId) async {
    try {
      if (!kIsWeb) return null;
      
      // Usar a nova Places API (New) via REST
      final url = Uri.parse(
        'https://places.googleapis.com/v1/places/$placeId',
      );
      
      final headers = {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': _apiKey,
        'X-Goog-FieldMask': 'location',
      };
      
      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['location'] != null) {
          final location = data['location'];
          return {
            'latitude': (location['latitude'] as num).toDouble(),
            'longitude': (location['longitude'] as num).toDouble(),
          };
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  // Geocoding direto a partir de um endereço (string)
  static Future<Map<String, dynamic>?> geocodificarEndereco(String endereco) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?address=${Uri.encodeComponent(endereco)}'
        '&key=$_apiKey'
        '&language=pt-BR'
        '&region=br', // Limitar ao Brasil
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'] != null && data['results'].isNotEmpty) {
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
    } catch (e) {
      return null;
    }
  }
}

