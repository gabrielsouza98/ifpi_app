# Configuração da API do Google Maps

## Passos para habilitar as APIs necessárias:

### 1. Acessar o Google Cloud Console
- Acesse: https://console.cloud.google.com/
- Certifique-se de estar no projeto correto: **ifpi-app** (ID: 560636982577)

### 2. Habilitar as APIs necessárias

Você precisa habilitar as seguintes APIs:

#### a) Places API (Nova)
- Vá em: **APIs e serviços** > **Biblioteca**
- Pesquise por: **"Places API (New)"** ou **"Places API"**
- Clique em **Ativar**

#### b) Geocoding API
- Vá em: **APIs e serviços** > **Biblioteca**
- Pesquise por: **"Geocoding API"**
- Clique em **Ativar**

#### c) Maps JavaScript API (opcional, para uso futuro)
- Vá em: **APIs e serviços** > **Biblioteca**
- Pesquise por: **"Maps JavaScript API"**
- Clique em **Ativar**

### 3. Verificar/Criar API Key

#### Verificar API Key existente:
- Vá em: **APIs e serviços** > **Credenciais**
- Procure pela API Key: `AIzaSyDkqbEZ-q020wOXE--9HvLRD0wwlfMfbmc`
- Se não encontrar, crie uma nova:
  - Clique em **Criar credenciais** > **Chave de API**
  - Copie a chave gerada

### 4. Configurar restrições da API Key (Recomendado para produção)

Para maior segurança:

1. Clique na API Key para editar
2. Em **Restrições de aplicativo**:
   - Para Web: Selecione **Referenciadores HTTP (websites)**
   - Adicione os domínios permitidos (ex: `localhost:56708`, `seu-dominio.com`)
3. Em **Restrições de API**:
   - Selecione **Restringir chave**
   - Marque apenas as APIs que você usa:
     - ✅ Places API (New)
     - ✅ Geocoding API
     - ✅ Maps JavaScript API (se usar)

### 5. Verificar faturamento

⚠️ **IMPORTANTE**: As APIs do Google Maps têm um plano gratuito, mas podem gerar custos:
- Places API: $17 por 1000 requisições (após crédito gratuito)
- Geocoding API: $5 por 1000 requisições (após crédito gratuito)

- Vá em: **Faturamento** no menu lateral
- Certifique-se de ter um método de pagamento configurado (mesmo que não seja cobrado no plano gratuito)
- Configure alertas de faturamento para monitorar o uso

### 6. Testar a configuração

Após habilitar as APIs, teste o cadastro de empresa:
1. Execute o app
2. Tente cadastrar uma empresa
3. Digite um endereço no campo de busca
4. Verifique se as sugestões aparecem

## Troubleshooting

### Erro: "This API project is not authorized to use this API"
- **Solução**: Verifique se as APIs estão habilitadas (passo 2)

### Erro: "API key not valid"
- **Solução**: Verifique se a API key está correta e se as APIs estão habilitadas

### Erro: "RefererNotAllowedMapError"
- **Solução**: Adicione o domínio nas restrições de aplicativo (passo 4)

### Erro de CORS (apenas web)
- **Solução**: O código já usa um proxy CORS para desenvolvimento. Para produção, use Cloud Functions.

## Links úteis:

- Google Cloud Console: https://console.cloud.google.com/
- Documentação Places API: https://developers.google.com/maps/documentation/places/web-service
- Preços: https://developers.google.com/maps/billing-and-pricing/pricing








