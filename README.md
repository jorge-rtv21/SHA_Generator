# 📖 Manual de Uso - Generador SHA

¡Bienvenido al Generador SHA! Esta es una herramienta sencilla y rápida que te permite obtener la "huella digital" (un código único) de cualquier archivo, sin importar su tamaño. Esto sirve para comprobar que un archivo no ha sido modificado, dañado o alterado.

Puedes usar esta aplicación de dos maneras distintas: usando la ventana normal (ideal para todos) o usando comandos de consola (ideal para procesos automáticos).

---

## 🖥️ 1. Uso Normal (Con Ventana Visual - GUI)

Esta es la forma más fácil y tradicional de usar el programa.

**Pasos:**

1. **Abre el programa:** Ve a tu carpeta `dist/` y haz doble clic sobre el archivo **`appSHAGenerator.exe`**.
2. **Selecciona tu archivo:** Haz clic en el botón de la lupa (Examinar) para buscar en tu computadora el documento, video, o archivo que quieres analizar. **¡También puedes simplemente arrastrar y soltar el archivo directamente sobre la ventana!**
3. **Elige el tipo de código:** En el menú desplegable, selecciona el tipo de código de seguridad que necesitas. Casi siempre se usa **SHA-256**, por lo que ya está seleccionado por defecto. (Otras opciones incluyen MD5, SHA-512, etc.).
4. **Espera un momento:** Verás una barra de progreso. Si el archivo es muy grande, puede tardar unos segundos. **Tu computadora no se trabará** gracias a que el programa está preparado para archivos gigantes.
5. **Ve el resultado:** Al terminar, aparecerá un código largo en la pantalla.
6. **Guardar el resultado:** Haz clic en el botón de **Guardar**. Se creará automáticamente un nuevo archivo de texto junto a tu archivo original (Por ejemplo, si elegiste `video.mp4`, se creará uno nuevo llamado `video.mp4.sha256`) con el código dentro.
7. **Verificar un Hash (Opcional):** Si descargaste un archivo de internet y te dieron un código oficial para validarlo, puedes pegar ese código en la caja inferior que dice "Verificación". El programa te avisará inmediatamente con una etiqueta Verde de "✔ COINCIDE" si es auténtico, o Rojo de "✖ NO COINCIDE" si está modificado o dañado.

---

## 💻 2. Uso Avanzado (Por Consola o Línea de Comandos - CLI)

Si eres un usuario avanzado y deseas obtener esta "huella digital" desde otra aplicación (como Python) o usarla en un script rápido (como un `.bat`), el programa tiene un modo "invisible" o silencioso.

En este modo, **no se abrirá ninguna ventana**, el programa simplemente buscará el archivo, hará el cálculo rápido y creará el archivo `.sha256` (o el que hayas elegido) junto al original, para luego cerrarse.

### ¿Cómo usarlo?

Abre tu "Símbolo del Sistema" (CMD) o "PowerShell" y escribe el nombre del programa, seguido de los comandos necesarios.

**Los comandos importantes son:**

- `--cli` o `-c` : **Obligatorio.** Le dice al programa que NO abra la ventana gráfica y trabaje de forma invisible.
- `--file` o `-f` : **Obligatorio.** Sirve para decirle al programa la ruta de tu archivo. Debe ir entre comillas si tiene espacios.
- `--algo` o `-a` : _Opcional._ Sirve para elegir el tipo de algoritmo. Si no lo pones, usará `sha256`. Puedes escribir: `md5`, `sha1`, `sha224`, `sha256`, `sha384`, o `sha512`.

### 👉 Ejemplos Prácticos:

**Ejemplo 1: El uso más común (SHA-256 por defecto)**
Si quieres analizar el archivo "Instalador.iso" y sacar su código SHA-256.

```powershell
.\appSHAGenerator.exe --cli --file "C:\Descargas\Instalador.iso"
```

**Ejemplo 2: Versión corta del Ejemplo 1**
Lo mismo, pero escribiendo menos.

```powershell
.\appSHAGenerator.exe -c -f "C:\Descargas\Instalador.iso"
```

**Ejemplo 3: Usando otro algoritmo (MD5)**
Si una página web te pide comprobar por "MD5" un documento Word.

```powershell
.\appSHAGenerator.exe --cli --algo md5 --file "Documento.docx"
```

**Ejemplo 4: Usando SHA-512**

```powershell
.\appSHAGenerator.exe -c -a sha512 -f "D:\Respaldos\servidor.zip"
```

¡Eso es todo! Con estos simples pasos podrás verificar la seguridad y exactitud de tus archivos como todo un profesional.
