import 'dart:typed_data';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// PASO 1: Importa tu servicio
import 'package:willy/services/gemini_service.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  // final Gemini gemini = Gemini.instance;

  List<ChatMessage> messages = [];
  final ChatUser currentUser = ChatUser(id: '0', firstName: 'User');
  final ChatUser geminiUser = ChatUser(
    id: '1',
    firstName: 'Willy',
    profileImage: 'https://i.imgur.com/SJ53unc.jpeg',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Análisis Gramatical con Willy', style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF7DD3FC),
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Container(
      color: const Color(0xFFF0F4F8),
      child: DashChat(
        messageOptions: const MessageOptions(
          currentUserContainerColor: Color(0xFF7DD3FC),
          containerColor: Color(0xFFFFFFFF),
        ),
        inputOptions: InputOptions(
          inputDecoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFFFFFFF),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            hintText: 'Escribe el texto a analizar...',
          ),
          inputToolbarPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          trailing: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 0.0),
              child: Container(
                decoration: const BoxDecoration(color: Color(0xFFF472B6), shape: BoxShape.circle),
                child: IconButton(onPressed: _sendMediaMessage, icon: const Icon(Icons.image, color: Colors.white)),
              ),
            ),
          ],
        ),
        currentUser: currentUser,
        onSend: _onSend,
        messages: messages,
      ),
    );
  }

  void _onSend(ChatMessage message) async {
    setState(() {
      messages = [message, ...messages];
    });

    final typingMessage = ChatMessage(user: geminiUser, createdAt: DateTime.now(), text: "Analizando...");
    setState(() {
      messages = [typingMessage, ...messages];
    });

    try {
      final analysis = await GeminiService.analyzeTextForTips(text: message.text);

      final responseMessage = ChatMessage(
        user: geminiUser,
        createdAt: DateTime.now(),
        text: analysis.tips,
      );

      setState(() {
        messages.removeAt(0); // Quita "Analizando..."
        messages = [responseMessage, ...messages];
      });
    } catch (e) {
      final errorMessage = ChatMessage(
        user: geminiUser,
        createdAt: DateTime.now(),
        text: "Lo siento, ocurrió un error al analizar el texto. Por favor, inténtalo de nuevo. Error: ${e.toString()}",
      );
      setState(() {
        messages.removeAt(0);
        messages = [errorMessage, ...messages];
      });
    }
  }

  void _sendMediaMessage() async {
    ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final Uint8List imageBytes = await image.readAsBytes();

      final message = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        text: "",
        medias: [ChatMedia(url: image.path, type: MediaType.image, fileName: "")],
      );

      setState(() {
        messages = [message, ...messages];
      });

      final typingMessage = ChatMessage(user: geminiUser, createdAt: DateTime.now(), text: "Analizando imagen...");
      setState(() {
        messages = [typingMessage, ...messages];
      });

      try {
        final analysis = await GeminiService.analyzeTextForTips(
          text: message.text,
          imageBytes: imageBytes,
        );

        final responseMessage = ChatMessage(user: geminiUser, createdAt: DateTime.now(), text: analysis.tips);

        setState(() {
          messages.removeAt(0);
          messages = [responseMessage, ...messages];
        });

      } catch (e) {
        final errorMessage = ChatMessage(user: geminiUser, createdAt: DateTime.now(), text: "Error al analizar la imagen: ${e.toString()}");
        setState(() {
          messages.removeAt(0);
          messages = [errorMessage, ...messages];
        });
      }
    }
  }
}