[Setup]
; Información de Aplicación
AppId={{D1A2B3C4-E5F6-7890-12A3-B4C5D6E7F800}
AppName=SHA Generator
AppVersion=1.0.0
AppPublisher=Jorge Vázquez
AppPublisherURL=https://github.com/jorge-rtv21/SHA_Generator
AppSupportURL=https://github.com/jorge-rtv21/SHA_Generator
AppUpdatesURL=https://github.com/jorge-rtv21/SHA_Generator

; Ícono del instalador y del acceso directo de desinstalación
SetupIconFile=assets\icon.ico
UninstallDisplayIcon={app}\appSHAGenerator.exe

; Rutas de Instalación (Acuerdo local "Archivos de Programa")
DefaultDirName={autopf}\SHA_Generator
DisableProgramGroupPage=yes

; Salida del Instalador
OutputDir=.\InnoOutput
OutputBaseFilename=Instalar_SHAGenerator_v1.0
Compression=lzma
SolidCompression=yes

; Estética y Funcionalidad
LanguageDetectionMethod=uilanguage
WizardStyle=modern

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Copiar el ejecutable base y toda la distribución de `dist\` (Librerías, Plugins Qt, etc.) al destino.
Source: "dist\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
; Crear el Icono en el Menú Inicio
Name: "{autoprograms}\SHA Generator"; Filename: "{app}\appSHAGenerator.exe"
; Crear el Icono en el Escritorio (si el usuario marca la casilla)
Name: "{autodesktop}\SHA Generator"; Filename: "{app}\appSHAGenerator.exe"; Tasks: desktopicon

[Run]
; Ofrecer arrancar la app al finalizar
Filename: "{app}\appSHAGenerator.exe"; Description: "{cm:LaunchProgram,SHA Generator}"; Flags: nowait postinstall skipifsilent

[Registry]
; Integración con Explorador de Windows (Menú Clic Derecho en Cascada)
Root: HKCR; Subkey: "*\shell\SHAGenerator"; ValueType: string; ValueName: "MUIVerb"; ValueData: "Calcular Hash"; Flags: uninsdeletekey
Root: HKCR; Subkey: "*\shell\SHAGenerator"; ValueType: string; ValueName: "Icon"; ValueData: """{app}\appSHAGenerator.exe"""; Flags: uninsdeletekey
Root: HKCR; Subkey: "*\shell\SHAGenerator"; ValueType: string; ValueName: "ExtendedSubCommandsKey"; ValueData: "*\shell\SHAGenerator"; Flags: uninsdeletekey

Root: HKCR; Subkey: "*\shell\SHAGenerator\shell\cmd1"; ValueType: string; ValueName: "MUIVerb"; ValueData: "Abrir en Ventana Principal"; Flags: uninsdeletekey
Root: HKCR; Subkey: "*\shell\SHAGenerator\shell\cmd1\command"; ValueType: string; ValueData: """{app}\appSHAGenerator.exe"" --open ""%1"""; Flags: uninsdeletekey

Root: HKCR; Subkey: "*\shell\SHAGenerator\shell\cmd2"; ValueType: string; ValueName: "MUIVerb"; ValueData: "SHA-256 (Silencioso)"; Flags: uninsdeletekey
Root: HKCR; Subkey: "*\shell\SHAGenerator\shell\cmd2\command"; ValueType: string; ValueData: """{app}\appSHAGenerator.exe"" --cli --algo sha256 --file ""%1"""; Flags: uninsdeletekey

Root: HKCR; Subkey: "*\shell\SHAGenerator\shell\cmd3"; ValueType: string; ValueName: "MUIVerb"; ValueData: "MD5 (Silencioso)"; Flags: uninsdeletekey
Root: HKCR; Subkey: "*\shell\SHAGenerator\shell\cmd3\command"; ValueType: string; ValueData: """{app}\appSHAGenerator.exe"" --cli --algo md5 --file ""%1"""; Flags: uninsdeletekey

Root: HKCR; Subkey: "*\shell\SHAGenerator\shell\cmd4"; ValueType: string; ValueName: "MUIVerb"; ValueData: "SHA-512 (Silencioso)"; Flags: uninsdeletekey
Root: HKCR; Subkey: "*\shell\SHAGenerator\shell\cmd4\command"; ValueType: string; ValueData: """{app}\appSHAGenerator.exe"" --cli --algo sha512 --file ""%1"""; Flags: uninsdeletekey
