import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final GenerativeModel _model;

  GeminiService(String apiKey)
      : _model = GenerativeModel(
          // ✅ Use the full model name with "models/" prefix
          model: 'gemini-2.5-flash',
          apiKey: apiKey,
        );

  Future<String?> sendMessage(String userMessage) async {
    final chat = _model.startChat();
    final content = Content.text(userMessage);

    try {
      final response = await chat.sendMessage(content);
      return response.text;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}
