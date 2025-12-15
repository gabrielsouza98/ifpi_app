# Solução para CORS no Desenvolvimento Web

## ⚠️ Problema
Os proxies CORS públicos são instáveis e podem estar bloqueados. Para desenvolvimento web, temos algumas opções:

## ✅ Solução Rápida (Desenvolvimento)

### Opção 1: Remover Restrições Temporariamente (Mais Rápido)

1. Acesse: https://console.cloud.google.com/apis/credentials
2. Clique na **"Browser key (auto created by Firebase)"**
3. Em **"Restrições de aplicativo"**, selecione: **"Nenhum"**
4. Mantenha as **"Restrições de API"** ativas (Places API e Geocoding API)
5. Clique em **"Salvar"**

⚠️ **ATENÇÃO**: Isso permite que a API Key seja usada de qualquer site. Use APENAS para desenvolvimento!

### Opção 2: Adicionar Todas as Portas do Localhost

1. Acesse: https://console.cloud.google.com/apis/credentials
2. Clique na **"Browser key"**
3. Em **"Restrições de aplicativo"**, selecione: **"Sites"**
4. Adicione múltiplas entradas:
   ```
   http://localhost
   http://localhost:56708
   http://localhost:56117
   http://127.0.0.1
   http://127.0.0.1:56708
   http://127.0.0.1:56117
   ```
5. Clique em **"Salvar"**

## 🚀 Solução para Produção (Recomendado)

Para produção, **NUNCA** remova as restrições. Use uma das opções:

### 1. Cloud Functions do Firebase (Melhor Opção)

Crie uma Cloud Function que faz as chamadas à API do Google Maps:

```javascript
// functions/index.js
const functions = require('firebase-functions');
const axios = require('axios');

exports.searchPlaces = functions.https.onCall(async (data, context) => {
  const query = data.query;
  const apiKey = 'SUA_API_KEY';
  
  const response = await axios.get(
    `https://maps.googleapis.com/maps/api/place/autocomplete/json`,
    {
      params: {
        input: query,
        key: apiKey,
        language: 'pt-BR',
        components: 'country:br'
      }
    }
  );
  
  return response.data;
});
```

### 2. Backend Próprio

Crie um endpoint no seu backend que faz as chamadas à API do Google Maps.

## 📝 Teste Agora

Após remover as restrições temporariamente:

1. Recarregue o app (Ctrl+R ou F5)
2. Tente digitar um endereço novamente
3. Deve funcionar agora!

## 🔒 Lembrete de Segurança

- **Desenvolvimento**: Pode remover restrições temporariamente
- **Produção**: SEMPRE use Cloud Functions ou backend próprio
- **Nunca** exponha a API Key no código frontend em produção








