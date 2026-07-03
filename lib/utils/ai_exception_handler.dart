class AIExceptionHandler {
  static const String noInternet =
      "🌐 No internet connection.\n\nPlease check your connection and try again.";

  static String getErrorMessage(dynamic error) {
    final errorText = error.toString().toLowerCase();

    // Network
    if (errorText.contains("socketexception") ||
        errorText.contains("failed host lookup")) {
      return noInternet;
    }

    // Quota
    if (errorText.contains("resource_exhausted") ||
        errorText.contains("429") ||
        errorText.contains("quota exceeded")) {
      return "⚠️ Daily AI quota reached.\n\nPlease try again later.";
    }

    // Invalid API Key
    if (errorText.contains("api key") ||
        errorText.contains("invalid")) {
      return "🔑 AI configuration error.\n\nPlease contact the developer.";
    }

    // Model not found
    if (errorText.contains("not found")) {
      return "🤖 AI model is currently unavailable.\n\nPlease try again later.";
    }

    // Timeout
    if (errorText.contains("timeout")) {
      return "⏳ Request timed out.\n\nPlease try again.";
    }

    // Unknown error
    return "⚠️ Something went wrong.\n\nPlease try again later.";
  }
}