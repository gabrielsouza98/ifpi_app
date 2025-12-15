# ⚠️ ERRO: ApiNotActivatedMapError - HABILITAR APIs AGORA

## 🔴 Erro Atual
```
Google Maps JavaScript API error: ApiNotActivatedMapError
```

Isso significa que as APIs do Google Maps **NÃO estão habilitadas** no seu projeto.

## ✅ SOLUÇÃO IMEDIATA

### Passo 1: Acessar o Google Cloud Console
1. Acesse: https://console.cloud.google.com/apis/library?project=ifpi-app
2. Certifique-se de estar no projeto: **ifpi-app**

### Passo 2: Habilitar as APIs (FAÇA ISSO AGORA!)

#### API 1: Places API (New) - OBRIGATÓRIA
1. Na barra de pesquisa, digite: **"Places API (New)"**
2. Clique no resultado
3. Clique no botão **"ATIVAR"** (grande botão azul)
4. Aguarde a confirmação

#### API 2: Geocoding API - OBRIGATÓRIA
1. Na barra de pesquisa, digite: **"Geocoding API"**
2. Clique no resultado
3. Clique no botão **"ATIVAR"**
4. Aguarde a confirmação

#### API 3: Maps JavaScript API - OBRIGATÓRIA
1. Na barra de pesquisa, digite: **"Maps JavaScript API"**
2. Clique no resultado
3. Clique no botão **"ATIVAR"**
4. Aguarde a confirmação

### Passo 3: Verificar se foram habilitadas
1. Vá em: **APIs e serviços** > **APIs e serviços ativados**
2. Você deve ver as 3 APIs listadas:
   - ✅ Places API (New)
   - ✅ Geocoding API
   - ✅ Maps JavaScript API

### Passo 4: Testar novamente
1. Recarregue o app (Ctrl+Shift+R)
2. Tente digitar um endereço novamente
3. Deve funcionar agora!

## 📋 Checklist Rápido

- [ ] Acessei o Google Cloud Console
- [ ] Habilitei "Places API (New)"
- [ ] Habilitei "Geocoding API"
- [ ] Habilitei "Maps JavaScript API"
- [ ] Verifiquei que aparecem em "APIs e serviços ativados"
- [ ] Testei o app novamente

## ⏱️ Tempo de Propagação
Após habilitar, pode levar **1-2 minutos** para as APIs ficarem ativas.

## 🔗 Link Direto
https://console.cloud.google.com/apis/library?project=ifpi-app








