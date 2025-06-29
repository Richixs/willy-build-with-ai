import 'dart:io';
import 'dart:typed_data';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final Gemini gemini = Gemini.instance;

  List<ChatMessage> messages = [];

  ChatUser currentUser = ChatUser(id: '0', firstName: 'User');
  ChatUser geminiUser = ChatUser(
    id: '1',
    firstName: 'Willy',
    profileImage: 'https://i.imgur.com/SJ53unc.jpeg',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Willy Chat',
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
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
        messageOptions: MessageOptions(
          currentUserContainerColor: Color(0xFF7DD3FC),
          containerColor: Color(0xFFFFFFFF),
        ),
        inputOptions: InputOptions(
          inputDecoration: InputDecoration(
            filled: true,
            fillColor: Color(0xFFFFFFFF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            hintText: 'Enviar mensaje a Willy',
          ),
          inputToolbarPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          trailing: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 0.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF472B6),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _sendMediaMessage,
                  icon: Icon(Icons.image, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        currentUser: currentUser,
        onSend: onSend,
        messages: messages,
      ),
    );
  }

  void onSend(ChatMessage message) {
    setState(() {
      messages = [message, ...messages];
    });
    try {
      String question = message.text;
      implementGeminiChat(question);
    } catch (e) {
      print(e);
    }
  }

  void implementGeminiChat(String question) {
    gemini.promptStream(parts: [Part.text(question)]).listen((value) {
      if (value!.output != null && value.output!.isNotEmpty) {
        ChatMessage? lastMessage = messages.firstOrNull;
        if (lastMessage != null && lastMessage.user == geminiUser) {
          lastMessage = messages.removeAt(0);
          lastMessage.text += value.output!;
          setState(() => messages = [lastMessage!, ...messages]);
        } else {
          ChatMessage message = ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: value.output!,
          );
          setState(() => messages = [message, ...messages]);
        }
      }
    });
  }

  void _sendMediaMessage() async {
    ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      ChatMessage message = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        text: "Describe this image",
        medias: [
          ChatMedia(url: image.path, type: MediaType.image, fileName: ""),
        ],
      );

      onSendMedia(message);
    }
  }

  void onSendMedia(ChatMessage message) {
    setState(() {
      messages = [message, ...messages];
    });
    try {
      String question = message.text;
      Uint8List? images;
      if (message.medias?.isNotEmpty ?? false) {
        images = File(message.medias!.first.url).readAsBytesSync();

        gemini.promptStream(parts: [Part.text(question), Part.uint8List(images)]).listen((value) {
          if (value!.output != null && value.output!.isNotEmpty) {
            ChatMessage? lastMessage = messages.firstOrNull;
            if (lastMessage != null && lastMessage.user == geminiUser) {
              lastMessage = messages.removeAt(0);
              lastMessage.text += value.output!;
              setState(() => messages = [lastMessage!, ...messages]);
            } else {
              ChatMessage message = ChatMessage(
                user: geminiUser,
                createdAt: DateTime.now(),
                text: value.output!,
              );
              setState(() => messages = [message, ...messages]);
            }
          }
        });
      }
    } catch (e) {
      print(e);
    }
  }
}
