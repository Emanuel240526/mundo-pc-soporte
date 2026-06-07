-- ============================================================
-- soporte.sql — mundo pc Pro — Base de datos COMPLETA
-- Compatible con: SQL Server (Visual Studio), SQLite, MySQL
-- Versión 2.0 — Expandida
-- ============================================================

-- CREATE DATABASE SoporteTecnico;
-- GO
-- USE SoporteTecnico;
-- GO

-- ============================================================
-- TABLAS PRINCIPALES
-- ============================================================

CREATE TABLE categorias (
    id          INT PRIMARY KEY IDENTITY(1,1),
    nombre      NVARCHAR(100) NOT NULL,
    icono       NVARCHAR(10)  NOT NULL DEFAULT '📁',
    descripcion NVARCHAR(255),
    orden       INT DEFAULT 0,
    activo      BIT NOT NULL DEFAULT 1,
    creado_en   DATETIME DEFAULT GETDATE()
);

CREATE TABLE subcategorias (
    id           INT PRIMARY KEY IDENTITY(1,1),
    categoria_id INT NOT NULL,
    nombre       NVARCHAR(100) NOT NULL,
    descripcion  NVARCHAR(255),
    activo       BIT NOT NULL DEFAULT 1,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE CASCADE
);

CREATE TABLE problemas (
    id               INT PRIMARY KEY IDENTITY(1,1),
    categoria_id     INT NOT NULL,
    subcategoria_id  INT,
    nombre           NVARCHAR(255) NOT NULL,
    descripcion      NVARCHAR(500),
    palabras_clave   NVARCHAR(500),   -- para búsqueda full-text
    frecuencia       INT DEFAULT 0,   -- cuántas veces se consulta
    activo           BIT NOT NULL DEFAULT 1,
    creado_en        DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (categoria_id)    REFERENCES categorias(id)    ON DELETE CASCADE,
    FOREIGN KEY (subcategoria_id) REFERENCES subcategorias(id)
);

CREATE TABLE soluciones (
    id              INT PRIMARY KEY IDENTITY(1,1),
    problema_id     INT NOT NULL,
    titulo          NVARCHAR(255) NOT NULL,
    resumen         NVARCHAR(500),
    pasos           NVARCHAR(MAX) NOT NULL,       -- JSON array
    herramientas    NVARCHAR(MAX),                -- JSON array
    comandos        NVARCHAR(MAX),                -- JSON array de comandos CLI/PS útiles
    advertencias    NVARCHAR(MAX),                -- JSON array de advertencias
    dificultad      NVARCHAR(20) DEFAULT 'facil' CHECK (dificultad IN ('facil','medio','avanzado','experto')),
    tiempo_minutos  INT DEFAULT 15,
    requiere_reinicio BIT DEFAULT 0,
    requiere_admin  BIT DEFAULT 0,                -- requiere permisos de administrador
    aplica_windows  BIT DEFAULT 1,
    aplica_linux    BIT DEFAULT 0,
    aplica_mac      BIT DEFAULT 0,
    notas           NVARCHAR(MAX),
    url_referencia  NVARCHAR(500),
    votos_utiles    INT DEFAULT 0,
    votos_inutiles  INT DEFAULT 0,
    vistas          INT DEFAULT 0,
    creado_en       DATETIME DEFAULT GETDATE(),
    actualizado_en  DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (problema_id) REFERENCES problemas(id) ON DELETE CASCADE
);

CREATE TABLE etiquetas (
    id     INT PRIMARY KEY IDENTITY(1,1),
    nombre NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE solucion_etiquetas (
    solucion_id INT NOT NULL,
    etiqueta_id INT NOT NULL,
    PRIMARY KEY (solucion_id, etiqueta_id),
    FOREIGN KEY (solucion_id) REFERENCES soluciones(id) ON DELETE CASCADE,
    FOREIGN KEY (etiqueta_id) REFERENCES etiquetas(id)  ON DELETE CASCADE
);

-- ============================================================
-- TABLAS DE USUARIOS Y TICKETS
-- ============================================================

CREATE TABLE usuarios (
    id            INT PRIMARY KEY IDENTITY(1,1),
    nombre        NVARCHAR(100) NOT NULL,
    email         NVARCHAR(150) UNIQUE,
    telefono      NVARCHAR(20),
    departamento  NVARCHAR(100),
    empresa       NVARCHAR(100),
    rol           NVARCHAR(20) DEFAULT 'usuario' CHECK (rol IN ('usuario','tecnico','admin','superadmin')),
    activo        BIT DEFAULT 1,
    creado_en     DATETIME DEFAULT GETDATE(),
    ultimo_acceso DATETIME
);

CREATE TABLE tecnicos (
    id               INT PRIMARY KEY IDENTITY(1,1),
    usuario_id       INT NOT NULL UNIQUE,
    especialidad     NVARCHAR(255),     -- ej: "Redes, Hardware, Windows Server"
    nivel            NVARCHAR(20) DEFAULT 'junior' CHECK (nivel IN ('junior','semi','senior','experto')),
    tickets_resueltos INT DEFAULT 0,
    calificacion_prom DECIMAL(3,2) DEFAULT 0.00,
    disponible       BIT DEFAULT 1,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

CREATE TABLE tickets (
    id             INT PRIMARY KEY IDENTITY(1,1),
    usuario_id     INT,
    tecnico_id     INT,
    categoria_id   INT,
    problema_id    INT,
    solucion_id    INT,
    titulo         NVARCHAR(255) NOT NULL,
    descripcion    NVARCHAR(MAX),
    severidad      NVARCHAR(20) DEFAULT 'Leve' CHECK (severidad IN ('Leve','Moderado','Crítico','Urgente')),
    estado         NVARCHAR(30) DEFAULT 'Abierto' CHECK (estado IN ('Abierto','En proceso','Esperando usuario','Resuelto','Cerrado','Cancelado')),
    prioridad      INT DEFAULT 2 CHECK (prioridad BETWEEN 1 AND 5),  -- 1=más baja, 5=más alta
    sistema_op     NVARCHAR(50),    -- Windows 10, Ubuntu 22, macOS 14...
    marca_pc       NVARCHAR(100),
    resuelto       BIT,
    calificacion   INT CHECK (calificacion BETWEEN 1 AND 5),
    comentario_cierre NVARCHAR(500),
    creado_en      DATETIME DEFAULT GETDATE(),
    actualizado_en DATETIME DEFAULT GETDATE(),
    resuelto_en    DATETIME,
    FOREIGN KEY (usuario_id)   REFERENCES usuarios(id),
    FOREIGN KEY (tecnico_id)   REFERENCES tecnicos(id),
    FOREIGN KEY (categoria_id) REFERENCES categorias(id),
    FOREIGN KEY (problema_id)  REFERENCES problemas(id),
    FOREIGN KEY (solucion_id)  REFERENCES soluciones(id)
);

CREATE TABLE ticket_comentarios (
    id          INT PRIMARY KEY IDENTITY(1,1),
    ticket_id   INT NOT NULL,
    usuario_id  INT,
    texto       NVARCHAR(MAX) NOT NULL,
    es_interno  BIT DEFAULT 0,    -- comentario interno solo para técnicos
    creado_en   DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ticket_id)  REFERENCES tickets(id)  ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

CREATE TABLE consultas (
    id           INT PRIMARY KEY IDENTITY(1,1),
    categoria_id INT,
    problema_id  INT,
    solucion_id  INT,
    severidad    NVARCHAR(20),
    resuelto     BIT,
    ip_cliente   NVARCHAR(50),
    user_agent   NVARCHAR(500),
    creado_en    DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (categoria_id) REFERENCES categorias(id),
    FOREIGN KEY (problema_id)  REFERENCES problemas(id),
    FOREIGN KEY (solucion_id)  REFERENCES soluciones(id)
);

CREATE TABLE dispositivos (
    id           INT PRIMARY KEY IDENTITY(1,1),
    usuario_id   INT,
    tipo         NVARCHAR(50),      -- Desktop, Laptop, Servidor, Impresora, Router...
    marca        NVARCHAR(100),
    modelo       NVARCHAR(100),
    serial       NVARCHAR(100),
    sistema_op   NVARCHAR(100),
    ram_gb       INT,
    almacenamiento_gb INT,
    procesador   NVARCHAR(150),
    fecha_compra DATE,
    garantia_hasta DATE,
    notas        NVARCHAR(500),
    activo       BIT DEFAULT 1,
    creado_en    DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- ============================================================
-- ÍNDICES
-- ============================================================
CREATE INDEX idx_problemas_categoria    ON problemas(categoria_id);
CREATE INDEX idx_soluciones_problema    ON soluciones(problema_id);
CREATE INDEX idx_tickets_estado         ON tickets(estado);
CREATE INDEX idx_tickets_usuario        ON tickets(usuario_id);
CREATE INDEX idx_tickets_tecnico        ON tickets(tecnico_id);
CREATE INDEX idx_consultas_fecha        ON consultas(creado_en);
CREATE INDEX idx_problemas_palabras     ON problemas(palabras_clave);

-- ============================================================
-- SEED: CATEGORÍAS (15 categorías)
-- ============================================================
INSERT INTO categorias (nombre, icono, descripcion, orden) VALUES
('Rendimiento',           '⚡', 'PC lenta, sobrecalentamiento, lag, congelamiento',        1),
('Pantalla / Video',      '🖥', 'Problemas de imagen, resolución, parpadeo, drivers GPU',  2),
('Red / Internet',        '🌐', 'Sin conexión, lentitud de red, WiFi, VPN, DNS',           3),
('Audio',                 '🔊', 'Sin sonido, distorsión, micrófono, auriculares',          4),
('Software / SO',         '💻', 'Windows, Linux, macOS, errores del sistema, drivers',     5),
('Hardware',              '🔧', 'Teclado, mouse, USB, RAM, disco, fuente de poder',        6),
('Almacenamiento',        '💾', 'Disco lleno, SSD lento, errores SMART, particiones',      7),
('Seguridad',             '🔒', 'Virus, malware, ransomware, contraseñas, phishing',       8),
('Impresoras',            '🖨', 'No imprime, atascos de papel, drivers, conexión',         9),
('Correo / Office',       '📧', 'Outlook, Gmail, Word, Excel, PowerPoint, licencias',     10),
('Windows Server',        '🖧', 'Active Directory, DNS Server, DHCP, IIS, roles',         11),
('Programación / Dev',    '⌨', 'IDEs, Git, compiladores, depuración, entornos',           12),
('Móviles / Tablets',     '📱', 'Android, iOS, sincronización, aplicaciones, batería',    13),
('Energía / Electricidad','🔌', 'UPS, cortes de luz, sobretensiones, fuente de poder',    14),
('Videoconferencias',     '📹', 'Zoom, Teams, Meet, cámara, micrófono, conexión',         15);

-- ============================================================
-- SEED: SUBCATEGORÍAS
-- ============================================================
INSERT INTO subcategorias (categoria_id, nombre) VALUES
-- Rendimiento
(1, 'Inicio lento'), (1, 'RAM'), (1, 'CPU'), (1, 'Temperatura'),
-- Pantalla
(2, 'Monitor externo'), (2, 'Drivers GPU'), (2, 'Resolución'),
-- Red
(3, 'WiFi'), (3, 'Cable Ethernet'), (3, 'VPN'), (3, 'DNS'),
-- Software
(5, 'Windows 10'), (5, 'Windows 11'), (5, 'Linux'), (5, 'macOS'),
-- Seguridad
(8, 'Virus/Malware'), (8, 'Ransomware'), (8, 'Phishing'), (8, 'Contraseñas'),
-- Windows Server
(11, 'Active Directory'), (11, 'DNS/DHCP'), (11, 'IIS'), (11, 'Backup');

-- ============================================================
-- SEED: PROBLEMAS (80 problemas)
-- ============================================================
INSERT INTO problemas (categoria_id, nombre, palabras_clave) VALUES
-- RENDIMIENTO (cat 1)
(1, 'La PC está muy lenta al iniciar', 'inicio lento boot arranque'),
(1, 'El ventilador hace ruido excesivo', 'ventilador ruido cooler fan sobrecalentamiento'),
(1, 'Programas se congelan o no responden', 'congelado freeze cuelga aplicación'),
(1, 'CPU al 100% sin razón aparente', 'cpu uso alto proceso rendimiento'),
(1, 'La PC tarda mucho en apagarse', 'apagado lento shutdown'),
(1, 'Poca memoria RAM disponible', 'ram memoria insuficiente poca memoria'),
(1, 'El equipo se reinicia solo', 'reinicia solo apagado inesperado reboot'),
(1, 'Juegos o programas pesados van lentos', 'fps lento juego lag rendimiento gaming'),
(1, 'La PC está lenta después de actualización', 'lenta actualización windows update'),
(1, 'Temperatura muy alta en reposo', 'temperatura alta idle sobrecalentamiento thermal'),

-- PANTALLA (cat 2)
(2, 'Pantalla en negro al encender', 'pantalla negra no enciende no muestra'),
(2, 'Pantalla parpadea constantemente', 'parpadeo flickering pantalla intermitente'),
(2, 'Resolución incorrecta o pixelada', 'resolución pixelada baja calidad pantalla'),
(2, 'Artefactos visuales / rayas en pantalla', 'rayas líneas artefactos glitch pantalla'),
(2, 'Monitor externo no es detectado', 'monitor externo no detectado hdmi displayport'),
(2, 'Brillo de pantalla no se ajusta', 'brillo no cambia pantalla oscura luminosidad'),
(2, 'Pantalla con colores incorrectos', 'colores incorrectos pantalla calibración'),
(2, 'Driver de tarjeta de video falla', 'driver gpu nvidia amd falla error'),
(2, 'Pantalla se apaga sola', 'pantalla se apaga sola suspensión ahorro energía'),

-- RED / INTERNET (cat 3)
(3, 'Sin acceso a internet', 'sin internet no conecta sin conexión'),
(3, 'WiFi se desconecta constantemente', 'wifi cae desconecta intermitente'),
(3, 'Internet muy lento', 'lento velocidad internet banda ancha'),
(3, 'No puede conectarse a la red WiFi', 'wifi no conecta contraseña red inalámbrica'),
(3, 'VPN no conecta o se cae', 'vpn no conecta falla desconecta'),
(3, 'Error de DNS / páginas no cargan', 'dns error página no carga servidor'),
(3, 'Dirección IP en conflicto', 'ip conflicto dirección duplicada red'),
(3, 'No hay internet solo en un equipo', 'sin internet un equipo otros sí router'),
(3, 'Proxy o firewall bloquea acceso', 'proxy firewall bloquea acceso corporativo'),

-- AUDIO (cat 4)
(4, 'Sin sonido en absoluto', 'sin sonido audio mudo no suena'),
(4, 'Sonido con distorsión o ruido de fondo', 'distorsión ruido audio crackling'),
(4, 'Micrófono no funciona', 'micrófono no detecta no graba mic'),
(4, 'Auriculares no se detectan', 'auriculares headset no detecta no funciona'),
(4, 'Sonido sale por altavoces y auriculares a la vez', 'audio ambos salida altavoz auricular'),
(4, 'Driver de audio falla o desaparece', 'driver audio falla realtek hdaudio'),
(4, 'Volumen baja o sube solo', 'volumen cambia solo baja sube automático'),

-- SOFTWARE / SO (cat 5)
(5, 'Pantalla azul de la muerte (BSOD)', 'bsod pantalla azul error crítico windows stop'),
(5, 'Windows no inicia o entra en bucle', 'windows no inicia loop bucle arranque boot'),
(5, 'Actualizaciones de Windows fallan', 'windows update error falla actualización'),
(5, 'Driver de dispositivo no funciona', 'driver error dispositivo no funciona'),
(5, 'El Explorador de archivos se cierra solo', 'explorador archivos crash cierra'),
(5, 'Aplicación no abre o da error', 'aplicación error no abre no ejecuta'),
(5, 'Registro de Windows dañado', 'registro windows regedit dañado corrompido'),
(5, 'Permisos de archivos o carpetas bloqueados', 'permisos acceso denegado carpeta archivo'),
(5, 'Windows no activa o licencia inválida', 'activación windows licencia inválida'),
(5, 'Reloj del sistema desincronizado', 'hora fecha incorrecta reloj sistema'),

-- HARDWARE (cat 6)
(6, 'Teclado no responde o pierde teclas', 'teclado no responde teclas falla'),
(6, 'Mouse no funciona o salta', 'mouse no funciona salta cursor'),
(6, 'Puerto USB no reconoce dispositivos', 'usb no reconoce dispositivo puerto'),
(6, 'PC no enciende al presionar el botón', 'no enciende botón power pc apagado'),
(6, 'Pantalla de POST / BIOS falla', 'bios post beep error arranque'),
(6, 'RAM no es detectada o falla', 'ram memoria no detecta falla error'),
(6, 'Fuente de poder hace ruido o falla', 'fuente poder psu ruido falla apagado'),
(6, 'Disco duro hace ruido (click / grinding)', 'disco duro ruido click grinding fallo'),
(6, 'Puertos HDMI o DisplayPort dañados', 'hdmi displayport puerto dañado no conecta'),

-- ALMACENAMIENTO (cat 7)
(7, 'Disco duro lleno', 'disco lleno sin espacio almacenamiento'),
(7, 'Error al leer o escribir en disco', 'error leer escribir disco fallo'),
(7, 'SSD lento o se degrada', 'ssd lento degradado rendimiento trim'),
(7, 'Archivos corrompidos o inaccesibles', 'archivos corrompidos inaccesibles error chkdsk'),
(7, 'Disco no aparece en el sistema', 'disco no aparece no detecta gestor particiones'),
(7, 'Partición dañada o perdida', 'partición perdida dañada recuperar'),
(7, 'SMART alerta de fallo inminente en disco', 'smart fallo disco duro inminente error'),
(7, 'Papelera de reciclaje no se vacía', 'papelera no vacía error $Recycle.Bin'),

-- SEGURIDAD (cat 8)
(8, 'Posible virus o malware', 'virus malware infección troyano'),
(8, 'Ransomware: archivos cifrados', 'ransomware archivos cifrados extorsión'),
(8, 'Cuenta de correo o red social hackeada', 'cuenta hackeada acceso no autorizado'),
(8, 'Sospechas de phishing o estafa', 'phishing estafa correo falso engaño'),
(8, 'El antivirus fue desactivado', 'antivirus desactivado apagado malware'),
(8, 'Contraseña olvidada del sistema', 'contraseña olvidada windows login acceso'),
(8, 'Spyware o adware instalado', 'spyware adware publicidad pop-up navegador'),

-- IMPRESORAS (cat 9)
(9, 'Impresora no imprime nada', 'impresora no imprime trabajo cola'),
(9, 'Atasco de papel en impresora', 'papel atasco trancado impresora'),
(9, 'Impresora no es detectada por la PC', 'impresora no detecta driver instalar'),
(9, 'Impresión con rayas o manchas', 'rayas manchas impresión calidad cabezal tóner'),
(9, 'Impresora dice sin tinta pero tiene', 'tinta cartucho nivel falso impresora'),

-- CORREO / OFFICE (cat 10)
(10, 'Outlook no abre o se congela', 'outlook no abre congela lento pst'),
(10, 'No puede enviar o recibir correos', 'correo no envía no recibe email smtp pop imap'),
(10, 'Excel se cierra solo o pierde datos', 'excel cierra datos perdidos crash'),
(10, 'Word no guarda o da error de archivo', 'word no guarda error archivo docx'),
(10, 'Licencia de Office expirada o inválida', 'office licencia expirada inválida activar');

-- ============================================================
-- SEED: ETIQUETAS
-- ============================================================
INSERT INTO etiquetas (nombre) VALUES
('Windows 10'),('Windows 11'),('Windows 7'),('Linux'),('macOS'),
('BIOS'),('Drivers'),('Red'),('Hardware'),('Seguridad'),
('Gratuito'),('Requiere admin'),('Reinicio necesario'),('Avanzado'),
('Rápido'),('Sin internet'),('Línea de comandos'),('PowerShell'),
('Registro'),('SSD'),('Antivirus'),('Offline');

-- ============================================================
-- SEED: SOLUCIONES (50 soluciones detalladas)
-- ============================================================

-- Problema 1: PC lenta al iniciar
INSERT INTO soluciones (problema_id, titulo, resumen, pasos, herramientas, comandos, advertencias, dificultad, tiempo_minutos, requiere_reinicio, requiere_admin, notas, url_referencia) VALUES
(1, 'Optimización completa del inicio de Windows',
 'Deshabilitar programas de inicio, limpiar temporales y optimizar servicios.',
 '["Presiona Ctrl+Shift+Esc y ve a la pestaña Inicio","Deshabilita todos los programas que no necesitas en el arranque","Abre Ejecutar (Win+R) y escribe services.msc","Deshabilita servicios no esenciales: SysMain, Connected User Experiences, Xbox Services","Abre cleanmgr.exe y limpia archivos temporales, miniaturas y archivos del sistema","Ejecuta en PowerShell como admin: Get-AppxPackage -AllUsers | Remove-AppxPackage (solo apps no deseadas)","Desfragmenta el disco si es HDD (no SSD): defrag C: /U /V","Reinicia y mide el tiempo de inicio"]',
 '["Administrador de tareas","CCleaner (opcional)","Autoruns de Sysinternals","WinDirStat"]',
 '["msconfig","services.msc","cleanmgr","powercfg /energy","bcdedit /set {current} bootmenupolicy legacy"]',
 '["No deshabilites servicios de Windows Defender ni de red","No elimines apps del sistema sin investigar primero"]',
 'facil', 20, 1, 1,
 'Si el tiempo de inicio supera 2 minutos con SSD, puede ser un problema de hardware o drivers.',
 'https://support.microsoft.com/windows/tips-to-improve-pc-performance-in-windows');

-- Problema 2: Ventilador ruidoso / sobrecalentamiento
INSERT INTO soluciones (problema_id, titulo, resumen, pasos, herramientas, comandos, advertencias, dificultad, tiempo_minutos, requiere_reinicio, requiere_admin, notas) VALUES
(2, 'Solución de sobrecalentamiento y ruido de ventiladores',
 'Limpieza de polvo, aplicación de pasta térmica y ajuste de curvas de ventiladores.',
 '["Apaga completamente el equipo y desconéctalo de la corriente","Abre el gabinete y usa aire comprimido para limpiar todos los ventiladores","Limpia las rejillas de entrada y salida de aire","Instala HWMonitor y verifica temperaturas antes y después","Si CPU supera 90°C en reposo: quita el disipador, limpia pasta vieja con alcohol isopropílico, aplica pasta nueva","Descarga MSI Afterburner para controlar la curva de ventiladores manualmente","Configura la curva: 50% velocidad a 60°C, 80% a 75°C, 100% a 85°C","Verifica que los cables internos no obstruyan el flujo de aire"]',
 '["HWMonitor","MSI Afterburner","Core Temp","SpeedFan","Aire comprimido","Pasta térmica Thermal Grizzly o Arctic MX-4"]',
 '["wmic /namespace:\\\\root\\wmi PATH MSAcpi_ThermalZoneTemperature get CurrentTemperature"]',
 '["Ten cuidado al manipular el disipador de CPU con el equipo encendido","Aplica pasta térmica en cantidad de un grano de arroz, no más"]',
 'medio', 45, 0, 0,
 'Limpieza recomendada cada 6 meses. En laptops puede ser más difícil acceder al disipador.');

-- Problema 3: Programas congelados
INSERT INTO soluciones (problema_id, titulo, resumen, pasos, herramientas, comandos, advertencias, dificultad, tiempo_minutos, requiere_reinicio, requiere_admin, notas) VALUES
(3, 'Diagnóstico y solución de programas que no responden',
 'Identificar la causa del congelamiento: RAM, disco, proceso zombie o corrupción.',
 '["Cuando una app se congele, espera 30 segundos antes de forzar cierre","Abre el Administrador de tareas → pestaña Detalles","Haz clic derecho en el proceso → Crear volcado de memoria (para diagnóstico profundo)","Fuerza el cierre con: End Task o taskkill /F /PID [número]","Verifica el Event Viewer (eventvwr.msc) → Registros de Windows → Aplicación","Busca errores justo antes del congelamiento","Ejecuta sfc /scannow en CMD como admin","Si el problema es recurrente con una app específica, reinstálala en modo limpio","Verifica que la RAM no falle con MemTest86 (análisis nocturno)"]',
 '["Administrador de tareas","Event Viewer","MemTest86","Process Explorer","WhoCrashed"]',
 '["taskkill /F /PID [PID]","sfc /scannow","DISM /Online /Cleanup-Image /RestoreHealth","verifier /standard /all"]',
 '["No usar verifier en producción sin saber qué haces, puede causar más BSOD"]',
 'medio', 30, 0, 1,
 'Si múltiples programas se congelan, sospechar de RAM defectuosa o disco en mal estado.');

-- Problema 4: CPU al 100%
INSERT INTO soluciones (problema_id, titulo, resumen, pasos, herramientas, comandos, advertencias, dificultad, tiempo_minutos, requiere_reinicio, requiere_admin, notas) VALUES
(4, 'Diagnóstico y solución de CPU al 100%',
 'Identificar el proceso culpable y solucionarlo sin afectar el sistema.',
 '["Abre el Administrador de tareas y ordena por CPU descendente","Identifica el proceso con mayor consumo","Si es WMI Provider Host (WmiPrvSE.exe): reinicia el servicio Windows Management Instrumentation","Si es Antimalware Service Executable: programa el escaneo para horarios de baja actividad","Si es System Idle Process al 99%: es normal (significa que la CPU está libre)","Si es un proceso desconocido: búscalo en Google + comprueba su ruta en Task Manager","Desactiva el Superfetch: services.msc → SysMain → Deshabilitar","Desactiva la indexación de búsqueda si no la usas: services.msc → Windows Search → Manual","Actualiza todos los drivers especialmente chipset y almacenamiento","Ejecuta un análisis completo de malware"]',
 '["Process Explorer (Sysinternals)","Process Monitor","Administrador de tareas","Malwarebytes"]',
 '["wmic cpu get loadpercentage","Get-Process | Sort-Object CPU -Descending | Select-Object -First 10","sc config SysMain start= disabled","sc stop SysMain"]',
 '["No termines procesos de sistema sin estar seguro de qué hacen"]',
 'medio', 25, 0, 1,
 'Windows Update puede causar CPU al 100% temporalmente. Espera 30 minutos antes de actuar.');

-- Problema 7: PC se reinicia sola
INSERT INTO soluciones (problema_id, titulo, resumen, pasos, herramientas, comandos, advertencias, dificultad, tiempo_minutos, requiere_reinicio, requiere_admin, notas) VALUES
(7, 'Diagnóstico de reinicios inesperados',
 'Los reinicios pueden ser por temperatura, RAM, PSU, drivers o configuración de Windows.',
 '["Abre el Event Viewer → Registros de Windows → Sistema","Filtra por ID de evento 41 (Kernel-Power): indica apagado no controlado","Anota la hora y busca eventos anteriores que expliquen la causa","Verifica temperaturas con HWMonitor durante carga","Si se reinicia bajo carga: sospechar de PSU insuficiente o temperatura","Deshabilita el reinicio automático: Propiedades de Mi PC → Configuración avanzada → Inicio y recuperación → desmarcar Reiniciar automáticamente","Ejecuta MemTest86 para descartar RAM defectuosa","Actualiza el firmware de la BIOS/UEFI si hay versión disponible","Verifica los voltajes de la PSU con HWiNFO"]',
 '["HWMonitor","HWiNFO","MemTest86","Event Viewer","WhoCrashed"]',
 '["eventvwr.msc","wevtutil qe System /q:*[System[EventID=41]] /f:text","bcdedit /set {default} bootstatuspolicy ignoreallfailures"]',
 '["Si la PSU está fallando, apaga el equipo hasta reemplazarla para evitar daños"]',
 'medio', 40, 0, 1,
 'PSU de baja calidad es causa frecuente de reinicios bajo carga en equipos con GPU dedicada.');

-- Problema 11: Pantalla negra
INSERT INTO soluciones (problema_id, titulo, resumen, pasos, herramientas, comandos, advertencias, dificultad, tiempo_minutos, requiere_reinicio, requiere_admin, notas) VALUES
(11, 'Solución de pantalla en negro al encender',
 'Diagnóstico paso a paso desde el cable hasta los drivers de video.',
 '["Verifica que el cable HDMI/DisplayPort esté bien conectado en ambos extremos","Prueba con otro cable y otro puerto del monitor","Comprueba que el monitor esté seleccionado en la entrada correcta (Source/Input)","Reinicia y presiona Win+Ctrl+Shift+B para restablecer el driver de video","Si ves el cursor pero pantalla negra: presiona Ctrl+Alt+Supr → Administrador de tareas → Archivo → Ejecutar nueva tarea → explorer.exe","Arranca en Modo Seguro (F8 o Shift+Reiniciar) y desinstala el driver de GPU","Descarga el driver más reciente desde el sitio oficial de NVIDIA/AMD/Intel","Si el problema persiste sin monitor externo: puede ser la pantalla o el cable interno de la laptop"]',
 '["DDU (Display Driver Uninstaller)","GeForce Experience o AMD Software","Monitor de prueba"]',
 '["bcdedit /set {default} safeboot minimal","bcdedit /deletevalue {default} safeboot"]',
 '["DDU debe usarse en Modo Seguro para no dejar residuos del driver anterior"]',
 'medio', 30, 1, 1,
 'En laptops, conecta un monitor externo para determinar si el problema es la pantalla o la GPU.');

-- Problema 20: Sin internet
INSERT INTO soluciones (problema_id, titulo, resumen, pasos, herramientas, comandos, advertencias, dificultad, tiempo_minutos, requiere_reinicio, requiere_admin, notas) VALUES
(20, 'Diagnóstico completo de sin acceso a internet',
 'Flujo de diagnóstico desde el router hasta la configuración TCP/IP del equipo.',
 '["Verifica las luces del router: WAN debe estar encendida y estable","Reinicia el router: desconecta 30 segundos y vuelve a conectar","Desde CMD ejecuta: ping 8.8.8.8 — si responde, el problema es DNS no hardware","Si ping falla: ipconfig /release → ipconfig /renew","Ejecuta: netsh winsock reset → reinicia el equipo","Configura DNS manualmente: 8.8.8.8 y 8.8.4.4 (Google DNS)","Deshabilita temporalmente el firewall de Windows para descartar bloqueos","Prueba con otro dispositivo en la misma red para aislar si es el equipo o el router","Llama al ISP si todos los dispositivos fallan"]',
 '["CMD","Configuración de red Windows","nslookup","tracert"]',
 '["ping 8.8.8.8","ping google.com","ipconfig /release","ipconfig /renew","ipconfig /flushdns","netsh winsock reset","netsh int ip reset","tracert 8.8.8.8","nslookup google.com"]',
 '["netsh winsock reset puede afectar algunas aplicaciones VPN o antivirus al reiniciar"]',
 'facil', 15, 1, 1,
 'Si solo falla en un equipo y el router funciona bien, el problema es local en ese equipo.');

-- Problema 21: WiFi cae
INSERT INTO soluciones (problema_id, titulo, resumen, pasos, herramientas, comandos, advertencias, dificultad, tiempo_minutos, requiere_reinicio, requiere_admin, notas) VALUES
(21, 'Solución para WiFi que se desconecta constantemente',
 'Problemas de driver, configuración de ahorro de energía o interferencia de canal.',
 '["Abre Administrador de dispositivos → Adaptadores de red → propiedades del WiFi","Ve a Administración de energía y desmarca Permitir que el equipo apague este dispositivo","Ve a Propiedades avanzadas y deshabilita el Roaming Aggressiveness","Actualiza el driver del adaptador WiFi desde el sitio del fabricante","Cambia el canal del router: entra a 192.168.1.1 y selecciona canal 1, 6 o 11 (2.4GHz) o canal 36/149 (5GHz)","Olvida la red WiFi y reconéctate desde cero","Usa WiFi Analyzer para ver los canales congestionados y elegir el menos usado","Si es laptop, desactiva el modo avión y vuélvelo a activar como truco de reset"]',
 '["WiFi Analyzer","Driver del fabricante del adaptador","Router admin panel"]',
 '["netsh wlan show interfaces","netsh wlan show profiles","netsh wlan disconnect","netsh wlan connect name=NombreWiFi","netsh wlan set autoconfig enabled=yes interface=Wi-Fi"]',
 '["Cambiar el canal del router afecta a todos los dispositivos conectados"]',
 'facil', 20, 0, 1,
 'Los adaptadores WiFi integrados en laptops baratas suelen tener drivers problemáticos. Considera un adaptador USB WiFi de calidad.');

-- Problema 30: Sin sonido
INSERT INTO soluciones (problema_id, titulo, resumen, pasos, herramientas, comandos, adversencias, dificultad, tiempo_minutos, requiere_reinicio, requiere_admin, notas) VALUES
(30, 'Reparación completa de audio en Windows',
 'Diagnóstico desde el mezclador de volumen hasta reinstalación de drivers.',
 '["Haz clic derecho en el ícono de volumen → Solucionar problemas de sonido","Verifica que el dispositivo de reproducción correcto esté como Predeterminado","Haz clic derecho en el escritorio de audio → Mostrar dispositivos deshabilitados","Abre el Mezclador de volumen y verifica que ninguna aplicación esté en mute","En services.msc verifica que Windows Audio y Windows Audio Endpoint Builder estén en Automático y ejecutándose","Actualiza el driver de audio desde el Administrador de dispositivos","Si eso falla, desinstala el driver y reinicia (Windows lo reinstalará)","Descarga el driver desde el sitio del fabricante de la placa madre (Realtek, etc.)","Revisa el BIOS: verifica que el audio integrado esté habilitado"]',
 '["Administrador de dispositivos","services.msc","Realtek HD Audio Manager (si aplica)"]',
 '["services.msc","mmsys.cpl","sndvol"]',
 '[]',
 'facil', 20, 1, 1,
 'Si usas tarjeta de sonido dedicada, descarga el driver específico del fabricante.');

-- Problema 37: BSOD
INSERT INTO soluciones (problema_id, titulo, resumen, pasos, herramientas, comandos, advertencias, dificultad, tiempo_minutos, requiere_reinicio, requiere_admin, notas, url_referencia) VALUES
(37, 'Diagnóstico y solución de pantalla azul (BSOD)',
 'Analizar el volcado de memoria para identificar el driver o componente responsable.',
 '["Anota el código de STOP (ej: IRQL_NOT_LESS_OR_EQUAL, PAGE_FAULT_IN_NONPAGED_AREA)","Busca el código en Google + Microsoft Docs para la causa probable","Arranca en Modo Seguro: Shift + Reiniciar → Solucionar problemas → Opciones avanzadas → Configuración de inicio","Desde CMD como administrador ejecuta: sfc /scannow","Luego: DISM /Online /Cleanup-Image /RestoreHealth","Instala WinDbg Preview desde Microsoft Store para analizar archivos .dmp","Los archivos de volcado están en C:\\Windows\\Minidump","Descarga e instala el último driver de chipset","Si el BSOD está ligado a un driver específico (lo muestra WhoCrashed): desinstálalo","Verifica la RAM con MemTest86 overnight","Verifica el disco con chkdsk C: /f /r"]',
 '["WinDbg Preview","WhoCrashed","MemTest86","CrystalDiskInfo","Driver Booster"]',
 '["sfc /scannow","DISM /Online /Cleanup-Image /RestoreHealth","chkdsk C: /f /r","verifier /standard /all","verifier /reset"]',
 '["verifier puede causar más BSOD si hay drivers malos; úsalo solo para diagnóstico y luego ejecuta verifier /reset"]',
 'avanzado', 60, 1, 1,
 'Guarda los archivos .dmp de C:\\Windows\\Minidump antes de reinstalar Windows.',
 'https://docs.microsoft.com/windows-hardware/drivers/debugger/');

-- Problema 38: Windows no inicia
INSERT INTO soluciones (problema_id, titulo, resumen, pasos, herramientas, comandos, advertencias, dificultad, tiempo_minutos, requiere_reinicio, requiere_admin, notas) VALUES
(38, 'Reparación de Windows que no inicia o entra en bucle',
 'Reparar el arranque, BCD y archivos del sistema sin reinstalar Windows.',
 '["Arranca desde una USB de instalación de Windows (mismo idioma y versión)","Selecciona Reparar el equipo → Solucionar problemas → Opciones avanzadas","Intenta Reparación de inicio automática primero","Si falla, ve a Símbolo del sistema y ejecuta:","bootrec /fixmbr","bootrec /fixboot","bootrec /rebuildbcd","Si sigue fallando: sfc /scannow /offbootdir=C:\\ /offwindir=C:\\Windows","Como último recurso antes de reinstalar: DISM /Image:C:\\ /Cleanup-Image /RestoreHealth","Si nada funciona, realiza una reinstalación conservando archivos personales"]',
 '["USB de instalación de Windows","Rufus (para crear USB booteable)","Medios de recuperación del fabricante"]',
 '["bootrec /fixmbr","bootrec /fixboot","bootrec /scanos","bootrec /rebuildbcd","bcdboot C:\\Windows /s C: /f ALL"]',
 '["Ten un backup actualizado antes de cualquier operación de reparación de arranque","bootrec /fixboot puede fallar en discos GPT; usa bcdboot en su lugar"]',
 'avanzado', 50, 1, 1,
 'Crea siempre una unidad de recuperación de Windows en una USB de 16GB.');

-- Problema 39: Windows Update falla
INSERT INTO soluciones (problema_id, titulo, resumen, pasos, herramientas, comandos, advertencias, dificultad, tiempo_minutos, requiere_reinicio, requiere_admin, notas) VALUES
(39, 'Solución a errores de Windows Update',
 'Limpiar la caché de actualizaciones y reiniciar los servicios relacionados.',
 '["Ejecuta el Solucionador de problemas de Windows Update: Configuración → Sistema → Solucionar problemas","Para solución manual, abre CMD como administrador y ejecuta los pasos siguientes","net stop wuauserv","net stop cryptSvc","net stop bits","net stop msiserver","Renombra las carpetas de caché: ren C:\\Windows\\SoftwareDistribution SoftwareDistribution.old","ren C:\\Windows\\System32\\catroot2 catroot2.old","Reinicia los servicios: net start wuauserv, cryptSvc, bits, msiserver","Intenta actualizar nuevamente","Si un error específico persiste (ej: 0x80070002), busca el código en catalog.update.microsoft.com"]',
 '["Windows Update Troubleshooter","Microsoft Update Catalog","DISM"]',
 '["net stop wuauserv","net stop bits","net stop cryptSvc","ren C:\\Windows\\SoftwareDistribution SoftwareDistribution.old","net start wuauserv","wuauclt /resetauthorization /detectnow","usoclient StartScan"]',
 '["Renombrar SoftwareDistribution fuerza la re-descarga de todas las actualizaciones pendientes"]',
 'medio', 25, 1, 1,
 'Si el error persiste, descarga la actualización manualmente desde el Catálogo de Microsoft Update.');

-- Problema 48: USB no reconoce
INSERT INTO soluciones (problema_id, titulo, resumen, pasos, herramientas, comandos, advertencias, dificultad, tiempo_minutos, requiere_reinicio, requiere_admin, notas) VALUES
(48, 'Solución para puerto USB que no reconoce dispositivos',
 'Desde deshabilitar el ahorro de energía USB hasta reinstalar los controladores.',
 '["Prueba el dispositivo USB en otro puerto del equipo","Prueba el mismo dispositivo en otro equipo para descartar que el dispositivo esté dañado","Abre Administrador de dispositivos → Controladores de bus serie universal","Haz clic derecho en cada controlador USB y selecciona Desinstalar dispositivo","Reinicia el equipo (Windows reinstalará los controladores automáticamente)","En las propiedades de cada concentrador USB: pestaña Administración de energía → desmarca la opción de ahorro de energía","Verifica en el BIOS que los puertos USB estén habilitados","Descarga el driver de chipset actualizado (Intel/AMD) desde el sitio del fabricante"]',
 '["Administrador de dispositivos","USBDeview (NirSoft)","Driver de chipset del fabricante"]',
 '["devmgmt.msc","usbview.exe","pnputil /scan-devices"]',
 '["Al desinstalar los controladores USB, el mouse y teclado USB dejarán de funcionar hasta el reinicio"]',
 'facil', 20, 1, 1,
 'Los hubs USB de mala calidad o con exceso de dispositivos pueden causar este problema.');

-- Problema 57: Disco lleno
INSERT INTO soluciones (problema_id, titulo, resumen, pasos, herramientas, comandos, advertencias, dificultad, tiempo_minutos, requiere_reinicio, requiere_admin, notas) VALUES
(57, 'Liberar espacio en disco de forma segura y efectiva',
 'Limpieza sistemática: temporales, archivos del sistema, hibernación, puntos de restauración.',
 '["Ejecuta Liberador de espacio en disco (cleanmgr.exe) → selecciona todos los tipos","Haz clic en Limpiar archivos del sistema para más opciones incluyendo actualizaciones anteriores","Deshabilita la hibernación si no la usas: powercfg /hibernate off (libera RAM×1 en espacio)","Reduce el espacio de Puntos de restauración: Panel de control → Sistema → Protección → Configurar","Usa WinDirStat para visualizar qué carpetas ocupan más espacio","Desinstala aplicaciones que no usas desde Configuración → Aplicaciones","Mueve Documentos, Fotos y Vídeos a un disco externo o OneDrive","Vacía las carpetas: %TEMP%, C:\\Windows\\Temp, C:\\Windows\\Prefetch","Comprime archivos raramente usados con 7-Zip"]',
 '["WinDirStat","TreeSize Free","7-Zip","Liberador de espacio en disco"]',
 '["cleanmgr.exe","del /q /f /s %TEMP%\\*","powercfg /hibernate off","compact /compactos:always /EXE:LZX"]',
 '["No elimines archivos de C:\\Windows ni de C:\\Program Files manualmente","compact /compactos puede causar lentitud en equipos con CPU vieja"]',
 'facil', 25, 0, 1,
 'Mantén mínimo 15% libre en el disco del sistema para que Windows funcione correctamente.');

-- Problema 62: Virus/Malware
INSERT INTO soluciones (problema_id, titulo, resumen, pasos, herramientas, comandos, advertencias, dificultad, tiempo_minutos, requiere_reinicio, requiere_admin, notas) VALUES
(62, 'Eliminación completa de virus y malware',
 'Proceso profesional de limpieza en múltiples capas para infecciones graves.',
 '["Desconecta el equipo de internet y de la red local","Reinicia en Modo Seguro con funciones de red: Shift + Reiniciar → Opciones avanzadas","Ejecuta análisis completo con Windows Defender: Seguridad de Windows → Análisis completo","Descarga y ejecuta Malwarebytes Free desde un USB limpio","Descarga y ejecuta AdwCleaner para adware y secuestradores de navegador","Revisa los programas de inicio con Autoruns (Sysinternals): elimina entradas sospechosas","Revisa extensiones de todos los navegadores: elimina las desconocidas","Cambia TODAS las contraseñas desde un dispositivo limpio","Activa la autenticación en dos pasos en tus cuentas importantes","Si el malware persiste: considera reinstalación limpia de Windows"]',
 '["Windows Defender","Malwarebytes Free","AdwCleaner","Autoruns","HijackThis","Norton Power Eraser"]',
 '["msconfig","regedit (HKLM\\Software\\Microsoft\\Windows\\CurrentVersion\\Run)","sc query state= all"]',
 '["No conectes el equipo infectado a la red hasta estar seguro de la limpieza","Algunos ransomware simulan ser antivirus; no instales nada que no hayas buscado tú"]',
 'medio', 90, 1, 1,
 'Después de la limpieza, instala un antivirus de tiempo real. Windows Defender es suficiente si se mantiene actualizado.');

-- Problema 63: Ransomware
INSERT INTO soluciones (problema_id, titulo, resumen, pasos, herramientas, comandos, advertencias, dificultad, tiempo_minutos, requiere_reinicio, requiere_admin, notas, url_referencia) VALUES
(63, 'Respuesta ante ataque de ransomware',
 'Pasos de contención y recuperación. NO pagues el rescate.',
 '["Desconecta INMEDIATAMENTE el equipo de la red: desenchufa el cable de red y desactiva WiFi","Apaga el equipo si el cifrado está en proceso","Identifica la variante del ransomware con el sitio ID Ransomware (uploading nota de rescate)","Busca en nomoreransom.org si hay un descifrador gratuito disponible","Reporta el incidente a la Policía Nacional / CERT nacional","Limpia el sistema con una reinstalación completa de Windows desde USB","Restaura archivos desde un backup limpio anterior a la infección","Si no hay backup: algunos archivos pueden recuperarse con Recuva si no fueron sobrescritos","NUNCA pagues el rescate: no garantiza la recuperación y financia el crimen"]',
 '["Herramientas de descifrado de nomoreransom.org","Recuva (recuperación de archivos)","Kaspersky Decryptors","Emsisoft Decryptor"]',
 '[]',
 '["NO reinicies el equipo durante el cifrado activo: puede corromper más archivos","NO pagues: el 40% de quienes pagan no recuperan sus archivos"]',
 'experto', 120, 0, 0,
 'La mejor defensa es backup 3-2-1: 3 copias, 2 medios distintos, 1 fuera del sitio.',
 'https://www.nomoreransom.org');

-- Problema 67: Impresora no imprime
INSERT INTO soluciones (problema_id, titulo, resumen, pasos, herramientas, comandos, advertencias, dificultad, tiempo_minutos, requiere_reinicio, requiere_admin, notas) VALUES
(67, 'Diagnóstico completo cuando la impresora no imprime',
 'Desde limpiar la cola de impresión hasta reinstalar el driver completo.',
 '["Verifica que la impresora esté encendida, conectada y sin errores en su pantalla","Reinicia el servicio Cola de impresión: services.msc → Print Spooler → Reiniciar","Limpia la cola de impresión manualmente:","net stop spooler","del /Q /F /S C:\\Windows\\System32\\spool\\PRINTERS\\*","net start spooler","Imprime una página de prueba desde las propiedades de la impresora","Desinstala completamente el driver desde Panel de control → Dispositivos e impresoras","Descarga el driver completo (no el básico) del sitio oficial del fabricante","Si es por red: verifica que la impresora tenga IP estática y sea accesible con ping"]',
 '["Print Management Console","Administrador de dispositivos","Driver oficial del fabricante"]',
 '["net stop spooler","net start spooler","del /Q /F /S C:\\Windows\\System32\\spool\\PRINTERS\\*","ping [IP-impresora]"]',
 '["Detener el spooler cancela todos los trabajos de impresión pendientes"]',
 'facil', 20, 0, 1,
 'Las impresoras HP tienen HP Print and Scan Doctor, una herramienta muy útil para diagnóstico automático.');

-- Problema 71: Outlook falla
INSERT INTO soluciones (problema_id, titulo, resumen, pasos, herramientas, comandos, advertencias, dificultad, tiempo_minutos, requiere_reinicio, requiere_admin, notas) VALUES
(71, 'Solución cuando Outlook no abre o se congela',
 'Reparar el perfil, el archivo PST y las rutas de carga de Outlook.',
 '["Abre Outlook en Modo Seguro: outlook.exe /safe","Si abre correctamente, el problema es un complemento: deshabilita todos en Archivo → Opciones → Complementos","Ejecuta la herramienta de reparación de Outlook (ScanPST.exe):","Ubicación: C:\\Program Files (x86)\\Microsoft Office\\root\\Office16\\","Selecciona el archivo .pst o .ost y ejecuta la reparación","Crea un nuevo perfil de Outlook: Panel de control → Correo → Mostrar perfiles → Agregar","Si usas Microsoft 365: ejecuta el Asistente de soporte y recuperación de Microsoft (SaRA)","Repara Office: Panel de control → Programas → Microsoft Office → Cambiar → Reparación rápida"]',
 '["ScanPST.exe","Microsoft Support and Recovery Assistant (SaRA)","Outlook /safe"]',
 '["outlook.exe /safe","outlook.exe /cleanviews","outlook.exe /resetnavpane","outlook.exe /profiles"]',
 '["ScanPST puede tardar horas en archivos PST grandes (>5GB)"]',
 'medio', 35, 0, 0,
 'Los archivos PST no deben superar 20GB. Configura el archivado automático.');

-- Problema 73: Excel falla
INSERT INTO soluciones (problema_id, titulo, resumen, pasos, herramientas, comandos, advertencias, dificultad, tiempo_minutos, requiere_reinicio, requiere_admin, notas) VALUES
(73, 'Solución cuando Excel se cierra o pierde datos',
 'Recuperar archivos no guardados y prevenir pérdidas futuras.',
 '["Busca archivos de autorrecuperación en: C:\\Users\\[usuario]\\AppData\\Roaming\\Microsoft\\Excel\\","Abre Excel → Archivo → Información → Administrar libro → Recuperar libros no guardados","Reduce el intervalo de autoguardado: Archivo → Opciones → Guardar → cada 2 minutos","Deshabilita los complementos de Excel: Archivo → Opciones → Complementos → Ir → desmarca todos","Si el archivo está corrupto: Archivo → Abrir → navega al archivo → flecha en Abrir → Abrir y reparar","Guarda siempre en formato .xlsx, no en .xls","Activa OneDrive para guardado automático en la nube","Verifica que Office esté completamente actualizado"]',
 '["Microsoft Support and Recovery Assistant","OneDrive"]',
 '[]',
 '["No abrir archivos .xlsx de fuentes desconocidas (pueden contener macros maliciosas)"]',
 'facil', 20, 0, 0,
 'Si el problema es recurrente, considera reparar Office completo desde el Panel de control.');

-- ============================================================
-- SEED: USUARIOS DE EJEMPLO
-- ============================================================
INSERT INTO usuarios (nombre, email, telefono, departamento, rol) VALUES
('Admin Sistema',    'admin@empresa.com',    '987654321', 'TI',             'admin'),
('Carlos Mendoza',   'carlos@empresa.com',   '987111222', 'TI',             'tecnico'),
('Rosa Huamán',      'rosa@empresa.com',     '987333444', 'TI',             'tecnico'),
('Luis García',      'luis@empresa.com',     '987555666', 'Contabilidad',   'usuario'),
('María Ríos',       'maria@empresa.com',    '987777888', 'Ventas',         'usuario'),
('Pedro Castillo',   'pedro@empresa.com',    '987999000', 'Logística',      'usuario'),
('Ana Torres',       'ana@empresa.com',      '986111222', 'RRHH',           'usuario'),
('Jorge Vargas',     'jorge@empresa.com',    '986333444', 'Gerencia',       'usuario'),
('Lucía Quispe',     'lucia@empresa.com',    '986555666', 'Marketing',      'usuario'),
('Miguel Flores',    'miguel@empresa.com',   '986777888', 'TI',             'tecnico');

INSERT INTO tecnicos (usuario_id, especialidad, nivel) VALUES
(2,  'Hardware, Windows, Redes',                    'senior'),
(3,  'Software, Office, Correo',                    'semi'),
(10, 'Seguridad, Servidores, Virtualización',       'experto');

-- ============================================================
-- SEED: DISPOSITIVOS DE EJEMPLO
-- ============================================================
INSERT INTO dispositivos (usuario_id, tipo, marca, modelo, sistema_op, ram_gb, almacenamiento_gb, procesador, fecha_compra) VALUES
(4,  'Desktop',  'HP',     'ProDesk 400 G7',   'Windows 11 Pro',   16, 512,  'Intel Core i5-10500',  '2022-03-15'),
(5,  'Laptop',   'Dell',   'Latitude 5420',    'Windows 10 Pro',   8,  256,  'Intel Core i5-1135G7', '2021-07-20'),
(6,  'Desktop',  'Lenovo', 'ThinkCentre M70q', 'Windows 11 Pro',   8,  512,  'Intel Core i3-10100T', '2023-01-10'),
(7,  'Laptop',   'HP',     'EliteBook 840 G8', 'Windows 11 Pro',   16, 512,  'Intel Core i7-1165G7', '2022-11-05'),
(8,  'Desktop',  'Custom', 'Ensamblado',       'Windows 11 Pro',   32, 1000, 'AMD Ryzen 9 5900X',    '2021-12-01'),
(9,  'Laptop',   'Asus',   'VivoBook 15',      'Windows 10 Home',  8,  512,  'AMD Ryzen 5 4500U',    '2020-09-14'),
(10, 'Servidor', 'Dell',   'PowerEdge T40',    'Windows Server 2022', 32, 2000, 'Intel Xeon E-2224', '2022-06-01');

-- ============================================================
-- SEED: TICKETS DE EJEMPLO
-- ============================================================
INSERT INTO tickets (usuario_id, tecnico_id, categoria_id, problema_id, titulo, descripcion, severidad, estado, sistema_op, resuelto, calificacion) VALUES
(4, 1, 1, 1,  'PC muy lenta al iniciar', 'El equipo tarda más de 5 minutos en estar listo tras encender.', 'Moderado',  'Resuelto',    'Windows 11 Pro',   1, 5),
(5, 2, 5, 37, 'Pantalla azul recurrente', 'BSOD aparece 2-3 veces por día con error MEMORY_MANAGEMENT.', 'Crítico',   'En proceso',  'Windows 10 Pro',   NULL, NULL),
(6, 1, 3, 20, 'Sin internet solo en mi PC', 'Los demás equipos sí tienen internet, el mío no.', 'Leve',      'Resuelto',    'Windows 11 Pro',   1, 4),
(7, 3, 8, 62, 'Sospecha de virus', 'El antivirus se desactivó solo y aparecen ventanas extrañas.', 'Urgente',   'Resuelto',    'Windows 11 Pro',   1, 5),
(9, 2, 10,71, 'Outlook no abre', 'Al intentar abrir Outlook aparece pantalla de carga y luego se cierra.', 'Moderado', 'Abierto',   'Windows 10 Home',  NULL, NULL),
(6, 1, 9, 67, 'Impresora no imprime', 'La impresora del área de logística no imprime desde ayer.', 'Moderado',  'Cerrado',     'Windows 11 Pro',   1, 3),
(4, 3, 7, 57, 'Disco casi lleno', 'Solo queda 2GB libres en el disco C.', 'Leve',      'Resuelto',    'Windows 11 Pro',   1, 5),
(8, 1, 2, 18, 'Driver de GPU falla', 'Después de actualizar Windows, la pantalla parpadea.', 'Crítico',   'En proceso',  'Windows 11 Pro',   NULL, NULL);

INSERT INTO ticket_comentarios (ticket_id, usuario_id, texto, es_interno) VALUES
(1, 2, 'Revisé el inicio y había 23 programas arrancando. Los reduje a 4 esenciales. Tiempo de inicio bajó de 5 min a 45 seg.', 0),
(1, 4, 'Perfecto, ahora arranca rápido. Muchas gracias!', 0),
(2, 2, 'El análisis de WhoCrashed apunta a un driver de audio de terceros. Procediendo a desinstalar.', 1),
(2, 3, 'Nota interna: también revisar la RAM con MemTest86. El MEMORY_MANAGEMENT puede ser RAM defectuosa.', 1),
(4, 3, 'Malwarebytes encontró 3 troyanos y un keylogger. Limpieza completada. Se cambió contraseña de todos sus accesos.', 0),
(4, 7, 'Qué susto, ya estoy más tranquila. Gracias por actuar rápido.', 0);

-- ============================================================
-- VISTAS
-- ============================================================

CREATE VIEW v_problemas_completos AS
SELECT
    p.id, p.nombre AS problema,
    c.nombre AS categoria, c.icono,
    sc.nombre AS subcategoria,
    p.frecuencia, p.activo
FROM problemas p
JOIN categorias c ON p.categoria_id = c.id
LEFT JOIN subcategorias sc ON p.subcategoria_id = sc.id;

CREATE VIEW v_soluciones_completas AS
SELECT
    s.id, s.titulo, s.dificultad, s.tiempo_minutos,
    s.votos_utiles, s.votos_inutiles, s.vistas,
    s.requiere_reinicio, s.requiere_admin,
    p.nombre AS problema,
    c.nombre AS categoria,
    s.creado_en
FROM soluciones s
JOIN problemas p ON s.problema_id = p.id
JOIN categorias c ON p.categoria_id = c.id;

CREATE VIEW v_tickets_completos AS
SELECT
    t.id, t.titulo, t.estado, t.severidad, t.prioridad,
    t.creado_en, t.resuelto_en, t.calificacion,
    u.nombre AS usuario, u.departamento,
    us.nombre AS tecnico,
    c.nombre AS categoria,
    p.nombre AS problema,
    DATEDIFF(MINUTE, t.creado_en, ISNULL(t.resuelto_en, GETDATE())) AS minutos_transcurridos
FROM tickets t
LEFT JOIN usuarios u  ON t.usuario_id  = u.id
LEFT JOIN tecnicos tc ON t.tecnico_id  = tc.id
LEFT JOIN usuarios us ON tc.usuario_id = us.id
LEFT JOIN categorias c ON t.categoria_id = c.id
LEFT JOIN problemas  p ON t.problema_id  = p.id;

CREATE VIEW v_estadisticas AS
SELECT
    (SELECT COUNT(*) FROM categorias  WHERE activo = 1)                    AS total_categorias,
    (SELECT COUNT(*) FROM problemas   WHERE activo = 1)                    AS total_problemas,
    (SELECT COUNT(*) FROM soluciones)                                       AS total_soluciones,
    (SELECT COUNT(*) FROM usuarios    WHERE activo = 1)                    AS total_usuarios,
    (SELECT COUNT(*) FROM tecnicos)                                         AS total_tecnicos,
    (SELECT COUNT(*) FROM tickets)                                          AS total_tickets,
    (SELECT COUNT(*) FROM tickets WHERE estado = 'Abierto')                AS tickets_abiertos,
    (SELECT COUNT(*) FROM tickets WHERE estado = 'En proceso')             AS tickets_en_proceso,
    (SELECT COUNT(*) FROM tickets WHERE estado IN ('Resuelto','Cerrado'))   AS tickets_resueltos,
    (SELECT COUNT(*) FROM tickets WHERE CAST(creado_en AS DATE) = CAST(GETDATE() AS DATE)) AS tickets_hoy,
    (SELECT AVG(CAST(calificacion AS FLOAT)) FROM tickets WHERE calificacion IS NOT NULL)  AS calificacion_promedio;

CREATE VIEW v_tecnico_rendimiento AS
SELECT
    u.nombre AS tecnico,
    tc.nivel,
    tc.especialidad,
    COUNT(t.id)                                          AS tickets_totales,
    SUM(CASE WHEN t.resuelto = 1 THEN 1 ELSE 0 END)     AS tickets_resueltos,
    AVG(CAST(t.calificacion AS FLOAT))                   AS calificacion_prom,
    AVG(DATEDIFF(MINUTE, t.creado_en, t.resuelto_en))   AS tiempo_resolucion_prom_min
FROM tecnicos tc
JOIN usuarios  u ON tc.usuario_id = u.id
LEFT JOIN tickets t ON t.tecnico_id = tc.id
GROUP BY u.nombre, tc.nivel, tc.especialidad;

-- ============================================================
-- STORED PROCEDURES
-- ============================================================

CREATE PROCEDURE sp_BuscarSolucion
    @problema_id INT,
    @severidad   NVARCHAR(20) = 'Leve'
AS
BEGIN
    -- Retorna la mejor solución según severidad
    SELECT TOP 1 s.*, p.nombre AS problema, c.nombre AS categoria, c.icono
    FROM soluciones s
    JOIN problemas p ON s.problema_id = p.id
    JOIN categorias c ON p.categoria_id = c.id
    WHERE s.problema_id = @problema_id
    ORDER BY
        CASE @severidad
            WHEN 'Crítico' THEN CASE s.dificultad WHEN 'experto' THEN 1 WHEN 'avanzado' THEN 2 WHEN 'medio' THEN 3 ELSE 4 END
            WHEN 'Urgente' THEN CASE s.dificultad WHEN 'experto' THEN 1 WHEN 'avanzado' THEN 2 WHEN 'medio' THEN 3 ELSE 4 END
            ELSE CASE s.dificultad WHEN 'facil' THEN 1 WHEN 'medio' THEN 2 WHEN 'avanzado' THEN 3 ELSE 4 END
        END,
        s.votos_utiles DESC;

    -- Incrementar contador de vistas
    UPDATE problemas SET frecuencia = frecuencia + 1 WHERE id = @problema_id;
END;
GO

CREATE PROCEDURE sp_CrearTicket
    @usuario_id  INT,
    @categoria_id INT,
    @problema_id  INT,
    @titulo       NVARCHAR(255),
    @descripcion  NVARCHAR(MAX),
    @severidad    NVARCHAR(20),
    @sistema_op   NVARCHAR(50) = NULL
AS
BEGIN
    DECLARE @tecnico_id INT;

    -- Asignar técnico disponible con menos tickets abiertos
    SELECT TOP 1 @tecnico_id = tc.id
    FROM tecnicos tc
    WHERE tc.disponible = 1
    ORDER BY (
        SELECT COUNT(*) FROM tickets t
        WHERE t.tecnico_id = tc.id AND t.estado IN ('Abierto', 'En proceso')
    ) ASC;

    INSERT INTO tickets (usuario_id, tecnico_id, categoria_id, problema_id, titulo, descripcion, severidad, sistema_op)
    VALUES (@usuario_id, @tecnico_id, @categoria_id, @problema_id, @titulo, @descripcion, @severidad, @sistema_op);

    SELECT SCOPE_IDENTITY() AS nuevo_ticket_id, @tecnico_id AS tecnico_asignado_id;
END;
GO

CREATE PROCEDURE sp_CerrarTicket
    @ticket_id   INT,
    @solucion_id INT,
    @resuelto    BIT,
    @calificacion INT = NULL,
    @comentario  NVARCHAR(500) = NULL
AS
BEGIN
    UPDATE tickets SET
        solucion_id       = @solucion_id,
        resuelto          = @resuelto,
        estado            = CASE WHEN @resuelto = 1 THEN 'Resuelto' ELSE 'Cerrado' END,
        calificacion      = @calificacion,
        comentario_cierre = @comentario,
        resuelto_en       = GETDATE(),
        actualizado_en    = GETDATE()
    WHERE id = @ticket_id;

    -- Actualizar stats del técnico
    DECLARE @tec_id INT;
    SELECT @tec_id = tecnico_id FROM tickets WHERE id = @ticket_id;

    IF @resuelto = 1 AND @tec_id IS NOT NULL
        UPDATE tecnicos SET tickets_resueltos = tickets_resueltos + 1 WHERE id = @tec_id;
END;
GO

CREATE PROCEDURE sp_RegistrarConsulta
    @categoria_id INT,
    @problema_id  INT,
    @solucion_id  INT = NULL,
    @severidad    NVARCHAR(20) = 'Leve',
    @ip_cliente   NVARCHAR(50) = NULL
AS
BEGIN
    INSERT INTO consultas (categoria_id, problema_id, solucion_id, severidad, ip_cliente)
    VALUES (@categoria_id, @problema_id, @solucion_id, @severidad, @ip_cliente);
    SELECT SCOPE_IDENTITY() AS nueva_consulta_id;
END;
GO

CREATE PROCEDURE sp_DarFeedback
    @consulta_id INT,
    @resuelto    BIT
AS
BEGIN
    UPDATE consultas SET resuelto = @resuelto WHERE id = @consulta_id;

    DECLARE @sol_id INT;
    SELECT @sol_id = solucion_id FROM consultas WHERE id = @consulta_id;

    IF @sol_id IS NOT NULL
    BEGIN
        IF @resuelto = 1
            UPDATE soluciones SET votos_utiles   = votos_utiles   + 1 WHERE id = @sol_id;
        ELSE
            UPDATE soluciones SET votos_inutiles = votos_inutiles + 1 WHERE id = @sol_id;
    END
END;
GO

CREATE PROCEDURE sp_BuscarPorPalabraClave
    @termino NVARCHAR(100)
AS
BEGIN
    SELECT p.id, p.nombre AS problema, c.nombre AS categoria, c.icono,
           (SELECT COUNT(*) FROM soluciones s WHERE s.problema_id = p.id) AS num_soluciones
    FROM problemas p
    JOIN categorias c ON p.categoria_id = c.id
    WHERE p.activo = 1
      AND (p.nombre LIKE '%' + @termino + '%'
        OR p.palabras_clave LIKE '%' + @termino + '%'
        OR c.nombre LIKE '%' + @termino + '%')
    ORDER BY p.frecuencia DESC;
END;
GO

-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================
