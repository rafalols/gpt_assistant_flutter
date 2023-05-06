import 'dart:convert';
import 'package:desktop_assistant/model/gpt_mode.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../utils/logger.dart';

class GPTRepository {
  final String apiKey = dotenv.env['OPENAI_API_KEY']!;
  final String apiUrl = 'https://api.openai.com/v1/chat/completions';
  final String model = "gpt-3.5-turbo";

  GPTRepository();

  Future<String> askChat(String prompt, GptMode mode) async {
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    final systemPrompt = systemForMode(mode);
    final userPrompt = {"role": "user", "content": prompt};
    final messages = systemPrompt != null ? [systemPrompt, userPrompt] : [userPrompt];

    final body = jsonEncode({
      'messages': messages,
      'model': model,
      'max_tokens': 1000, // TODO: from settings
      'temperature': 0.7, // TODO: from settings
    });

    logger.d("ChatGPT request: $body");

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: body,
    );

    String decodedResponse = utf8.decode(response.bodyBytes);

    logger.d("ChatGPT response: ${response.statusCode} : $decodedResponse");

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(decodedResponse);
      return jsonResponse['choices'][0]['message']['content'].trim();
    } else {
      throw Exception('Failed to communicate with ChatGPT. Error: ${response.body}');
    }
  }

  Map<String, String>? systemForMode(GptMode mode) {
    String? prompt;
    switch (mode) {
      case GptMode.raw:
        break;
      case GptMode.translate:
        prompt =  "You are a translator. If the text is in Polish, translate it into English. If it is in another language, translate it into Polish.";
        break;
      case GptMode.fixMistakes:
        prompt = "You are a proofreader. Please proofread and correct any spelling or grammatical errors in the following text. Return only the fixed text, and nothing more. If text has no errors please return the same text. Ensure that the corrections are made in the same language as the original text provided by the user.";
        break;
      case GptMode.summary:
        prompt = "Make a summary of the following text. Return only the summary, and nothing more. Ensure that the summary is made in the same language as the original text provided by the user.";
        break;
      case GptMode.summaryWithTranslate:
        prompt = "Make a summary of the following text. Return only the summary, and nothing more. Always return summary in polish language.";
        break;
    }

    return prompt != null ? {"role": "system", "content": prompt} : null;
  }

}
