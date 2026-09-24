@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion
title Banco de Imagens - atualizando copia local

rem ------------------------------------------------------------------
rem  Banco de Imagens VLI
rem  O Chrome nao consegue ler as imagens direto da pasta sincronizada
rem  do SharePoint. Este atalho mantem uma copia local atualizada
rem  (pasta "imagens", ao lado deste arquivo), troca os arquivos de
rem  analise compartilhada com o SharePoint e abre o app.
rem  Nao instala nada. Nao apaga nada no SharePoint.
rem ------------------------------------------------------------------

set "APPDIR=%~dp0"
set "CFG=%APPDIR%origem.txt"
set "DEST=%APPDIR%imagens"
set "IDX=.banco-imagens"

if exist "%CFG%" goto ler_origem

:perguntar
echo.
echo  Informe a pasta de imagens do SharePoint.
echo  Pode ser a pasta principal: todas as subpastas entram.
echo  Ao trocar de pasta, a copia local passa a ter so as imagens da nova pasta.
echo  Dica: no Explorador de Arquivos, abra a pasta, clique na barra de
echo  endereco, copie o caminho (Ctrl+C) e cole aqui (botao direito).
echo.
set "ORIGEM="
set /p "ORIGEM=Caminho da pasta: "
set "ORIGEM=!ORIGEM:"=!"
if "!ORIGEM!"=="" goto perguntar
if "!ORIGEM:~-1!"=="\" set "ORIGEM=!ORIGEM:~0,-1!"
if not exist "!ORIGEM!\" (
  echo.
  echo  Pasta nao encontrada: !ORIGEM!
  goto perguntar
)
> "%CFG%" echo(!ORIGEM!
goto copiar

:ler_origem
set /p ORIGEM=<"%CFG%"
if not exist "!ORIGEM!\" (
  echo.
  echo  A pasta salva nao existe mais: !ORIGEM!
  del "%CFG%" >nul 2>&1
  goto perguntar
)
echo.
echo  Pasta de origem salva: !ORIGEM!
choice /c UT /n /t 15 /d U /m "  [U] Usar esta pasta   [T] Trocar de pasta   (usa esta em 15 s): "
if errorlevel 2 goto perguntar

:copiar
echo.
echo  Origem : !ORIGEM!
echo  Copia  : %DEST%
echo.
echo  [1/3] Copiando imagens novas ou alteradas...
echo        Na primeira vez pode demorar; depois so copia o que mudou.
rem /MIR espelha (remove da copia o que foi apagado no SharePoint).
rem /XD protege a pasta de analise e evita copiar a propria copia (se o app estiver dentro da pasta do SharePoint).
robocopy "!ORIGEM!" "%DEST%" *.jpg *.jpeg *.jfif *.png *.gif *.webp *.avif *.bmp *.svg *.heic *.heif *.tif *.tiff /MIR /XD "%IDX%" "%DEST%" "%APPDIR:~0,-1%" /R:1 /W:1 /NFL /NDL /NJH /NP
if %ERRORLEVEL% GEQ 8 (
  echo.
  echo  Houve erro ao copiar algumas imagens ^(codigo %ERRORLEVEL%^). O app vai abrir com o que foi copiado.
)

echo  [2/3] Trocando analise compartilhada com o SharePoint...
rem Cada computador grava so os proprios arquivos; /XO mantem sempre a versao mais nova.
if exist "%DEST%\%IDX%\" robocopy "%DEST%\%IDX%" "!ORIGEM!\%IDX%" /E /XO /R:1 /W:1 /NFL /NDL /NJH /NJS /NP >nul
if exist "!ORIGEM!\%IDX%\" robocopy "!ORIGEM!\%IDX%" "%DEST%\%IDX%" /E /XO /R:1 /W:1 /NFL /NDL /NJH /NJS /NP >nul

echo  [3/3] Abrindo o Banco de Imagens...
echo.
echo  No app: clique em "Reabrir" ou em "Abrir pasta" e escolha a pasta:
echo     %DEST%
echo  Para enviar sua analise para a equipe, rode este atalho de novo depois de analisar.
echo.
set "NAVEGADOR=msedge"
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe" >nul 2>&1 && set "NAVEGADOR=chrome"
reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe" >nul 2>&1 && set "NAVEGADOR=chrome"
start "" !NAVEGADOR! "%APPDIR%index.html"
timeout /t 12 >nul
