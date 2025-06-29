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
    firstName: 'Gemini',
    profileImage: 'https://www.gemini.com/static/images/gemini-logo.png',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Willy Chat')),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Container(
      color: const Color(0xFFF0F4F8),
      child: DashChat(
        inputOptions: InputOptions(
          trailing: [
            IconButton(onPressed: _sendMediaMessage, icon: Icon(Icons.image)),
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
