@echo off
setlocal ENABLEDELAYEDEXPANSION

:: ==== Comprobación de administrador ====
net session >nul 2>&1
if not %errorlevel%==0 (
  echo [!] Ejecuta este archivo como ADMINISTRADOR.
  pause
  exit /b 1
)

:: ==== Carpeta y nombre de reporte ====
for /f "tokens=1-4 delims=/ " %%a in ("%date%") do (set _D=%%d%%b%%c)
for /f "tokens=1-2 delims=: " %%a in ("%time%") do (set _T=%%a%%b)
set _T=%_T: =0%
set OUTDIR=%SystemDrive%\SecReport
set OUT=%OUTDIR%\reporte_seguridad_%_D%_%_T%.txt

if not exist "%OUTDIR%" mkdir "%OUTDIR%"

echo =============================================================== > "%OUT%"
echo  REPORTE RAPIDO DE SEGURIDAD - WINDOWS (CMD)                 >> "%OUT%"
echo =============================================================== >> "%OUT%"
echo  Equipo   : %COMPUTERNAME%                                     >> "%OUT%"
echo  Usuario  : %USERNAME%                                         >> "%OUT%"
echo  Fecha    : %DATE%  %TIME%                                     >> "%OUT%"
echo  SO/Build :                                                     >> "%OUT%"
ver >> "%OUT%"
echo. >> "%OUT%"

:: ==== 1) Procesos ====
echo [1] PROCESOS (tasklist /v) ===================================== >> "%OUT%"
tasklist /v >> "%OUT%"
echo. >> "%OUT%"

echo [1.1] PROCESOS + RUTA COMPLETA (WMIC) ========================== >> "%OUT%"
wmic process get Name,ProcessId,ParentProcessId,ExecutablePath,CommandLine >> "%OUT%"
echo. >> "%OUT%"

echo [1.2] SVCHOST FUERA DE SYSTEM32 (SOSPECHOSOS) ================== >> "%OUT%"
wmic process where "name='svchost.exe' and not ExecutablePath like '%%\\System32\\svchost.exe%%'" get Name,ProcessId,ExecutablePath >> "%OUT%"
echo. >> "%OUT%"

echo [1.3] PROCESOS DESDE AppData o Temp (SOSPECHOSOS) ============== >> "%OUT%"
wmic process get Name,ProcessId,ExecutablePath | findstr /I ":\Users\ :\Temp\" >> "%OUT%"
echo. >> "%OUT%"

:: ==== 2) Servicios hospedados en svchost ====
echo [2] TASKLIST /SVC (servicios por proceso) ====================== >> "%OUT%"
tasklist /svc >> "%OUT%"
echo. >> "%OUT%"

:: ==== 3) Conexiones de red ====
echo [3] NETSTAT -ANO (conexiones y PID) ============================ >> "%OUT%"
netstat -ano >> "%OUT%"
echo. >> "%OUT%"

:: ==== 4) Inicio automático (Run) ====
echo [4] PROGRAMAS EN INICIO (HKLM/HKCU Run) ======================== >> "%OUT%"
reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /s >> "%OUT%" 2>&1
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /s >> "%OUT%" 2>&1
echo. >> "%OUT%"

:: ==== 5) Tareas programadas ====
echo [5] TAREAS PROGRAMADAS (schtasks) ============================== >> "%OUT%"
schtasks /query /fo LIST /v >> "%OUT%"
echo. >> "%OUT%"

:: ==== 6) Servicios y controladores ====
echo [6] SERVICIOS (todos) ========================================= >> "%OUT%"
sc query type= service state= all >> "%OUT%"
echo. >> "%OUT%"

echo [6.1] CONTROLADORES (drivers) ================================== >> "%OUT%"
sc query type= driver state= all >> "%OUT%"
echo. >> "%OUT%"

:: ==== 7) Archivos recientes en TEMP del usuario ====
echo [7] TEMP del usuario (archivos mas recientes) ================== >> "%OUT%"
dir /a:-d /o:-d "%TEMP%" >> "%OUT%"
echo. >> "%OUT%"

:: ==== 8) Hash y firma digital de binarios en ejecucion (PowerShell) ====
echo [8] HASH SHA-256 + FIRMA DIGITAL DE PROCESOS =================== >> "%OUT%"
powershell -NoLogo -NoProfile -Command ^
  "$ErrorActionPreference='SilentlyContinue';" ^
  "Get-Process | ForEach-Object {" ^
  "  try { if ($_.Path) {" ^
  "    $sig = Get-AuthenticodeSignature -FilePath $_.Path;" ^
  "    $hash = (Get-FileHash -Path $_.Path -Algorithm SHA256).Hash;" ^
  "    [PSCustomObject]@{Name=$_.Name; Id=$_.Id; Path=$_.Path; IsSigned=($sig.Status -eq 'Valid'); Signer=$sig.SignerCertificate.Subject; HashSHA256=$hash}" ^
  "  } } catch {} } | Sort-Object Name | Format-Table -AutoSize | Out-String -Width 4096" >> "%OUT%"

echo. >> "%OUT%"
echo ===== FIN DEL REPORTE ========================================== >> "%OUT%"
echo Archivo generado: %OUT%
echo.
echo Abriendo carpeta del reporte...
start "" "%OUTDIR%"

endlocal
