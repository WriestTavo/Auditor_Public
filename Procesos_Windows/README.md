# Auditor_Public — Herramienta de diagnóstico rápido de procesos y conexiones (Windows)

> **Resumen rápido:** este repo contiene un script `.bat` que genera un reporte con procesos, rutas de ejecutables, servicios, conexiones de red, tareas programadas y hash/firma digital de binarios en uso. El resultado se guarda en `C:\SecReport\reporte_seguridad_YYYYMMDD_HHMM.txt`.

Repositorio: **https://github.com/WriestTavo/Auditor_Public**

---

## 1) Introducción
Este README explica qué hace el script, por qué es útil, cómo instalarlo y ejecutarlo, y cómo interpretar las salidas más importantes. Está dirigido a admins y usuarios avanzados que quieran una verificación rápida del estado de procesos y conexiones en Windows.

## 2) Propósito
- Recolectar evidencia y estado del sistema para análisis forense básico.
- Detectar `svchost.exe` fuera de `System32` y procesos corriendo desde `AppData`/`Temp`.
- Volcar conexiones de red (con PID) para cruzarlas con procesos.
- Generar hash SHA‑256 y verificar firma digital de binarios (PowerShell).
- Dejar un reporte legible y archivarlo fácilmente.

## 3) ¿Para qué sirve?
- Diagnóstico inicial ante sospecha de infección o actividad de red extraña.
- Recolección de info antes de un escaneo profundo o de escalar a un equipo de respuesta.
- Auditoría periódica automatizada.

## 4) Contenido
- `reporte_seguridad.bat` — script principal (genera `C:\SecReport\reporte_seguridad_YYYYMMDD_HHMM.txt`)
- `README.md` — este archivo.

## 5) Requisitos
- Windows 10/11 (o Server reciente).
- **Administrador** para ejecutar.
- PowerShell (incluido por defecto en Windows).
- Herramientas nativas: `wmic`, `tasklist`, `netstat`, `sc`, `schtasks` y PowerShell.

## 6) Instalación
1. Descarga `reporte_seguridad.bat` y colócalo en `C:\Herramientas\` (o tu carpeta preferida).
2. No requiere instalación extra.

## 7) Ejecución
1. Clic derecho → **Ejecutar como administrador** sobre `reporte_seguridad.bat`.
2. Espera a que termine (puede tardar unos minutos).
3. El informe se guardará en `C:\SecReport` y abrirá la carpeta automáticamente.

## 8) Comandos útiles (manuales)

### 8.1 Volcar conexiones y cruzar con procesos
```cmd
netstat -abno > C:\SecReport\conexiones.txt
```

### 8.2 Ver ruta del proceso por PID
Sustituye `<PID>` por el número:
```cmd
wmic process where "processid=<PID>" get Name,ExecutablePath,CommandLine
```

### 8.3 Escaneo completo con Microsoft Defender
```cmd
"%ProgramFiles%\Windows Defender\MpCmdRun.exe" -Scan -ScanType 2
```
Actualizar firmas:
```cmd
"%ProgramFiles%\Windows Defender\MpCmdRun.exe" -SignatureUpdate
```

## 9) Interpretación rápida
- **[1.2] `svchost` fuera de System32** → si aparece, investigar.
- **[1.3] AppData/Temp** → sospechoso si el binario principal vive ahí.
- **NETSTAT** → `ESTABLISHED` a IPs desconocidas/extrañas = revisar.
- **Firma/Hash** → binarios no firmados y desconocidos = alerta.

## 10) Acciones rápidas
- Matar proceso por PID:
```cmd
taskkill /F /PID <PID>
```
- Firma digital (PowerShell):
```powershell
Get-AuthenticodeSignature -FilePath "C:\ruta\archivo.exe"
```
- Hash SHA256 (PowerShell):
```powershell
Get-FileHash -Path "C:\ruta\archivo.exe" -Algorithm SHA256
```

## 11) Dónde quedan los reportes
- Carpeta: `C:\SecReport`
- Archivos: `reporte_seguridad_YYYYMMDD_HHMM.txt` y, si ejecutaste netstat manual, `conexiones.txt`.

## 12) Cómo descargar desde GitHub

**Opción A — Descargar ZIP (interfaz web):**
1. Abre: https://github.com/WriestTavo/Auditor_Public
2. Haz clic en **Code** → **Download ZIP**.
3. Extrae el ZIP y usa los archivos.

**Opción B — Git (clonar repo):**
```bash
git clone https://github.com/WriestTavo/Auditor_Public.git
cd Auditor_Public
```

**Opción C — Descargar solo `README.md` (PowerShell):**
```powershell
Invoke-WebRequest `
  -Uri "https://raw.githubusercontent.com/WriestTavo/Auditor_Public/refs/heads/main/README.md" `
  -OutFile "$env:USERPROFILE\Downloads\README.md"
```

**Opción D — Descargar solo `README.md` (curl):**
```bash
curl -L "https://raw.githubusercontent.com/WriestTavo/Auditor_Public/refs/heads/main/README.md" -o README.md
```

---

## 13) Seguridad y límites
- Es una herramienta de **diagnóstico inicial**; no reemplaza un análisis forense completo.
- Ejecuta como admin para resultados completos.
- `netstat -b` puede requerir permisos elevados para mostrar binarios.

## 14) Próximos pasos (opcionales)
- Script PowerShell en tiempo real que alerte cuando un proceso inicie conexiones externas.
- Exportar a CSV procesos no firmados.
- Paquete ZIP con los reportes recientes.

---

**Autor:** Gustavo (WriestTavo)  
**Colaboración:** ChatGPT — soporte técnico y documentación
