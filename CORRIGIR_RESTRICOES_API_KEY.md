# 🔧 Corrigir Erro: ApiTargetBlockedMapError

## 🔴 Erro Atual
```
Google Maps JavaScript API error: ApiTargetBlockedMapError
```

Isso significa que a **API Key está bloqueada pelas restrições de aplicativo**.

## ✅ SOLUÇÃO

### Opção 1: Remover Restrições Temporariamente (Mais Rápido para Desenvolvimento)

1. Acesse: https://console.cloud.google.com/apis/credentials?project=ifpi-app
2. Clique na **"Browser key (auto created by Firebase)"**
3. Em **"Restrições de aplicativo"**, selecione: **"Nenhum"**
4. **MANTENHA** as **"Restrições de API"** ativas:
   - ✅ Places API (New)
   - ✅ Geocoding API
   - ✅ Maps JavaScript API
5. Clique em **"Salvar"**
6. Aguarde 1-2 minutos
7. Recarregue o app (Ctrl+Shift+R)

### Opção 2: Adicionar Localhost Corretamente

Se preferir manter as restrições:

1. Acesse: https://console.cloud.google.com/apis/credentials?project=ifpi-app
2. Clique na **"Browser key"**
3. Em **"Restrições de aplicativo"**, selecione: **"Sites"**
4. Adicione TODAS estas URLs (uma por linha):
   ```
   http://localhost
   http://localhost:*
   http://127.0.0.1
   http://127.0.0.1:*
   ```
5. Clique em **"Salvar"**

## ⚠️ IMPORTANTE

- **Para desenvolvimento**: Pode remover restrições temporariamente
- **Para produção**: Use Cloud Functions do Firebase (não exponha a API Key no frontend)

## 🧪 Teste

Após salvar:
1. Aguarde 1-2 minutos
2. Recarregue o app completamente (Ctrl+Shift+R)
3. Tente digitar um endereço
4. Deve funcionar agora!








