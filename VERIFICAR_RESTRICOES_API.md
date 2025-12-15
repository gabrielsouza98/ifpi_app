# 🔍 Verificar Restrições de API

## Se as restrições de aplicativo já estavam desativadas, verifique:

### 1. Restrições de API (Mais Importante!)

1. Acesse: https://console.cloud.google.com/apis/credentials?project=ifpi-app
2. Clique na **"Browser key (auto created by Firebase)"**
3. Role até **"Restrições de API"**
4. Verifique se está selecionado: **"Restringir chave"**
5. **Verifique se estas APIs estão marcadas:**
   - ✅ **Places API (New)** - OBRIGATÓRIA
   - ✅ **Geocoding API** - OBRIGATÓRIA  
   - ✅ **Maps JavaScript API** - OBRIGATÓRIA

### 2. Se "Nenhum" estiver selecionado em "Restrições de API"

**PROBLEMA**: Isso permite TODAS as APIs, mas pode causar problemas.

**SOLUÇÃO**: 
1. Selecione **"Restringir chave"**
2. Marque APENAS as 3 APIs acima
3. Clique em **"Salvar"**

### 3. Verificar se as APIs estão realmente habilitadas

1. Acesse: https://console.cloud.google.com/apis/library?project=ifpi-app
2. Vá em: **APIs e serviços** > **APIs e serviços ativados**
3. Verifique se aparecem:
   - ✅ Places API (New)
   - ✅ Geocoding API
   - ✅ Maps JavaScript API

Se alguma não aparecer, habilite-a!

### 4. Verificar a API Key no código

A API Key usada no código é: `AIzaSyDkqbEZ-q020wOXE--9HvLRD0wwlfMfbmc`

Verifique se esta é a mesma da **Browser key** no console.

### 5. Tentar criar uma nova API Key (se nada funcionar)

1. Acesse: https://console.cloud.google.com/apis/credentials?project=ifpi-app
2. Clique em **"+ Criar credenciais"** > **"Chave de API"**
3. Nomeie como: "Browser Key - Desenvolvimento"
4. Configure:
   - **Restrições de aplicativo**: Nenhum
   - **Restrições de API**: Restringir chave
     - ✅ Places API (New)
     - ✅ Geocoding API
     - ✅ Maps JavaScript API
5. Copie a nova API Key
6. Substitua no código








