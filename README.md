# Descontai (IFPI App)

Aplicativo Flutter para ofertas e descontos com dois perfis (comprador e empresa), autenticacao Firebase, cadastro de produtos, upload de imagens e analytics basicos.

## Stack

- Flutter
- Firebase Auth
- Cloud Firestore
- Firebase Storage
- Google Places / Geocoding

## Pre-requisitos

- Flutter (stable)
- Firebase CLI (`npm i -g firebase-tools`)
- Projeto Firebase configurado (Auth, Firestore e Storage)
- Android SDK / Xcode (para mobile)

## Instalar dependencias

```bash
flutter pub get
```

## Configurar chaves Google Maps/Places

As chaves foram removidas do codigo. Configure via `--dart-define`:

- `GOOGLE_MAPS_API_KEY_WEB`
- `GOOGLE_MAPS_API_KEY_MOBILE`

Exemplos:

```bash
flutter run -d chrome --dart-define=GOOGLE_MAPS_API_KEY_WEB=SUA_CHAVE_WEB
flutter run -d emulator-5554 --dart-define=GOOGLE_MAPS_API_KEY_MOBILE=SUA_CHAVE_MOBILE
```

Ou passe as duas:

```bash
flutter run --dart-define=GOOGLE_MAPS_API_KEY_WEB=SUA_CHAVE_WEB --dart-define=GOOGLE_MAPS_API_KEY_MOBILE=SUA_CHAVE_MOBILE
```

## Rodar o app

```bash
flutter run
```

Dispositivos especificos:

```bash
flutter run -d chrome
flutter run -d windows
flutter run -d emulator-5554
flutter run -d ios
```

## Regras do Firebase

Arquivos locais de regras:

- `firestore.rules`
- `storage.rules`

Publicar via Firebase CLI:

```bash
firebase login
firebase use <seu-projeto>
firebase deploy --only firestore:rules,storage
```

Tambem pode publicar pelo Firebase Console:

- Firestore > Rules
- Storage > Rules

## Qualidade (recomendado)

```bash
flutter analyze
flutter test
```

## Estrutura (resumo)

- `lib/main.dart`: bootstrap e rotas
- `lib/auth_screens.dart`: login/cadastro/recuperacao
- `lib/dashboard_screens.dart`: dashboards comprador/empresa
- `lib/services/`: auth, produtos, analytics, tema e geocoding
- `lib/widgets/`: componentes reutilizaveis

## Observacoes

- Upload de imagens usa caminho `produtos/{empresaId}/...` no Storage
- Regras do Storage permitem leitura publica das imagens e escrita apenas pela empresa dona
- Restrinja as API keys do Google Cloud por dominio/plataforma
