import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

class GemmaTestScreen extends StatefulWidget {
  const GemmaTestScreen({super.key});

  @override
  State<GemmaTestScreen> createState() => _GemmaTestScreenState();
}

class _GemmaTestScreenState extends State<GemmaTestScreen> {
  String _statusMessage = 'Model not loaded.';
  String _generatedTask = '';
  List<Map<String, dynamic>> _exercises = [];
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, bool?> _results = {};
  bool _isLoading = false;
  double _downloadProgress = 0.0;
  bool _isModelInstalled = false;

  InferenceChat? _chat;

  @override
  void initState() {
    super.initState();
    // In a real app we'd check if a model is already active. For this test screen,
    // we'll instruct the user to download it from the HF network.
  }

  Future<void> _installModel() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Installing model...';
      _downloadProgress = 0.0;
    });

    try {
      // For general Gemma inference, Gemma3n or other small CPU/GPU variants are recommended.
      // This URL uses a small 270M community-provided model that typically doesn't require a gated token.
      await FlutterGemma.installModel(
            modelType: ModelType.gemmaIt,
            fileType: ModelFileType.litertlm,
          )
          .fromNetwork(
            'https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm',
          )
          .withProgress((progress) {
            if (mounted) {
              setState(() {
                _downloadProgress = progress / 100;
              });
            }
          })
          .install();

      final model = await FlutterGemma.getActiveModel(maxTokens: 1024);

      _chat = await model.createChat(
        systemInstruction:
            'You are an English language tutor. Generate exercises specifically testing the Present Simple tense. All your responses must be strictly in valid JSON format without any markdown code blocks or extra text.',
      );

      setState(() {
        _isModelInstalled = true;
        _statusMessage = 'Model ready.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error installing model: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _generateTask() async {
    if (_chat == null) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Generating task...';
      _generatedTask = '';
    });

    try {
      await _chat!.addQueryChunk(
        Message.text(
          text:
              'Generate 3 fill-in-the-blank style exercises for the Present Simple tense. Use the format with the base verb in parentheses, for example: "I __(to be) 18 years old.". Output strictly as a JSON array of objects with keys: "sentence" (containing the blank and base verb) and "answer". Example: [{"sentence": "She __(to drink) milk everyday.", "answer": "drinks"}]',
          isUser: true,
        ),
      );

      final response = await _chat!.generateChatResponse();

      setState(() {
        String rawText = '';
        if (response is TextResponse) {
          rawText = response.token;
        } else {
          rawText = response.toString();
        }

        _generatedTask = rawText;
        _exercises.clear();
        _controllers.clear();
        _results.clear();

        try {
          final jsonStart = rawText.indexOf('[');
          final jsonEnd = rawText.lastIndexOf(']');
          if (jsonStart != -1 && jsonEnd != -1) {
            final jsonString = rawText.substring(jsonStart, jsonEnd + 1);
            final List<dynamic> parsed = jsonDecode(jsonString);
            _exercises = List<Map<String, dynamic>>.from(parsed);

            for (var i = 0; i < _exercises.length; i++) {
              _controllers[i] = TextEditingController();
            }
          }
        } catch (e) {
          debugPrint('Could not parse JSON: $e');
        }

        _statusMessage = 'Task generated.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error generating task: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _deleteModel() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Deleting models...';
    });

    try {
      final models = await FlutterGemma.listInstalledModels();
      for (final modelId in models) {
        await FlutterGemma.uninstallModel(modelId);
      }

      setState(() {
        _isModelInstalled = false;
        _chat = null;
        _statusMessage = 'Model deleted successfully.';
        _downloadProgress = 0.0;
        _generatedTask = '';
        _exercises.clear();
        _controllers.clear();
        _results.clear();
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error deleting model: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Gemma Tests')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Status: $_statusMessage',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (_isLoading && !_isModelInstalled && _downloadProgress > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: LinearProgressIndicator(value: _downloadProgress),
              ),
            const SizedBox(height: 16),
            if (!_isModelInstalled)
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _installModel,
                icon:
                    _isLoading
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.download),
                label: const Text('Install Model'),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _generateTask,
                    icon:
                        _isLoading
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.school),
                    label: const Text('Generate JSON Task'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _deleteModel,
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text(
                      'Delete Model',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child:
                    _exercises.isNotEmpty && !_isLoading
                        ? ListView.separated(
                          itemCount: _exercises.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final ex = _exercises[index];
                            final sentence = ex['sentence']?.toString() ?? '';
                            final parts = sentence.split('__');
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        parts.isNotEmpty ? parts[0] : sentence,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      if (parts.length > 1) ...[
                                        Container(
                                          width: 120,
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          child: TextField(
                                            controller: _controllers[index],
                                            decoration: InputDecoration(
                                              isDense: true,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                    horizontal: 8,
                                                  ),
                                              border:
                                                  const OutlineInputBorder(),
                                              fillColor:
                                                  _results[index] == true
                                                      ? Colors.green.withValues(
                                                        alpha: 0.1,
                                                      )
                                                      : _results[index] == false
                                                      ? Colors.red.withValues(
                                                        alpha: 0.1,
                                                      )
                                                      : null,
                                              filled: _results[index] != null,
                                            ),
                                            onChanged: (_) {
                                              if (_results[index] != null) {
                                                setState(() {
                                                  _results[index] = null;
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                        Text(
                                          parts.sublist(1).join('__'),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (_results[index] == false)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        'Correct answer: ${ex['answer']}',
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        )
                        : SingleChildScrollView(
                          child: Text(
                            _generatedTask.isEmpty && !_isLoading
                                ? 'Your JSON task will appear here...'
                                : _generatedTask,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
              ),
            ),
            if (_exercises.isNotEmpty && !_isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      for (int i = 0; i < _exercises.length; i++) {
                        final answer =
                            _exercises[i]['answer']
                                ?.toString()
                                .trim()
                                .toLowerCase() ??
                            '';
                        final userAnswer =
                            _controllers[i]?.text.trim().toLowerCase() ?? '';
                        _results[i] = answer == userAnswer;
                      }
                    });
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Check Answers'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
