import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GrammarAnalysis {
  final String tips;
  GrammarAnalysis({required this.tips});
  factory GrammarAnalysis.fromJson(Map<String, dynamic> json) {
    return GrammarAnalysis(
      tips: json['tips'] as String? ?? 'No se recibieron sugerencias.',
    );
  }
}

class GeminiService {
  static const String geminiTextModel = "gemini-pro";
  static final Gemini gemini = Gemini.instance;

  static void initialize() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw StateError('API_KEY no encontrada en las variables de entorno.');
    }
    Gemini.init(apiKey: apiKey);
  }

  static Future<GrammarAnalysis> analyzeTextForTips({
    required String text,
    Uint8List? imageBytes,
  }) async {
    const systemInstruction = """Eres un experto en el idioma español. Tu tarea es analizar texto en español en busca de errores gramaticales, de coherencia, puntuación y acentuación. Proporciona consejos constructivos para ayudar al usuario a mejorar su escritura.
IMPORTANTE: NO proporciones la versión corregida del texto bajo ninguna circunstancia. En su lugar, da una lista de sugerencias y pistas, explicando el 'porqué' de cada una. Por ejemplo, si ves 'el agua es frio', podrías sugerir 'Pista: El sustantivo "agua" es femenino, por lo que los adjetivos que lo describen también deben ser femeninos. Intenta cambiar "frio" para que concuerde.'.
DEBES responder con un objeto JSON con una única clave "tips", que debe ser una cadena de texto que contenga una lista con viñetas (usando '- ' al principio de cada línea) de tus sugerencias. Si el texto es perfecto, el valor de 'tips' debe ser un mensaje de confirmación en español.

Aquí está el texto a analizar:
""";

    final fullPrompt = systemInstruction + (imageBytes != null ? "Analiza el texto de la imagen." : text);

    final imageList = imageBytes != null ? [imageBytes] : null;

    try {
      final responseStream = gemini.streamGenerateContent(
        fullPrompt,
        images: imageList,
        modelName: geminiTextModel,
      );


      final fullResponse = await responseStream.map((event) => event.output ?? "").join();
      if (fullResponse.isEmpty) {
        throw Exception("La respuesta de la IA estaba vacía.");
      }

      var jsonStr = fullResponse.trim();

      final fenceRegex = RegExp(r'^```(\w*)?\s*\n?(.*?)\n?\s*```$', dotAll: true);
      final match = fenceRegex.firstMatch(jsonStr);
      if (match != null && match.group(2) != null) {
        jsonStr = match.group(2)!.trim();
      }

      final parsedData = jsonDecode(jsonStr) as Map<String, dynamic>;
      return GrammarAnalysis.fromJson(parsedData);

    } catch (e) {
      print("Error en el análisis gramatical: $e");
      throw Exception("No se pudieron obtener las sugerencias. La IA pudo haber retornado un formato inesperado.");
    }
  }
}