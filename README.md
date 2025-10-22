# app_ifpi

Aplicativo Flutter inicial do IFPI.

## Como rodar

Pré-requisitos:

- Flutter instalado (canal stable)
- Android SDK/Xcode caso vá rodar em mobile

Comandos:

```bash
flutter pub get
flutter run        # detecta dispositivo/simulador
# ou escolha um:
flutter run -d chrome   # Web
flutter run -d windows  # Windows
flutter run -d android  # Android
flutter run -d ios      # iOS
```

## Estrutura

- `lib/main.dart`: ponto de entrada, tema e tela inicial.
- `pubspec.yaml`: dependências e configurações Flutter.

## Links úteis

- [Codelab: seu primeiro app Flutter](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: exemplos úteis](https://docs.flutter.dev/cookbook)
- [Documentação Flutter](https://docs.flutter.dev/)
