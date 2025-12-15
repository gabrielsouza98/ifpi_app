# Guia: Como Configurar Restrições da API Key do Google Maps

## Passo a Passo Detalhado

### 1. Acessar as Credenciais

1. Acesse o **Google Cloud Console**: https://console.cloud.google.com/
2. Certifique-se de estar no projeto correto: **ifpi-app**
3. No menu lateral esquerdo, clique em:
   - **APIs e serviços** > **Credenciais**

### 2. Localizar a API Key

1. Na lista de credenciais, procure pela API Key:
   - `AIzaSyDkqbEZ-q020wOXE--9HvLRD0wwlfMfbmc`
   - Ou qualquer outra API Key que você esteja usando

2. **Clique no nome da API Key** (não no ícone de copiar)

### 3. Configurar Restrições de API

Na página de edição da API Key, você verá duas seções de restrições:

#### a) Restrições de API

1. Localize a seção **"Restrições de API"**
2. Selecione a opção: **"Restringir chave"**
3. Uma lista de APIs aparecerá
4. **Marque APENAS as APIs que você usa**:
   - ✅ **Places API (New)** ou **Places API**
   - ✅ **Geocoding API**
   - ✅ **Maps JavaScript API** (opcional, se usar no futuro)
5. Clique em **"Salvar"** no final da página

**Por que fazer isso?**
- Evita que a API Key seja usada para outras APIs não autorizadas
- Reduz o risco de uso indevido
- Economiza créditos/recursos

### 4. Configurar Restrições de Aplicativo

#### Para Desenvolvimento Web (localhost):

1. Localize a seção **"Restrições de aplicativo"**
2. Selecione: **"Referenciadores HTTP (websites)"**
3. Clique em **"+ Adicionar um item"**
4. Adicione os seguintes referenciadores (um por linha):
   ```
   http://localhost:*
   http://127.0.0.1:*
   ```
   - O `*` permite qualquer porta (56708, 8080, etc.)

#### Para Produção Web:

1. Adicione também os domínios de produção:
   ```
   https://seu-dominio.com/*
   https://*.seu-dominio.com/*
   ```
   - Substitua `seu-dominio.com` pelo seu domínio real

#### Para Aplicativos Android:

1. Selecione: **"Aplicativos Android"**
2. Clique em **"+ Adicionar um item"**
3. Informe:
   - **Nome do pacote**: `com.example.app_ifpi`
   - **Impressão digital do certificado SHA-1**: (obtenha com o comando abaixo)

**Como obter o SHA-1 para Android:**
```bash
# No Windows (PowerShell):
cd android
.\gradlew signingReport

# Procure por "SHA1:" na saída
```

#### Para Aplicativos iOS:

1. Selecione: **"Aplicativos iOS"**
2. Adicione o **ID do pacote**: `com.example.appIfpi`

### 5. Salvar as Alterações

1. Role até o final da página
2. Clique no botão **"Salvar"**
3. Aguarde a confirmação (pode levar alguns segundos)

### 6. Verificar se Funcionou

Após salvar, teste o aplicativo:

1. **Para Web:**
   - Execute: `flutter run -d chrome`
   - Tente cadastrar uma empresa
   - Digite um endereço no campo de busca
   - Verifique se as sugestões aparecem

2. **Se der erro:**
   - Verifique se adicionou `http://localhost:*` nas restrições
   - Verifique se as APIs estão habilitadas
   - Aguarde alguns minutos (pode levar tempo para propagar)

## Exemplo Visual da Configuração

```
┌─────────────────────────────────────────┐
│  Editar chave de API                    │
├─────────────────────────────────────────┤
│                                         │
│  Nome: Minha API Key                    │
│  Chave de API: AIzaSy...               │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │ Restrições de aplicativo          │ │
│  │ ○ Nenhuma                         │ │
│  │ ● Referenciadores HTTP (websites) │ │
│  │                                   │ │
│  │ Referenciadores:                 │ │
│  │ http://localhost:*                │ │
│  │ http://127.0.0.1:*                │ │
│  │ + Adicionar um item               │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │ Restrições de API                 │ │
│  │ ○ Nenhuma                         │ │
│  │ ● Restringir chave                │ │
│  │                                   │ │
│  │ ☑ Places API (New)               │ │
│  │ ☑ Geocoding API                   │ │
│  │ ☐ Maps JavaScript API            │ │
│  │ ☐ Outras APIs...                 │ │
│  └───────────────────────────────────┘ │
│                                         │
│  [Cancelar]  [Salvar]                  │
└─────────────────────────────────────────┘
```

## Dicas Importantes

### ⚠️ Atenção:
- **Não restrinja demais**: Se restringir apenas para produção, não funcionará em desenvolvimento
- **Teste sempre**: Após configurar, teste imediatamente
- **Propagação**: Mudanças podem levar até 5 minutos para propagar

### 🔒 Segurança:
- **Nunca commite a API Key no Git**: Use variáveis de ambiente
- **Revise periodicamente**: Verifique o uso da API Key no console
- **Monitore custos**: Configure alertas de faturamento

### 🚀 Para Produção:
- Use **Cloud Functions** do Firebase para esconder a API Key
- Configure restrições mais específicas
- Use diferentes API Keys para desenvolvimento e produção

## Troubleshooting

### Erro: "RefererNotAllowedMapError"
**Causa**: O domínio não está nas restrições  
**Solução**: Adicione `http://localhost:*` nas restrições de aplicativo

### Erro: "This API project is not authorized"
**Causa**: A API não está habilitada  
**Solução**: Vá em "APIs e serviços" > "Biblioteca" e habilite a API

### Erro: "API key not valid"
**Causa**: API Key incorreta ou restrições muito restritivas  
**Solução**: Verifique a API Key e as restrições configuradas

## Links Úteis

- Console de Credenciais: https://console.cloud.google.com/apis/credentials
- Documentação: https://developers.google.com/maps/api-security-best-practices








