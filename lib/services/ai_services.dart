import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static final model = GenerativeModel(
    model: "gemini-2.0-flash",
    apiKey: dotenv.env["GEMINI_API_KEY"]!,
  );

  static Future<String> getResponse(String prompt) async {
    try {
      final content = [Content.text(prompt)];

      final response = await model.generateContent(content);

      return response.text ?? "Sorry, I couldn't generate a response.";
    } catch (e) {
      return "Something went wrong.\n\n$e";
    }
  }
}