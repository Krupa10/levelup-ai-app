import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../utils/prompt_builder.dart';
import '../utils/ai_exception_handler.dart';

class AIService {
  static final model = GenerativeModel(
    model: "gemini-2.0-flash",
    apiKey: dotenv.env["GEMINI_API_KEY"]!,
  );

//prompt → the user's original message.
//fullPrompt → the enriched prompt sent to Gemini.

  static Future<String> getResponse(String userMessage) async {
    try {
      final fullPrompt = await PromptBuilder.buildPrompt(
        userMessage: userMessage,
      );

      final content = [Content.text(fullPrompt)];

      final response = await model.generateContent(content);

      return response.text ?? "Sorry, I couldn't generate a response.";
    } catch (e) {
      return AIExceptionHandler.getErrorMessage(e);
    }
  }
}