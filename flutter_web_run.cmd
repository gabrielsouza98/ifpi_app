
@echo off
REM flutter_web_run.cmd
REM Pré-visualizar app Flutter no iPhone via Flutter Web (HTTP local)
REM Uso:
REM   1) Abra o CMD na pasta do seu projeto Flutter.
REM   2) Execute: flutter_web_run.cmd

for /f "tokens=14" %%i in ('ipconfig ^| findstr /i "IPv4"') do set IP=%%i
if "%IP%"=="" set IP=127.0.0.1
set PORT=8080

echo ==^> Habilitando Flutter Web (uma vez so)...
flutter config --enable-web >nul

echo ==^> Verificando devices Web...
flutter devices

echo ==^> Servindo app em http://%IP%:%PORT%
echo Se aparecer a janela do Firewall do Windows, permita acesso em Rede Privada.
flutter run -d web-server --web-hostname 0.0.0.0 --web-port %PORT%
