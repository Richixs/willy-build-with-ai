# Willy AI - Asistente de Escritura con IA 🤖📝

![Banner de Willy AI](https://i.imgur.com/F4a8yO4.jpeg)

**Willy AI** es una aplicación móvil multiplataforma, desarrollada con Flutter, que funciona como un asistente inteligente para mejorar la escritura en español. Utilizando el poder de la API de **Google Gemini**, la aplicación analiza textos y ofrece consejos constructivos sobre gramática, puntuación, coherencia y estilo, sin simplemente corregir el texto por ti.

---

## Características Principales

* ✅ **Análisis Gramatical Profundo**: Identifica errores de gramática, acentuación, puntuación y coherencia en el texto proporcionado.
* ✅ **Consejos Constructivos**: En lugar de darte la respuesta correcta, Willy AI te ofrece pistas y explicaciones para que aprendas y mejores tu escritura. ¡Aprende el "porqué" de cada corrección!
* ✅ **Soporte Multimodal**: ¿El texto está en una imagen? ¡No hay problema! Puedes subir una foto y Willy analizará el texto contenido en ella.
* ✅ **Interfaz de Chat Intuitiva**: La interacción se realiza a través de una interfaz de chat amigable y fácil de usar, construida con `dash_chat_2`.
* ✅ **Configuración Segura**: Manejo seguro de la clave de API utilizando variables de entorno para proteger tus credenciales.

---

## 🛠️ Tecnologías y Paquetes Utilizados

* **Framework**: [Flutter](https://flutter.dev/)
* **Modelo de IA**: [Google Gemini API](https://ai.google.dev/)
* **Cliente de API**: [flutter_gemini](https://pub.dev/packages/flutter_gemini)
* **UI de Chat**: [dash_chat_2](https://pub.dev/packages/dash_chat_2)
* **Gestión de Entorno**: [flutter_dotenv](https://pub.dev/packages/flutter_dotenv)
* **Selector de Imágenes**: [image_picker](https://pub.dev/packages/image_picker)

---

## Cómo Empezar

Sigue estos pasos para tener una copia del proyecto funcionando en tu máquina local.

### Prerrequisitos

* Tener el **SDK de Flutter** instalado. [Guía de instalación](https://docs.flutter.dev/get-started/install).
* Un editor de código como **VS Code** o **Android Studio**.

### Instalación

1.  **Clona el repositorio:**
    ```sh
    git clone [https://github.com/tu_usuario/willy-build-with-ai.git](https://github.com/tu_usuario/willy-build-with-ai.git)
    cd willy-build-with-ai
    ```
    2.  **Obtén una Clave de API de Gemini:**
    * Ve a [Google AI Studio](https://aistudio.google.com/app/apikey).
    * Haz clic en "**Create API key**" para generar una nueva clave.
    * Copia la clave generada. ¡La necesitarás en el siguiente paso!

3.  **Configura tus variables de entorno:**
    * En la raíz del proyecto, crea un archivo llamado `.env`.
    * Abre el archivo `.env` y añade la siguiente línea, reemplazando `TU_API_KEY_DE_GEMINI` con la clave que acabas de copiar:
    ```
    GEMINI_API_KEY=TU_API_KEY_DE_GEMINI
    ```

4.  **Instala las dependencias del proyecto:**
    ```sh
    flutter pub get
    ```

5.  **Ejecuta la aplicación:**
    ```sh
    flutter run
    ```

¡Y eso es todo! La aplicación debería compilarse y ejecutarse en tu emulador o dispositivo físico.

---

## Estructura del Código

El proyecto está organizado de una manera limpia y escalable para separar la lógica de la presentación.

* `📁 lib/main.dart`
    * Es el punto de entrada de la aplicación. Se encarga de inicializar los servicios esenciales (como `DotEnv` y `GeminiService`) antes de lanzar la aplicación.

* `📁 lib/services/gemini_service.dart`
    * **El cerebro de la aplicación.** Contiene toda la lógica para comunicarse con la API de Gemini. Aquí se encuentra el **prompt del sistema**, cuidadosamente diseñado para instruir al modelo a actuar como un experto en gramática y a formatear su respuesta en JSON.

* `📁 lib/views/chat_view.dart`
    * La capa de presentación. Construye la interfaz de usuario del chat, gestiona los mensajes y llama al `GeminiService` para obtener los análisis cuando el usuario envía un texto o una imagen.

---

## Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo `LICENSE` para más detalles.

---
