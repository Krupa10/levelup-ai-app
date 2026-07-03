enum MessageRole {
  user,
  ai,
}

class ChatMessage {
  final MessageRole role;
  final String text;

  const ChatMessage({
    required this.role,
    required this.text,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json["role"] == "user"
          ? MessageRole.user
          : MessageRole.ai,
      text: json["text"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "role": role == MessageRole.user ? "user" : "ai",
      "text": text,
    };
  }
}