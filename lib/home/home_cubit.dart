import 'package:desktop_assistant/model/message_data.dart';
import 'package:desktop_assistant/model/message_sender.dart';
import 'package:desktop_assistant/repo/gpt_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/gpt_mode.dart';
import '../utils/logger.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GPTRepository _gptRepository = GPTRepository();

  HomeCubit() : super(const HomeState());

  Future<void> sendMessage(String message) async {
    emit(state.copyWith(
        messages: [...state.messages, MessageData(text: message, sender: MessageSender.user, mode: state.gptMode)],
        isLoading: true,
        error: ""));
    try {
      final response = await askChat(message, state.gptMode);
      emit(state.copyWith(
          messages: [...state.messages, MessageData(text: response, sender: MessageSender.chatbot, mode: state.gptMode)],
          isLoading: false,
          error: ""));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<String> askChat(String message, GptMode mode) async {
    final response = await _gptRepository.askChat(message, mode);
    return response;
  }

  void changeGptMode(GptMode mode) {
    logger.d("changeGptMode $mode");
    emit(state.copyWith(gptMode: mode));
  }

  void clearMessages() {
    emit(state.copyWith(messages: []));
  }
}
