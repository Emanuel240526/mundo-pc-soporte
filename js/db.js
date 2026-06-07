/**
 * db.js — Capa de base de datos para mundo pc Pro v2.0
 *
 * Modo actual: localStorage (desarrollo)
 * Para conectar a SQL Server: cambia CONFIG.modo a 'api' y apunta CONFIG.apiBase a tu backend ASP.NET
 */

const DB = (() => {

  const CONFIG = {
    modo: 'local',
    apiBase: 'http://localhost:5000/api',
  };

  // ============================================================
  // SEED COMPLETO — espejo del soporte.sql
  // ============================================================
  const SEED = {

    categorias: [
      { id:1,  nombre:'Rendimiento',           icono:'⚡', descripcion:'PC lenta, sobrecalentamiento, lag, congelamiento' },
      { id:2,  nombre:'Pantalla / Video',       icono:'🖥', descripcion:'Problemas de imagen, resolución, parpadeo, drivers GPU' },
      { id:3,  nombre:'Red / Internet',         icono:'🌐', descripcion:'Sin conexión, lentitud de red, WiFi, VPN, DNS' },
      { id:4,  nombre:'Audio',                  icono:'🔊', descripcion:'Sin sonido, distorsión, micrófono, auriculares' },
      { id:5,  nombre:'Software / SO',          icono:'💻', descripcion:'Windows, Linux, macOS, errores del sistema, drivers' },
      { id:6,  nombre:'Hardware',               icono:'🔧', descripcion:'Teclado, mouse, USB, RAM, disco, fuente de poder' },
      { id:7,  nombre:'Almacenamiento',         icono:'💾', descripcion:'Disco lleno, SSD lento, errores SMART, particiones' },
      { id:8,  nombre:'Seguridad',              icono:'🔒', descripcion:'Virus, malware, ransomware, contraseñas, phishing' },
      { id:9,  nombre:'Impresoras',             icono:'🖨', descripcion:'No imprime, atascos de papel, drivers, conexión' },
      { id:10, nombre:'Correo / Office',        icono:'📧', descripcion:'Outlook, Gmail, Word, Excel, PowerPoint, licencias' },
      { id:11, nombre:'Windows Server',         icono:'🖧', descripcion:'Active Directory, DNS Server, DHCP, IIS, roles' },
      { id:12, nombre:'Programación / Dev',     icono:'⌨', descripcion:'IDEs, Git, compiladores, depuración, entornos' },
      { id:13, nombre:'Móviles / Tablets',      icono:'📱', descripcion:'Android, iOS, sincronización, aplicaciones, batería' },
      { id:14, nombre:'Energía / Electricidad', icono:'🔌', descripcion:'UPS, cortes de luz, sobretensiones, fuente de poder' },
      { id:15, nombre:'Videoconferencias',      icono:'📹', descripcion:'Zoom, Teams, Meet, cámara, micrófono, conexión' },
    ],

    problemas: [
      // RENDIMIENTO
      { id:1,  categoria_id:1, nombre:'La PC está muy lenta al iniciar' },
      { id:2,  categoria_id:1, nombre:'El ventilador hace ruido excesivo / sobrecalentamiento' },
      { id:3,  categoria_id:1, nombre:'Programas se congelan o no responden' },
      { id:4,  categoria_id:1, nombre:'CPU al 100% sin razón aparente' },
      { id:5,  categoria_id:1, nombre:'La PC tarda mucho en apagarse' },
      { id:6,  categoria_id:1, nombre:'Poca memoria RAM disponible' },
      { id:7,  categoria_id:1, nombre:'El equipo se reinicia solo' },
      { id:8,  categoria_id:1, nombre:'Juegos o programas pesados van lentos' },
      { id:9,  categoria_id:1, nombre:'La PC está lenta después de una actualización' },
      { id:10, categoria_id:1, nombre:'Temperatura muy alta en reposo' },
      // PANTALLA
      { id:11, categoria_id:2, nombre:'Pantalla en negro al encender' },
      { id:12, categoria_id:2, nombre:'Pantalla parpadea constantemente' },
      { id:13, categoria_id:2, nombre:'Resolución incorrecta o pixelada' },
      { id:14, categoria_id:2, nombre:'Artefactos visuales / rayas en pantalla' },
      { id:15, categoria_id:2, nombre:'Monitor externo no es detectado' },
      { id:16, categoria_id:2, nombre:'Brillo de pantalla no se ajusta' },
      { id:17, categoria_id:2, nombre:'Pantalla con colores incorrectos' },
      { id:18, categoria_id:2, nombre:'Driver de tarjeta de video falla' },
      { id:19, categoria_id:2, nombre:'Pantalla se apaga sola' },
      // RED
      { id:20, categoria_id:3, nombre:'Sin acceso a internet' },
      { id:21, categoria_id:3, nombre:'WiFi se desconecta constantemente' },
      { id:22, categoria_id:3, nombre:'Internet muy lento' },
      { id:23, categoria_id:3, nombre:'No puede conectarse a la red WiFi' },
      { id:24, categoria_id:3, nombre:'VPN no conecta o se cae' },
      { id:25, categoria_id:3, nombre:'Error de DNS / páginas no cargan' },
      { id:26, categoria_id:3, nombre:'Dirección IP en conflicto' },
      { id:27, categoria_id:3, nombre:'No hay internet solo en un equipo' },
      { id:28, categoria_id:3, nombre:'Proxy o firewall bloquea acceso' },
      // AUDIO
      { id:29, categoria_id:4, nombre:'Sin sonido en absoluto' },
      { id:30, categoria_id:4, nombre:'Sonido con distorsión o ruido de fondo' },
      { id:31, categoria_id:4, nombre:'Micrófono no funciona' },
      { id:32, categoria_id:4, nombre:'Auriculares no se detectan' },
      { id:33, categoria_id:4, nombre:'Sonido sale por altavoces y auriculares a la vez' },
      { id:34, categoria_id:4, nombre:'Driver de audio falla o desaparece' },
      { id:35, categoria_id:4, nombre:'Volumen baja o sube solo' },
      // SOFTWARE
      { id:36, categoria_id:5, nombre:'Pantalla azul de la muerte (BSOD)' },
      { id:37, categoria_id:5, nombre:'Windows no inicia o entra en bucle' },
      { id:38, categoria_id:5, nombre:'Actualizaciones de Windows fallan' },
      { id:39, categoria_id:5, nombre:'Driver de dispositivo no funciona' },
      { id:40, categoria_id:5, nombre:'El Explorador de archivos se cierra solo' },
      { id:41, categoria_id:5, nombre:'Aplicación no abre o da error' },
      { id:42, categoria_id:5, nombre:'Registro de Windows dañado' },
      { id:43, categoria_id:5, nombre:'Permisos de archivos o carpetas bloqueados' },
      { id:44, categoria_id:5, nombre:'Windows no activa o licencia inválida' },
      { id:45, categoria_id:5, nombre:'Reloj del sistema desincronizado' },
      // HARDWARE
      { id:46, categoria_id:6, nombre:'Teclado no responde o pierde teclas' },
      { id:47, categoria_id:6, nombre:'Mouse no funciona o salta' },
      { id:48, categoria_id:6, nombre:'Puerto USB no reconoce dispositivos' },
      { id:49, categoria_id:6, nombre:'PC no enciende al presionar el botón' },
      { id:50, categoria_id:6, nombre:'Pantalla de POST / BIOS falla' },
      { id:51, categoria_id:6, nombre:'RAM no es detectada o falla' },
      { id:52, categoria_id:6, nombre:'Fuente de poder hace ruido o falla' },
      { id:53, categoria_id:6, nombre:'Disco duro hace ruido (click / grinding)' },
      { id:54, categoria_id:6, nombre:'Puertos HDMI o DisplayPort dañados' },
      // ALMACENAMIENTO
      { id:55, categoria_id:7, nombre:'Disco duro lleno' },
      { id:56, categoria_id:7, nombre:'Error al leer o escribir en disco' },
      { id:57, categoria_id:7, nombre:'SSD lento o se degrada' },
      { id:58, categoria_id:7, nombre:'Archivos corrompidos o inaccesibles' },
      { id:59, categoria_id:7, nombre:'Disco no aparece en el sistema' },
      { id:60, categoria_id:7, nombre:'Partición dañada o perdida' },
      { id:61, categoria_id:7, nombre:'SMART alerta de fallo inminente en disco' },
      { id:62, categoria_id:7, nombre:'Papelera de reciclaje no se vacía' },
      // SEGURIDAD
      { id:63, categoria_id:8, nombre:'Posible virus o malware' },
      { id:64, categoria_id:8, nombre:'Ransomware: archivos cifrados' },
      { id:65, categoria_id:8, nombre:'Cuenta de correo o red social hackeada' },
      { id:66, categoria_id:8, nombre:'Sospechas de phishing o estafa' },
      { id:67, categoria_id:8, nombre:'El antivirus fue desactivado' },
      { id:68, categoria_id:8, nombre:'Contraseña olvidada del sistema' },
      { id:69, categoria_id:8, nombre:'Spyware o adware instalado' },
      // IMPRESORAS
      { id:70, categoria_id:9, nombre:'Impresora no imprime nada' },
      { id:71, categoria_id:9, nombre:'Atasco de papel en impresora' },
      { id:72, categoria_id:9, nombre:'Impresora no es detectada por la PC' },
      { id:73, categoria_id:9, nombre:'Impresión con rayas o manchas' },
      { id:74, categoria_id:9, nombre:'Impresora dice sin tinta pero tiene' },
      // CORREO / OFFICE
      { id:75, categoria_id:10, nombre:'Outlook no abre o se congela' },
      { id:76, categoria_id:10, nombre:'No puede enviar o recibir correos' },
      { id:77, categoria_id:10, nombre:'Excel se cierra solo o pierde datos' },
      { id:78, categoria_id:10, nombre:'Word no guarda o da error de archivo' },
      { id:79, categoria_id:10, nombre:'Licencia de Office expirada o inválida' },
      // VIDEOCONFERENCIAS
      { id:80, categoria_id:15, nombre:'Cámara no funciona en Zoom o Teams' },
    ],

    soluciones: [
      {
        id:1, problema_id:1,
        titulo:'Optimización completa del inicio de Windows',
        resumen:'Deshabilitar programas de inicio, limpiar temporales y optimizar servicios.',
        pasos:[
          'Presiona Ctrl+Shift+Esc y ve a la pestaña "Inicio"',
          'Deshabilita todos los programas que no necesitas en el arranque',
          'Abre Ejecutar (Win+R) y escribe services.msc',
          'Deshabilita servicios no esenciales: SysMain, Connected User Experiences, Xbox Services',
          'Abre cleanmgr.exe y limpia archivos temporales, miniaturas y archivos del sistema',
          'Desfragmenta el disco si es HDD (no SSD): en el buscador escribe "Desfragmentar"',
          'Reinicia y mide el tiempo de inicio'
        ],
        herramientas:['Administrador de tareas','CCleaner (opcional)','Autoruns de Sysinternals'],
        comandos:['msconfig','services.msc','cleanmgr','powercfg /energy'],
        advertencias:['No deshabilites servicios de Windows Defender ni de red'],
        dificultad:'facil', tiempo_minutos:20, requiere_reinicio:true, requiere_admin:true,
        notas:'Si el tiempo de inicio supera 2 minutos con SSD, puede ser un problema de hardware o drivers.'
      },
      {
        id:2, problema_id:2,
        titulo:'Solución de sobrecalentamiento y ruido de ventiladores',
        resumen:'Limpieza de polvo, aplicación de pasta térmica y ajuste de curvas de ventiladores.',
        pasos:[
          'Apaga completamente el equipo y desconéctalo de la corriente',
          'Abre el gabinete y usa aire comprimido para limpiar todos los ventiladores y rejillas',
          'Instala HWMonitor y verifica temperaturas en tiempo real',
          'Si la CPU supera 90°C en reposo: retira el disipador, limpia la pasta vieja con alcohol isopropílico y aplica pasta nueva',
          'Descarga MSI Afterburner para controlar la curva de ventiladores manualmente',
          'Configura la curva: 50% velocidad a 60°C, 80% a 75°C, 100% a 85°C',
          'Verifica que los cables internos no obstruyan el flujo de aire'
        ],
        herramientas:['HWMonitor','MSI Afterburner','Core Temp','Aire comprimido','Pasta térmica Arctic MX-4'],
        comandos:['wmic /namespace:\\\\root\\wmi PATH MSAcpi_ThermalZoneTemperature get CurrentTemperature'],
        advertencias:['Aplica pasta térmica en cantidad de un grano de arroz, no más'],
        dificultad:'medio', tiempo_minutos:45, requiere_reinicio:false, requiere_admin:false,
        notas:'Limpieza recomendada cada 6 meses. En laptops puede ser más difícil acceder al disipador.'
      },
      {
        id:3, problema_id:3,
        titulo:'Diagnóstico y solución de programas que no responden',
        resumen:'Identificar la causa del congelamiento: RAM, disco, proceso zombie o corrupción.',
        pasos:[
          'Cuando una app se congele, espera 30 segundos antes de forzar cierre',
          'Abre el Administrador de tareas → pestaña Detalles',
          'Haz clic derecho en el proceso → End Task',
          'Abre el Visor de eventos (eventvwr.msc) → Registros de Windows → Aplicación',
          'Busca errores justo antes del congelamiento',
          'Ejecuta sfc /scannow en CMD como admin',
          'Si el problema es recurrente, reinstala la app en modo limpio',
          'Verifica que la RAM no falle con MemTest86'
        ],
        herramientas:['Administrador de tareas','Event Viewer','MemTest86','Process Explorer'],
        comandos:['taskkill /F /PID [PID]','sfc /scannow','DISM /Online /Cleanup-Image /RestoreHealth'],
        advertencias:['No uses verifier en producción sin saber qué haces'],
        dificultad:'medio', tiempo_minutos:30, requiere_reinicio:false, requiere_admin:true,
        notas:'Si múltiples programas se congelan, sospechar de RAM defectuosa o disco en mal estado.'
      },
      {
        id:4, problema_id:4,
        titulo:'Diagnóstico y solución de CPU al 100%',
        resumen:'Identificar el proceso culpable y solucionarlo sin afectar el sistema.',
        pasos:[
          'Abre el Administrador de tareas y ordena por CPU descendente',
          'Identifica el proceso con mayor consumo',
          'Si es WMI Provider Host: reinicia el servicio "Windows Management Instrumentation"',
          'Si es Antimalware Service Executable: programa el escaneo para horarios de baja actividad',
          'Desactiva el Superfetch: services.msc → SysMain → Deshabilitar',
          'Desactiva la indexación si no la usas: services.msc → Windows Search → Manual',
          'Actualiza todos los drivers, especialmente chipset y almacenamiento',
          'Ejecuta un análisis completo de malware'
        ],
        herramientas:['Process Explorer (Sysinternals)','Administrador de tareas','Malwarebytes'],
        comandos:['wmic cpu get loadpercentage','sc config SysMain start= disabled','sc stop SysMain'],
        advertencias:['No termines procesos de sistema sin estar seguro de qué hacen'],
        dificultad:'medio', tiempo_minutos:25, requiere_reinicio:false, requiere_admin:true,
        notas:'Windows Update puede causar CPU al 100% temporalmente. Espera 30 minutos antes de actuar.'
      },
      {
        id:5, problema_id:7,
        titulo:'Diagnóstico de reinicios inesperados',
        resumen:'Los reinicios pueden ser por temperatura, RAM, PSU, drivers o configuración de Windows.',
        pasos:[
          'Abre el Visor de eventos → Registros de Windows → Sistema',
          'Filtra por ID de evento 41 (Kernel-Power): indica apagado no controlado',
          'Deshabilita el reinicio automático: Propiedades de Mi PC → Configuración avanzada → Inicio y recuperación → desmarcar "Reiniciar automáticamente"',
          'Verifica temperaturas con HWMonitor durante carga',
          'Si se reinicia bajo carga: sospechar de PSU insuficiente o temperatura alta',
          'Ejecuta MemTest86 para descartar RAM defectuosa',
          'Actualiza el firmware de la BIOS/UEFI si hay versión disponible',
          'Verifica los voltajes de la PSU con HWiNFO'
        ],
        herramientas:['HWMonitor','HWiNFO','MemTest86','Event Viewer','WhoCrashed'],
        comandos:['eventvwr.msc','wevtutil qe System /q:*[System[EventID=41]] /f:text'],
        advertencias:['Si la PSU está fallando, apaga el equipo hasta reemplazarla para evitar daños'],
        dificultad:'medio', tiempo_minutos:40, requiere_reinicio:false, requiere_admin:true,
        notas:'PSU de baja calidad es causa frecuente de reinicios bajo carga en equipos con GPU dedicada.'
      },
      {
        id:6, problema_id:11,
        titulo:'Solución de pantalla en negro al encender',
        resumen:'Diagnóstico paso a paso desde el cable hasta los drivers de video.',
        pasos:[
          'Verifica que el cable HDMI/DisplayPort esté bien conectado en ambos extremos',
          'Prueba con otro cable y otro puerto del monitor',
          'Comprueba que el monitor esté seleccionado en la entrada correcta (Source/Input)',
          'Reinicia y presiona Win+Ctrl+Shift+B para restablecer el driver de video',
          'Si ves el cursor pero pantalla negra: presiona Ctrl+Alt+Supr → Administrador de tareas → Archivo → Ejecutar nueva tarea → explorer.exe',
          'Arranca en Modo Seguro y desinstala el driver de GPU con DDU',
          'Descarga el driver más reciente desde el sitio oficial de NVIDIA/AMD/Intel',
          'Si el problema persiste sin monitor externo: puede ser la pantalla o el cable interno de la laptop'
        ],
        herramientas:['DDU (Display Driver Uninstaller)','GeForce Experience o AMD Software'],
        comandos:['bcdedit /set {default} safeboot minimal','bcdedit /deletevalue {default} safeboot'],
        advertencias:['DDU debe usarse en Modo Seguro para no dejar residuos del driver anterior'],
        dificultad:'medio', tiempo_minutos:30, requiere_reinicio:true, requiere_admin:true,
        notas:'En laptops, conecta un monitor externo para determinar si el problema es la pantalla o la GPU.'
      },
      {
        id:7, problema_id:20,
        titulo:'Diagnóstico completo de sin acceso a internet',
        resumen:'Flujo de diagnóstico desde el router hasta la configuración TCP/IP del equipo.',
        pasos:[
          'Verifica las luces del router: WAN debe estar encendida y estable',
          'Reinicia el router: desconecta 30 segundos y vuelve a conectar',
          'Desde CMD ejecuta: ping 8.8.8.8 — si responde, el problema es DNS',
          'Si ping falla: ipconfig /release → ipconfig /renew',
          'Ejecuta: netsh winsock reset → reinicia el equipo',
          'Configura DNS manualmente: 8.8.8.8 y 8.8.4.4 (Google DNS)',
          'Deshabilita temporalmente el firewall de Windows para descartar bloqueos',
          'Prueba con otro dispositivo en la misma red para aislar si es el equipo o el router'
        ],
        herramientas:['CMD','Configuración de red Windows','nslookup','tracert'],
        comandos:['ping 8.8.8.8','ipconfig /release','ipconfig /renew','ipconfig /flushdns','netsh winsock reset','tracert 8.8.8.8'],
        advertencias:['netsh winsock reset puede afectar algunas aplicaciones VPN o antivirus al reiniciar'],
        dificultad:'facil', tiempo_minutos:15, requiere_reinicio:true, requiere_admin:true,
        notas:'Si solo falla en un equipo y el router funciona bien, el problema es local en ese equipo.'
      },
      {
        id:8, problema_id:21,
        titulo:'Solución para WiFi que se desconecta constantemente',
        resumen:'Problemas de driver, ahorro de energía o interferencia de canal.',
        pasos:[
          'Abre Administrador de dispositivos → Adaptadores de red → propiedades del WiFi',
          'Ve a "Administración de energía" y desmarca "Permitir que el equipo apague este dispositivo"',
          'En "Propiedades avanzadas" deshabilita el Roaming Aggressiveness',
          'Actualiza el driver del adaptador WiFi desde el sitio del fabricante',
          'Cambia el canal del router: entra a 192.168.1.1 y selecciona canal 1, 6 o 11 (2.4GHz)',
          'Olvida la red WiFi y reconéctate desde cero',
          'Usa WiFi Analyzer para ver los canales congestionados'
        ],
        herramientas:['WiFi Analyzer','Driver del fabricante del adaptador','Router admin panel'],
        comandos:['netsh wlan show interfaces','netsh wlan disconnect','netsh wlan connect name=NombreWiFi'],
        advertencias:['Cambiar el canal del router afecta a todos los dispositivos conectados'],
        dificultad:'facil', tiempo_minutos:20, requiere_reinicio:false, requiere_admin:true,
        notas:'Los adaptadores WiFi integrados en laptops baratas suelen tener drivers problemáticos.'
      },
      {
        id:9, problema_id:29,
        titulo:'Reparación completa de audio en Windows',
        resumen:'Diagnóstico desde el mezclador de volumen hasta reinstalación de drivers.',
        pasos:[
          'Haz clic derecho en el ícono de volumen → "Solucionar problemas de sonido"',
          'Verifica que el dispositivo de reproducción correcto esté como Predeterminado',
          'Haz clic derecho en el área de reproducción → "Mostrar dispositivos deshabilitados"',
          'Abre el Mezclador de volumen y verifica que ninguna aplicación esté en mute',
          'En services.msc verifica que "Windows Audio" y "Windows Audio Endpoint Builder" estén en Automático',
          'Actualiza el driver de audio desde el Administrador de dispositivos',
          'Si falla, desinstala el driver y reinicia (Windows lo reinstalará)',
          'Descarga el driver desde el sitio del fabricante de la placa madre (Realtek, etc.)'
        ],
        herramientas:['Administrador de dispositivos','services.msc','Realtek HD Audio Manager'],
        comandos:['services.msc','mmsys.cpl','sndvol'],
        advertencias:[],
        dificultad:'facil', tiempo_minutos:20, requiere_reinicio:true, requiere_admin:true,
        notas:'Si usas tarjeta de sonido dedicada, descarga el driver específico del fabricante.'
      },
      {
        id:10, problema_id:36,
        titulo:'Diagnóstico y solución de pantalla azul (BSOD)',
        resumen:'Analizar el volcado de memoria para identificar el driver o componente responsable.',
        pasos:[
          'Anota el código de STOP (ej: IRQL_NOT_LESS_OR_EQUAL, PAGE_FAULT_IN_NONPAGED_AREA)',
          'Busca el código en Google + Microsoft Docs para la causa probable',
          'Arranca en Modo Seguro: Shift + Reiniciar → Solucionar problemas → Opciones avanzadas',
          'Desde CMD como administrador ejecuta: sfc /scannow',
          'Luego: DISM /Online /Cleanup-Image /RestoreHealth',
          'Instala WhoCrashed para analizar los archivos de volcado en C:\\Windows\\Minidump',
          'Si un driver específico aparece: desinstálalo desde el Administrador de dispositivos',
          'Verifica la RAM con MemTest86 (análisis nocturno)',
          'Verifica el disco con chkdsk C: /f /r'
        ],
        herramientas:['WhoCrashed','MemTest86','CrystalDiskInfo','WinDbg Preview','Driver Booster'],
        comandos:['sfc /scannow','DISM /Online /Cleanup-Image /RestoreHealth','chkdsk C: /f /r','verifier /standard /all','verifier /reset'],
        advertencias:['verifier puede causar más BSOD si hay drivers malos; ejecuta verifier /reset después del diagnóstico'],
        dificultad:'avanzado', tiempo_minutos:60, requiere_reinicio:true, requiere_admin:true,
        notas:'Guarda los archivos .dmp de C:\\Windows\\Minidump antes de reinstalar Windows.'
      },
      {
        id:11, problema_id:37,
        titulo:'Reparación de Windows que no inicia o entra en bucle',
        resumen:'Reparar el arranque, BCD y archivos del sistema sin reinstalar Windows.',
        pasos:[
          'Arranca desde una USB de instalación de Windows (mismo idioma y versión)',
          'Selecciona Reparar el equipo → Solucionar problemas → Opciones avanzadas',
          'Intenta "Reparación de inicio automática" primero',
          'Si falla, ve a Símbolo del sistema y ejecuta bootrec /fixmbr',
          'Luego bootrec /fixboot',
          'Luego bootrec /rebuildbcd',
          'Si sigue fallando: sfc /scannow /offbootdir=C:\\ /offwindir=C:\\Windows',
          'Como último recurso: reinstalación conservando archivos personales'
        ],
        herramientas:['USB de instalación de Windows','Rufus (para crear USB booteable)'],
        comandos:['bootrec /fixmbr','bootrec /fixboot','bootrec /scanos','bootrec /rebuildbcd','bcdboot C:\\Windows /s C: /f ALL'],
        advertencias:['Ten un backup actualizado antes de cualquier operación de reparación de arranque'],
        dificultad:'avanzado', tiempo_minutos:50, requiere_reinicio:true, requiere_admin:true,
        notas:'Crea siempre una unidad de recuperación de Windows en una USB de 16GB.'
      },
      {
        id:12, problema_id:38,
        titulo:'Solución a errores de Windows Update',
        resumen:'Limpiar la caché de actualizaciones y reiniciar los servicios relacionados.',
        pasos:[
          'Ejecuta el Solucionador de problemas de Windows Update: Configuración → Sistema → Solucionar problemas',
          'Abre CMD como administrador y ejecuta: net stop wuauserv',
          'net stop cryptSvc',
          'net stop bits',
          'Renombra la carpeta de caché: ren C:\\Windows\\SoftwareDistribution SoftwareDistribution.old',
          'Reinicia los servicios: net start wuauserv, net start cryptSvc, net start bits',
          'Intenta actualizar nuevamente',
          'Si persiste, descarga la actualización manualmente desde catalog.update.microsoft.com'
        ],
        herramientas:['Windows Update Troubleshooter','Microsoft Update Catalog','DISM'],
        comandos:['net stop wuauserv','net stop bits','ren C:\\Windows\\SoftwareDistribution SoftwareDistribution.old','net start wuauserv','wuauclt /resetauthorization /detectnow'],
        advertencias:['Renombrar SoftwareDistribution fuerza la re-descarga de todas las actualizaciones pendientes'],
        dificultad:'medio', tiempo_minutos:25, requiere_reinicio:true, requiere_admin:true,
        notas:'Si el error persiste, busca el código de error en el Catálogo de Microsoft Update.'
      },
      {
        id:13, problema_id:48,
        titulo:'Solución para puerto USB que no reconoce dispositivos',
        resumen:'Desde deshabilitar el ahorro de energía USB hasta reinstalar los controladores.',
        pasos:[
          'Prueba el dispositivo USB en otro puerto del equipo',
          'Prueba el mismo dispositivo en otro equipo para descartar que el dispositivo esté dañado',
          'Abre Administrador de dispositivos → Controladores de bus serie universal',
          'Haz clic derecho en cada controlador USB y selecciona "Desinstalar dispositivo"',
          'Reinicia el equipo (Windows reinstalará los controladores automáticamente)',
          'En las propiedades de cada concentrador USB: desmarca la opción de ahorro de energía',
          'Verifica en el BIOS que los puertos USB estén habilitados',
          'Descarga el driver de chipset actualizado desde el sitio del fabricante'
        ],
        herramientas:['Administrador de dispositivos','USBDeview (NirSoft)','Driver de chipset'],
        comandos:['devmgmt.msc','pnputil /scan-devices'],
        advertencias:['Al desinstalar los controladores USB, el mouse y teclado USB dejarán de funcionar hasta el reinicio'],
        dificultad:'facil', tiempo_minutos:20, requiere_reinicio:true, requiere_admin:true,
        notas:'Los hubs USB de mala calidad o con exceso de dispositivos pueden causar este problema.'
      },
      {
        id:14, problema_id:55,
        titulo:'Liberar espacio en disco de forma segura y efectiva',
        resumen:'Limpieza sistemática: temporales, archivos del sistema, hibernación, puntos de restauración.',
        pasos:[
          'Ejecuta Liberador de espacio en disco (cleanmgr.exe) → selecciona todos los tipos',
          'Haz clic en "Limpiar archivos del sistema" para incluir actualizaciones anteriores',
          'Deshabilita la hibernación si no la usas: powercfg /hibernate off',
          'Reduce el espacio de Puntos de restauración: Panel de control → Sistema → Protección → Configurar',
          'Usa WinDirStat para visualizar qué carpetas ocupan más espacio',
          'Desinstala aplicaciones que no usas desde Configuración → Aplicaciones',
          'Mueve Documentos, Fotos y Vídeos a un disco externo o nube',
          'Vacía las carpetas: %TEMP% y C:\\Windows\\Temp'
        ],
        herramientas:['WinDirStat','TreeSize Free','7-Zip','Liberador de espacio en disco'],
        comandos:['cleanmgr.exe','del /q /f /s %TEMP%\\*','powercfg /hibernate off'],
        advertencias:['No elimines archivos de C:\\Windows ni de C:\\Program Files manualmente'],
        dificultad:'facil', tiempo_minutos:25, requiere_reinicio:false, requiere_admin:true,
        notas:'Mantén mínimo 15% libre en el disco del sistema para que Windows funcione correctamente.'
      },
      {
        id:15, problema_id:63,
        titulo:'Eliminación completa de virus y malware',
        resumen:'Proceso profesional de limpieza en múltiples capas para infecciones graves.',
        pasos:[
          'Desconecta el equipo de internet y de la red local',
          'Reinicia en Modo Seguro con funciones de red',
          'Ejecuta análisis completo con Windows Defender',
          'Descarga y ejecuta Malwarebytes Free desde un USB limpio',
          'Descarga y ejecuta AdwCleaner para adware y secuestradores de navegador',
          'Revisa los programas de inicio con Autoruns: elimina entradas sospechosas',
          'Revisa extensiones de todos los navegadores: elimina las desconocidas',
          'Cambia TODAS las contraseñas desde un dispositivo limpio',
          'Activa la autenticación en dos pasos en tus cuentas importantes'
        ],
        herramientas:['Windows Defender','Malwarebytes Free','AdwCleaner','Autoruns','Norton Power Eraser'],
        comandos:['msconfig','sc query state= all'],
        advertencias:['No conectes el equipo infectado a la red hasta estar seguro de la limpieza'],
        dificultad:'medio', tiempo_minutos:90, requiere_reinicio:true, requiere_admin:true,
        notas:'Después de la limpieza, instala un antivirus de tiempo real. Windows Defender es suficiente si se mantiene actualizado.'
      },
      {
        id:16, problema_id:64,
        titulo:'Respuesta ante ataque de ransomware',
        resumen:'Pasos de contención y recuperación. NO pagues el rescate.',
        pasos:[
          'Desconecta INMEDIATAMENTE el equipo de la red: desenchufa el cable y desactiva WiFi',
          'Apaga el equipo si el cifrado está en proceso',
          'Identifica la variante en el sitio ID Ransomware (sube la nota de rescate)',
          'Busca en nomoreransom.org si hay un descifrador gratuito disponible',
          'Reporta el incidente a la Policía Nacional / CERT nacional',
          'Limpia el sistema con una reinstalación completa de Windows desde USB',
          'Restaura archivos desde un backup limpio anterior a la infección',
          'Si no hay backup: algunos archivos pueden recuperarse con Recuva',
          'NUNCA pagues el rescate: no garantiza la recuperación'
        ],
        herramientas:['Herramientas de descifrado de nomoreransom.org','Recuva','Kaspersky Decryptors'],
        comandos:[],
        advertencias:['NO reinicies durante el cifrado activo','NO pagues: el 40% de quienes pagan no recuperan sus archivos'],
        dificultad:'experto', tiempo_minutos:120, requiere_reinicio:false, requiere_admin:false,
        notas:'La mejor defensa es backup 3-2-1: 3 copias, 2 medios distintos, 1 fuera del sitio.'
      },
      {
        id:17, problema_id:70,
        titulo:'Diagnóstico completo cuando la impresora no imprime',
        resumen:'Desde limpiar la cola de impresión hasta reinstalar el driver completo.',
        pasos:[
          'Verifica que la impresora esté encendida, conectada y sin errores en su pantalla',
          'Reinicia el servicio Cola de impresión: services.msc → Print Spooler → Reiniciar',
          'Limpia la cola: net stop spooler → elimina archivos en C:\\Windows\\System32\\spool\\PRINTERS\\ → net start spooler',
          'Imprime una página de prueba desde las propiedades de la impresora',
          'Desinstala completamente el driver desde Panel de control → Dispositivos e impresoras',
          'Descarga el driver completo (no el básico) del sitio oficial del fabricante',
          'Si es por red: verifica que la impresora tenga IP estática y sea accesible con ping'
        ],
        herramientas:['Print Management Console','Administrador de dispositivos','Driver oficial del fabricante'],
        comandos:['net stop spooler','net start spooler','del /Q /F /S C:\\Windows\\System32\\spool\\PRINTERS\\*'],
        advertencias:['Detener el spooler cancela todos los trabajos de impresión pendientes'],
        dificultad:'facil', tiempo_minutos:20, requiere_reinicio:false, requiere_admin:true,
        notas:'Las impresoras HP tienen HP Print and Scan Doctor para diagnóstico automático.'
      },
      {
        id:18, problema_id:75,
        titulo:'Solución cuando Outlook no abre o se congela',
        resumen:'Reparar el perfil, el archivo PST y las rutas de carga de Outlook.',
        pasos:[
          'Abre Outlook en Modo Seguro: outlook.exe /safe',
          'Si abre correctamente, el problema es un complemento: deshabilita todos en Archivo → Opciones → Complementos',
          'Ejecuta la herramienta ScanPST.exe (Reparación de Bandeja de entrada de Outlook)',
          'Ruta: C:\\Program Files (x86)\\Microsoft Office\\root\\Office16\\SCANPST.EXE',
          'Selecciona el archivo .pst o .ost y ejecuta la reparación',
          'Crea un nuevo perfil de Outlook: Panel de control → Correo → Mostrar perfiles → Agregar',
          'Si usas Microsoft 365: ejecuta el Asistente de soporte y recuperación de Microsoft (SaRA)',
          'Repara Office: Panel de control → Programas → Microsoft Office → Cambiar → Reparación rápida'
        ],
        herramientas:['ScanPST.exe','Microsoft Support and Recovery Assistant (SaRA)'],
        comandos:['outlook.exe /safe','outlook.exe /cleanviews','outlook.exe /resetnavpane'],
        advertencias:['ScanPST puede tardar horas en archivos PST grandes (>5GB)'],
        dificultad:'medio', tiempo_minutos:35, requiere_reinicio:false, requiere_admin:false,
        notas:'Los archivos PST no deben superar 20GB. Configura el archivado automático.'
      },
      {
        id:19, problema_id:77,
        titulo:'Solución cuando Excel se cierra o pierde datos',
        resumen:'Recuperar archivos no guardados y prevenir pérdidas futuras.',
        pasos:[
          'Busca archivos de autorrecuperación en: C:\\Users\\[usuario]\\AppData\\Roaming\\Microsoft\\Excel\\',
          'Abre Excel → Archivo → Información → Administrar libro → Recuperar libros no guardados',
          'Reduce el intervalo de autoguardado: Archivo → Opciones → Guardar → cada 2 minutos',
          'Deshabilita los complementos: Archivo → Opciones → Complementos → Ir → desmarca todos',
          'Si el archivo está corrupto: Archivo → Abrir → flecha en Abrir → "Abrir y reparar"',
          'Activa OneDrive para guardado automático en la nube',
          'Verifica que Office esté completamente actualizado'
        ],
        herramientas:['Microsoft Support and Recovery Assistant','OneDrive'],
        comandos:[],
        advertencias:['No abrir archivos .xlsx de fuentes desconocidas (pueden contener macros maliciosas)'],
        dificultad:'facil', tiempo_minutos:20, requiere_reinicio:false, requiere_admin:false,
        notas:'Si el problema es recurrente, repara Office completo desde el Panel de control.'
      },
      {
        id:20, problema_id:31,
        titulo:'Diagnóstico y solución de micrófono que no funciona',
        resumen:'Permisos de privacidad, driver y configuración de dispositivo predeterminado.',
        pasos:[
          'Ve a Configuración → Privacidad → Micrófono: verifica que las apps tengan permiso',
          'Haz clic derecho en el ícono de volumen → Sonidos → pestaña Grabación',
          'Verifica que el micrófono correcto esté como dispositivo predeterminado',
          'Haz clic derecho → Propiedades → Niveles: sube el volumen del micrófono al 80%',
          'Actualiza el driver del micrófono desde el Administrador de dispositivos',
          'Prueba el micrófono en el Grabador de voz de Windows para aislar si es problema de app',
          'Si es un headset USB: prueba en otro puerto USB'
        ],
        herramientas:['Grabador de voz de Windows','Administrador de dispositivos'],
        comandos:['mmsys.cpl'],
        advertencias:[],
        dificultad:'facil', tiempo_minutos:15, requiere_reinicio:false, requiere_admin:false,
        notas:'Windows 10/11 puede silenciar automáticamente el micrófono en llamadas. Revisa la configuración de comunicaciones.'
      },
    ],

    consultas: [],
    nextIds: { categorias: 16, problemas: 81, soluciones: 21, consultas: 1 }
  };

  // ============================================================
  // INICIALIZACIÓN
  // ============================================================
  function init() {
    if (!localStorage.getItem('ts_v2_initialized')) {
      // Limpiar versión anterior si existe
      ['ts_categorias','ts_problemas','ts_soluciones','ts_consultas','ts_nextIds','ts_initialized'].forEach(k => localStorage.removeItem(k));
      localStorage.setItem('ts_categorias',  JSON.stringify(SEED.categorias));
      localStorage.setItem('ts_problemas',   JSON.stringify(SEED.problemas));
      localStorage.setItem('ts_soluciones',  JSON.stringify(SEED.soluciones));
      localStorage.setItem('ts_consultas',   JSON.stringify(SEED.consultas));
      localStorage.setItem('ts_nextIds',     JSON.stringify(SEED.nextIds));
      localStorage.setItem('ts_v2_initialized', '1');
    }
  }

  function getAll(table)       { return JSON.parse(localStorage.getItem(`ts_${table}`) || '[]'); }
  function saveAll(table, data){ localStorage.setItem(`ts_${table}`, JSON.stringify(data)); }
  function getNextId(table) {
    const ids  = JSON.parse(localStorage.getItem('ts_nextIds') || '{}');
    const next = ids[table] || 1;
    ids[table] = next + 1;
    localStorage.setItem('ts_nextIds', JSON.stringify(ids));
    return next;
  }

  // ============================================================
  // API PÚBLICA
  // ============================================================
  return {
    init,

    getCategorias() { return getAll('categorias'); },
    addCategoria(nombre, icono, descripcion = '') {
      const cats = getAll('categorias');
      const nueva = { id: getNextId('categorias'), nombre, icono, descripcion, activo: true };
      cats.push(nueva); saveAll('categorias', cats); return nueva;
    },
    deleteCategoria(id) { saveAll('categorias', getAll('categorias').filter(c => c.id !== id)); },

    getProblemas(categoria_id = null) {
      const todos = getAll('problemas');
      return categoria_id ? todos.filter(p => p.categoria_id === categoria_id) : todos;
    },
    buscarProblemas(termino) {
      const t = termino.toLowerCase();
      return getAll('problemas').filter(p => p.nombre.toLowerCase().includes(t));
    },
    addProblema(categoria_id, nombre) {
      const probs = getAll('problemas');
      const nuevo = { id: getNextId('problemas'), categoria_id: parseInt(categoria_id), nombre, activo: true };
      probs.push(nuevo); saveAll('problemas', probs); return nuevo;
    },
    deleteProblema(id) { saveAll('problemas', getAll('problemas').filter(p => p.id !== id)); },

    getSoluciones(problema_id = null) {
      const todas = getAll('soluciones');
      return problema_id ? todas.filter(s => s.problema_id === problema_id) : todas;
    },
    getSolucionById(id) { return getAll('soluciones').find(s => s.id === id) || null; },
    addSolucion(data) {
      const sols = getAll('soluciones');
      const nueva = { id: getNextId('soluciones'), votos_utiles: 0, votos_inutiles: 0, ...data };
      sols.push(nueva); saveAll('soluciones', sols); return nueva;
    },
    deleteSolucion(id) { saveAll('soluciones', getAll('soluciones').filter(s => s.id !== id)); },
    votarSolucion(id, util) {
      const sols = getAll('soluciones');
      const idx  = sols.findIndex(s => s.id === id);
      if (idx !== -1) {
        util ? sols[idx].votos_utiles++ : sols[idx].votos_inutiles++;
        saveAll('soluciones', sols);
      }
    },

    getConsultas() { return getAll('consultas').reverse(); },
    addConsulta(categoria_id, problema_id, severidad, solucion_id) {
      const consultas = getAll('consultas');
      const cats  = getAll('categorias');
      const probs = getAll('problemas');
      const cat   = cats.find(c => c.id === categoria_id);
      const prob  = probs.find(p => p.id === problema_id);
      const nueva = {
        id: getNextId('consultas'),
        fecha: new Date().toLocaleString('es-PE'),
        categoria: cat ? cat.nombre : '—',
        problema:  prob ? prob.nombre : '—',
        severidad, solucion_id, resuelto: null
      };
      consultas.push(nueva); saveAll('consultas', consultas); return nueva;
    },
    marcarResuelta(id, resuelto) {
      const consultas = getAll('consultas');
      const idx = consultas.findIndex(c => c.id === id);
      if (idx !== -1) { consultas[idx].resuelto = resuelto; saveAll('consultas', consultas); }
    },
    clearConsultas() { saveAll('consultas', []); },

    getStats() {
      return {
        soluciones:   getAll('soluciones').length,
        categorias:   getAll('categorias').length,
        problemas:    getAll('problemas').length,
        consultasHoy: getAll('consultas').filter(c =>
          c.fecha && c.fecha.includes(new Date().toLocaleDateString('es-PE'))
        ).length
      };
    }
  };
})();

DB.init();
window.DB = DB;
