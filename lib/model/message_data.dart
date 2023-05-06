

import 'package:desktop_assistant/model/message_sender.dart';
import 'package:equatable/equatable.dart';

class MessageData extends Equatable {

  final String text;
  final MessageSender sender;

  const MessageData({
    required this.text,
    required this.sender,
  });

  @override
  List<Object?> get props => [text, sender];

}