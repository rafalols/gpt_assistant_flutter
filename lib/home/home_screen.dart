import 'package:desktop_assistant/home/home_state.dart';
import 'package:desktop_assistant/model/gpt_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/message_sender.dart';
import 'home_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildButtons(context, state),
                _buildChatWindow(context, state),
                const _MessageBox(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildButtons(BuildContext context, HomeState state) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildButton(context, state, GptMode.raw),
            _buildButton(context, state, GptMode.translate),
            _buildButton(context, state, GptMode.fixMistakes),
            _buildButton(context, state, GptMode.summary),
            _buildButton(context, state, GptMode.summaryWithTranslate),
          ],
        ),
      );

  Widget _buildButton(BuildContext context, HomeState state, GptMode mode) {
    String title;
    switch (mode) {
      case GptMode.raw:
        title = "Raw";
        break;
      case GptMode.translate:
        title = "Translate";
        break;
      case GptMode.fixMistakes:
        title = "Fix Mistakes";
        break;
      case GptMode.summary:
        title = "Summary";
        break;
      case GptMode.summaryWithTranslate:
        title = "Summary with Translate";
        break;
    }

    return GestureDetector(
      onTap: () => context.read<HomeCubit>().changeGptMode(mode),
      child: Card(
        color: state.gptMode == mode
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.tertiaryContainer,
        child: Padding(padding: EdgeInsets.all(16), child: Text(title)),
      ),
    );
  }

  Widget _buildChatWindow(BuildContext context, HomeState state) => Expanded(
        child: Card(
          color: Theme.of(context).colorScheme.surface,
          child: ListView.builder(
            itemCount: state.messages.length,
            itemBuilder: (context, index) {
              final message = state.messages[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: message.sender == MessageSender.user ? Alignment.centerRight : Alignment.centerLeft,
                  child: Card(
                    color: message.sender == MessageSender.user
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.tertiaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: SelectableText(message.text),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
}

class _MessageBox extends StatefulWidget {
  const _MessageBox({Key? key}) : super(key: key);

  @override
  _MessageBoxState createState() => _MessageBoxState();
}

class _MessageBoxState extends State<_MessageBox> {
  TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: TextField(
          controller: _textEditingController,
          decoration: InputDecoration(hintText: 'Enter text here'),
        )),
        ElevatedButton(
          onPressed: () {
            context.read<HomeCubit>().sendMessage(_textEditingController.text);
            _textEditingController.clear();
          },
          child: Text("Send"),
        )
      ],
    );
  }
}
