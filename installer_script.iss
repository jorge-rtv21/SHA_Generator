[Setup]
; Información de Aplicación
AppId={{D1A2B3C4-E5F6-7890-12A3-B4C5D6E7F800}
AppName=SHA Generator
AppVersion=1.0.0
AppPublisher=Jorge Vázquez
AppPublisherURL=https://github.com/jorge-rtv21/SHA_Generator
AppSupportURL=https://github.com/jorge-rtv21/SHA_Generator
AppUpdatesURL=https://github.com/jorge-rtv21/SHA_Generator

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
