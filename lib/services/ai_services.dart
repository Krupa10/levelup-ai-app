import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../utils/prompt_builder.dart';
import '../utils/ai_exception_handler.dart';
import '../models/chat_message.dart';

class AIService {
  static final model = GenerativeModel(
    model: "gemini-2.5-flash",
    apiKey: dotenv.env["GEMINI_API_KEY"]!,
  );

  //prompt → the user's original message.
  //fullPrompt → the enriched prompt sent to Gemini.

  static Future<String> getResponse(
    String userMessage,
    List<ChatMessage> chatHistory,
  ) async {
    try {
      final fullPrompt = await PromptBuilder.buildPrompt(
        userMessage: userMessage,
        chatHistory: chatHistory,
      );
      print("API KEY: ${dotenv.env["GEMINI_API_KEY"]}");
      final content = [Content.text(fullPrompt)];

      final response = await model.generateContent(content);

      return response.text ?? "Sorry, I couldn't generate a response.";
    } catch (e, stackTrace) {
      debugPrint("========== AI ERROR ==========");
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());

      return e.toString();
    }
  }
}
