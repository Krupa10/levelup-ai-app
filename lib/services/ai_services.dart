import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String apiKey = "";

  static Future<String> getResponse(String message) async {
    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/responses"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode({
        "model": "gpt-4.1-mini",
        "input": message,
      }),
    );

    final data = jsonDecode(response.body);
/*    print("API called with: $message");
    print(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["output"][0]["content"][0]["text"];
    } else {
      print(response.body);
      return "Error: Unable to get response";
    }*/
    return data["output"][0]["content"][0]["text"];
  }
}