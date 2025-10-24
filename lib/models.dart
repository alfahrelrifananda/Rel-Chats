import 'package:flutter/material.dart';

// AI Model Enum
enum AIModel {
  chatgpt,
  claude,
  gemini;

  String get displayName {
    switch (this) {
      case AIModel.chatgpt:
        return 'ChatGPT';
      case AIModel.claude:
        return 'Claude';
      case AIModel.gemini:
        return 'Gemini';
    }
  }

  String get description {
    switch (this) {
      case AIModel.chatgpt:
        return 'OpenAI\'s conversational AI';
      case AIModel.claude:
        return 'Anthropic\'s helpful assistant';
      case AIModel.gemini:
        return 'Google\'s multimodal AI';
    }
  }

  String get tagline {
    switch (this) {
      case AIModel.chatgpt:
        return 'Versatile & creative';
      case AIModel.claude:
        return 'Thoughtful & detailed';
      case AIModel.gemini:
        return 'Fast & intelligent';
    }
  }

  IconData get icon {
    switch (this) {
      case AIModel.chatgpt:
        return Icons.psychology_rounded;
      case AIModel.claude:
        return Icons.smart_toy_rounded;
      case AIModel.gemini:
        return Icons.auto_awesome_rounded;
    }
  }

  Color get color {
    switch (this) {
      case AIModel.chatgpt:
        return const Color(0xFF10A37F);
      case AIModel.claude:
        return const Color(0xFFCC785C);
      case AIModel.gemini:
        return const Color(0xFF4285F4);
    }
  }
}

// Chat Session Model
class ChatSession {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime timestamp;
  final AIModel model;

  ChatSession({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.timestamp,
    required this.model,
  });
}