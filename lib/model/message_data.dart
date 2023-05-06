

import 'package:desktop_assistant/model/gpt_mode.dart';
import 'package:desktop_assistant/model/message_sender.dart';
import 'package:equatable/equatable.dart';

class MessageData extends Equatable {

  final String text;
  final MessageSender sender;
  final GptMode mode;

  const MessageData({
    required this.text,
    required this.sender,
    required this.mode,
  });

  @override
  List<Object?> get props => [text, sender, mode];

}