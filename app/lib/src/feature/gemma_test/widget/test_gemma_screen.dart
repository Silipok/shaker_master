import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

class GemmaTestScreen extends StatefulWidget {
  const GemmaTestScreen({super.key});

  @override
  State<GemmaTestScreen> createState() => _GemmaTestScreenState();
}

class _GemmaTestScreenState extends State<GemmaTestScreen> {
  static const _modelUrl =
      'https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm';

  String _statusMessage = 'Model not loaded.';
  bool _isModelInstalled = false;
  bool _isInstalling = false;
  bool _isGenerating = false;
  double _downloadProgress = 0.0;

  InferenceChat? _chat;

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _restoreExistingModel();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _restoreExistingModel() async {
    try {
      final installed = await FlutterGemma.listInstalledModels();
      if (installed.isEmpty || !mounted) return;
      final model = await FlutterGemma.getActiveModel(maxTokens: 1024);
      final chat = await model.createChat(
        systemInstruction:
            'You are a helpful assistant. Answer concisely and in the '
            "language of the user's question.",
      );
      if (!mounted) return;
      setState(() {
        _chat = chat;
        _isModelInstalled = true;
        _statusMessage = 'Model ready.';
      });
    } catch (_) {
      // No active model yet — stay on the install screen.
    }
  }

  Future<void> _installModel() async {
    setState(() {
      _isInstalling = true;
      _statusMessage = 'Installing model...';
      _downloadProgress = 0.0;
    });

    try {
      await FlutterGemma.installModel(
            modelType: ModelType.gemmaIt,
            fileType: ModelFileType.litertlm,
          )
          .fromNetwork(_modelUrl)
          .withProgress((progress) {
            if (!mounted) return;
            setState(() => _downloadProgress = progress / 100);
          })
          .install();

      final model = await FlutterGemma.getActiveModel(maxTokens: 1024);
      _chat = await model.createChat(
        systemInstruction:
            'You are a helpful assistant. Answer concisely and in the '
            "language of the user's question.",
      );

      if (!mounted) return;
      setState(() {
        _isModelInstalled = true;
        _statusMessage = 'Model ready.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _statusMessage = 'Error installing model: $e');
    } finally {
      if (mounted) setState(() => _isInstalling = false);
    }
  }

  Future<void> _deleteModel() async {
    setState(() {
      _isInstalling = true;
      _statusMessage = 'Deleting models...';
    });

    try {
      final models = await FlutterGemma.listInstalledModels();
      for (final modelId in models) {
        await FlutterGemma.uninstallModel(modelId);
      }
      if (!mounted) return;
      setState(() {
        _isModelInstalled = false;
        _chat = null;
        _statusMessage = 'Model deleted.';
        _downloadProgress = 0.0;
        _messages.clear();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _statusMessage = 'Error deleting model: $e');
    } finally {
      if (mounted) setState(() => _isInstalling = false);
    }
  }

  Future<void> _send() async {
    final chat = _chat;
    final text = _inputController.text.trim();
    if (chat == null || text.isEmpty || _isGenerating) return;

    _inputController.clear();
    setState(() {
      _messages.add(_ChatMessage(role: _Role.user, text: text));
      _messages.add(const _ChatMessage(role: _Role.assistant, text: ''));
      _isGenerating = true;
      _statusMessage = 'Generating...';
    });
    _scrollToBottom();

    try {
      await chat.addQueryChunk(Message.text(text: text, isUser: true));
      final response = await chat.generateChatResponse();
      final answer = response is TextResponse
          ? response.token
          : response.toString();

      if (!mounted) return;
      setState(() {
        _messages[_messages.length - 1] =
            _ChatMessage(role: _Role.assistant, text: answer);
        _statusMessage = 'Model ready.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages[_messages.length - 1] = _ChatMessage(
          role: _Role.assistant,
          text: 'Error: $e',
          isError: true,
        );
        _statusMessage = 'Error generating response.';
      });
    } finally {
      if (mounted) setState(() => _isGenerating = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemma chat'),
        actions: [
          if (_isModelInstalled)
            IconButton(
              tooltip: 'Delete model',
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _isInstalling || _isGenerating ? null : _deleteModel,
            ),
        ],
      ),
      body: Column(
        children: [
          _StatusBar(
            message: _statusMessage,
            progress: _isInstalling && !_isModelInstalled && _downloadProgress > 0
                ? _downloadProgress
                : null,
          ),
          Expanded(
            child: !_isModelInstalled
                ? _InstallPrompt(
                    isInstalling: _isInstalling,
                    onInstall: _installModel,
                  )
                : _ChatView(
                    controller: _scrollController,
                    messages: _messages,
                    isGenerating: _isGenerating,
                  ),
          ),
          if (_isModelInstalled)
            _ChatInput(
              controller: _inputController,
              enabled: !_isGenerating,
              onSend: _send,
            ),
        ],
      ),
    );
  }
}

enum _Role { user, assistant }

class _ChatMessage {
  const _ChatMessage({
    required this.role,
    required this.text,
    this.isError = false,
  });

  final _Role role;
  final String text;
  final bool isError;
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.message, this.progress});

  final String message;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            message,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          if (progress != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(value: progress),
            ),
        ],
      ),
    );
  }
}

class _InstallPrompt extends StatelessWidget {
  const _InstallPrompt({required this.isInstalling, required this.onInstall});

  final bool isInstalling;
  final VoidCallback onInstall;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Install the on-device Gemma model to start chatting.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: isInstalling ? null : onInstall,
              icon: isInstalling
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              label: const Text('Install model'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatView extends StatelessWidget {
  const _ChatView({
    required this.controller,
    required this.messages,
    required this.isGenerating,
  });

  final ScrollController controller;
  final List<_ChatMessage> messages;
  final bool isGenerating;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Type a question below to start the conversation.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.separated(
      controller: controller,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: messages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final m = messages[i];
        final isLast = i == messages.length - 1;
        final showPlaceholder = isGenerating &&
            isLast &&
            m.role == _Role.assistant &&
            m.text.isEmpty;
        return _MessageBubble(message: m, showPlaceholder: showPlaceholder);
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, this.showPlaceholder = false});

  final _ChatMessage message;
  final bool showPlaceholder;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == _Role.user;
    final theme = Theme.of(context);
    final bubbleColor = isUser
        ? theme.primaryColor.withValues(alpha: 0.12)
        : (message.isError
              ? Colors.red.withValues(alpha: 0.08)
              : theme.colorScheme.surfaceContainerHighest);
    final textColor = message.isError ? Colors.red.shade900 : null;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: showPlaceholder
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : SelectableText(
                  message.text,
                  style: TextStyle(fontSize: 15, color: textColor),
                ),
        ),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  const _ChatInput({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => enabled ? onSend() : null,
                decoration: InputDecoration(
                  hintText: 'Ask Gemma anything…',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: enabled ? onSend : null,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
