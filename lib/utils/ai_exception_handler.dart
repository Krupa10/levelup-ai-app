class AIExceptionHandler {
  static const String noInternet =
      "🌐 No internet connection.\n\nPlease check your connection and try again.";

  static String getErrorMessage(dynamic error) {
    final errorText = error.toString().toLowerCase();

    if (errorText.contains("socketexception") ||
        errorText.contains("failed host lookup")) {
      return "🌐 No internet connection.\n\nPlease check your connection and try again.";
    }

    if (errorText.contains("resource_exhausted") ||
        errorText.contains("429") ||
        errorText.contains("quota exceeded")) {
      return "Quota Exceeded";
    }

    if (errorText.contains("api key") ||
        errorText.contains("invalid")) {
      return "🔑 AI configuration error.\n\nPlease contact the developer.";
    }

    if (errorText.contains("timeout")) {
      return "⏳ The request took too long.\n\nPlease try again.";
    }

    if (errorText.contains("not found")) {
      return "❌ AI model not found.\n\nPlease check the configured model name.";
    }

    return "Unexpected AI error:\n$error";
  }
}