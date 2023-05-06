
import 'package:desktop_assistant/model/message_data.dart';
import 'package:equatable/equatable.dart';

import '../model/gpt_mode.dart';

class HomeState extends Equatable {

  final GptMode gptMode;
  final List<MessageData> messages;
  final String error;
  final bool isLoading;

  const HomeState({
    this.gptMode = GptMode.raw,
    this.messages = const [],
    this.error = "",
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [gptMode, messages, error, isLoading];

  HomeState copyWith({
    GptMode? gptMode,
    List<MessageData>? messages,
    String? error,
    bool? isLoading,
  }) =>
      HomeState(
        gptMode: gptMode ?? this.gptMode,
        messages: messages ?? this.messages,
        error: error ?? this.error,
        isLoading: isLoading ?? this.isLoading,
      );

}