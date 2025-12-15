# Teste da Configuração do Google Maps

## ✅ Checklist Final

Antes de testar, verifique se:

- [x] API Key do Browser configurada com restrições de Sites
- [x] API Key do Android configurada com SHA-1
- [ ] **Places API (New) está HABILITADA**
- [ ] **Geocoding API está HABILITADA**

## 🔍 Verificar se as APIs estão habilitadas:

1. Acesse: https://console.cloud.google.com/apis/library
2. Procure por "Places API (New)" - deve aparecer como "Habilitada"
3. Procure por "Geocoding API" - deve aparecer como "Habilitada"

Se não estiverem habilitadas:
- Clique em cada uma
- Clique no botão "Ativar"

## 🧪 Testar o App:

### Para Web:
1. Execute: `flutter run -d chrome`
2. Vá para a tela de cadastro de empresa
3. Digite um endereço no campo de busca (ex: "Rua Equador")
4. **Deve aparecer uma lista de sugestões de endereços**

### Para Android:
1. Execute: `flutter run`
2. Vá para a tela de cadastro de empresa
3. Digite um endereço no campo de busca
4. **Deve aparecer uma lista de sugestões de endereços**

## ❌ Se não funcionar:

### Erro: "This API project is not authorized"
- **Solução**: Habilite as APIs (Places API e Geocoding API)

### Erro: "RefererNotAllowedMapError" (Web)
- **Solução**: Verifique se adicionou `http://localhost` nas restrições do Browser key

### Erro: "API key not valid" (Android)
- **Solução**: Verifique se o SHA-1 está correto na Android key

### Nenhuma sugestão aparece
- Aguarde 2-5 minutos (pode levar tempo para propagar)
- Verifique o console do navegador para erros
- Certifique-se de que as APIs estão habilitadas

## 🎉 Se funcionar:

Você verá:
- Uma lista de endereços aparecendo enquanto digita
- Ao clicar em um endereço, ele será selecionado
- Um check verde aparecerá indicando que o endereço foi selecionado
- As coordenadas serão obtidas automaticamente








