import 'package:desktop_assistant/home/home_state.dart';
import 'package:desktop_assistant/model/gpt_mode.dart';
import 'package:desktop_assistant/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';

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
          registerKeys(context);

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

  Widget _buildButtons(BuildContext context, HomeState state) =>
      SingleChildScrollView(
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
            ? Theme
            .of(context)
            .colorScheme
            .primaryContainer
            : Theme
            .of(context)
            .colorScheme
            .tertiaryContainer,
        child: Padding(padding: const EdgeInsets.all(16), child: Text(title)),
      ),
    );
  }

  Widget _buildChatWindow(BuildContext context, HomeState state) =>
      Expanded(
        child: Card(
          color: Theme
              .of(context)
              .colorScheme
              .surface,
          child: ListView.builder(
            itemCount: state.messages.length,
            itemBuilder: (context, index) {
              final message = state.messages[index];
              final padding = message.sender == MessageSender.user
                  ? const EdgeInsets.fromLTRB(64, 8, 8, 2)
                  : const EdgeInsets.fromLTRB(8, 2, 64, 64);
              return Column(
                children: [
                  if (message.sender == MessageSender.user) Divider(),
                  if (message.sender == MessageSender.user) Text(message.mode.name),
                  Padding(
                    padding: padding,
                    child: Align(
                      alignment: message.sender == MessageSender.user ? Alignment.centerRight : Alignment.centerLeft,
                      child: Card(
                        color: message.sender == MessageSender.user
                            ? Theme
                            .of(context)
                            .colorScheme
                            .primaryContainer
                            : Theme
                            .of(context)
                            .colorScheme
                            .tertiaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: SelectableText(message.text),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );

  void registerKeys(BuildContext context) async {
    HotKey hotKey = HotKey(
      KeyCode.keyT,
      modifiers: [KeyModifier.control, KeyModifier.shift],
      scope: HotKeyScope.system,
    );

    await hotKeyManager.register(
      hotKey,
      keyDownHandler: (hotKey) async {
        logger.d("Hotkey pressed");
        final text = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
        if (text == null || text.isEmpty) {
          await FlutterPlatformAlert.playAlertSound(iconStyle: IconStyle.error);
          logger.d("Clipboard empty");
          return;
        }
        try {
          if (!context.mounted) return;
          final response = await context.read<HomeCubit>().askChat(text, GptMode.translate);
          logger.d("Response: $response");
          if (response.isNotEmpty) {
            await FlutterPlatformAlert.playAlertSound(iconStyle: IconStyle.information);
            final clickedButton = await FlutterPlatformAlert.showCustomAlert(
                windowTitle: 'Translated text:',
                text: response,
                positiveButtonTitle: "Copy",
                negativeButtonTitle: "Close",
            );
            if (clickedButton == CustomButton.positiveButton) {
              Clipboard.setData(ClipboardData(text: response));
            }
          } else {
            await FlutterPlatformAlert.playAlertSound(iconStyle: IconStyle.error);
          }
        } catch (e) {
          await FlutterPlatformAlert.playAlertSound(iconStyle: IconStyle.error);
          logger.e(e);
        }
      },
    );
  }
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
              decoration: const InputDecoration(hintText: 'Enter text here'),
              onEditingComplete: () {
                context.read<HomeCubit>().sendMessage(_textEditingController.text);
                _textEditingController.clear();
              },
            )),
        ElevatedButton(
          onPressed: () {
            context.read<HomeCubit>().sendMessage(_textEditingController.text);
            _textEditingController.clear();
          },
          child: const Text("Send"),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<HomeCubit>().clearMessages();
          },
          child: Text("Clear", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error)),
        ),
      ],
    );
  }
}
