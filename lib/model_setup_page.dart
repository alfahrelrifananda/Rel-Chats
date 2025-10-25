import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class ModelSetupPage extends StatefulWidget {
  const ModelSetupPage({super.key, required this.model});

  final AIModel model;

  @override
  State<ModelSetupPage> createState() => _ModelSetupPageState();
}

class _ModelSetupPageState extends State<ModelSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  bool _obscureApiKey = true;
  bool _isTesting = false;
  bool _isConfigured = false;
  String? _testResult;
  bool? _testSuccess;

  @override
  void initState() {
    super.initState();
    _loadSavedApiKey();
  }

  Future<void> _loadSavedApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final savedKey = prefs.getString('${widget.model.name}_api_key');
    if (savedKey != null && savedKey.isNotEmpty) {
      setState(() {
        _apiKeyController.text = savedKey;
        _isConfigured = true;
      });
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isTesting = true;
      _testResult = null;
      _testSuccess = null;
    });

    try {
      bool success = false;
      String message = '';

      switch (widget.model) {
        case AIModel.chatgpt:
          success = await _testOpenAI();
          message = success
              ? 'Connection successful! OpenAI API key is valid.'
              : 'Connection failed. Invalid API key or no access.';
          break;
        case AIModel.claude:
          success = await _testClaude();
          message = success
              ? 'Connection successful! Claude API key is valid.'
              : 'Connection failed. Invalid API key or no access.';
          break;
        case AIModel.gemini:
          success = await _testGemini();
          message = success
              ? 'Connection successful! Gemini API key is valid.'
              : 'Connection failed. Invalid API key or no access.';
          break;
      }

      setState(() {
        _isTesting = false;
        _testSuccess = success;
        _testResult = message;
      });
    } catch (e) {
      setState(() {
        _isTesting = false;
        _testSuccess = false;
        _testResult = 'Connection error: ${e.toString()}';
      });
    }
  }

  Future<bool> _testOpenAI() async {
    try {
      final response = await http
          .get(
            Uri.parse('https://api.openai.com/v1/models'),
            headers: {'Authorization': 'Bearer ${_apiKeyController.text}'},
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _testClaude() async {
    try {
      final response = await http
          .post(
            Uri.parse('https://api.anthropic.com/v1/messages'),
            headers: {
              'x-api-key': _apiKeyController.text,
              'anthropic-version': '2023-06-01',
              'content-type': 'application/json',
            },
            body: jsonEncode({
              'model': 'claude-3-haiku-20240307',
              'max_tokens': 10,
              'messages': [
                {'role': 'user', 'content': 'Hi'},
              ],
            }),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _testGemini() async {
    try {
      final response = await http
          .post(
            Uri.parse(
              'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${_apiKeyController.text}',
            ),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': 'Hi'},
                  ],
                },
              ],
            }),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveConfiguration() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${widget.model.name}_api_key',
      _apiKeyController.text,
    );

    setState(() {
      _isConfigured = true;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.model.displayName} configured successfully',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _removeConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${widget.model.name}_api_key');

    setState(() {
      _apiKeyController.clear();
      _isConfigured = false;
      _testResult = null;
      _testSuccess = null;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.model.displayName} configuration removed'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.model.displayName} Setup',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          if (_isConfigured)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Remove Configuration'),
                    content: Text(
                      'Are you sure you want to remove ${widget.model.displayName} configuration?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _removeConfiguration();
                        },
                        child: const Text('Remove'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Status Badge
            if (_isConfigured)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${widget.model.displayName} is configured and ready to use',
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // API Key Section
            Text(
              'API Key',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your ${widget.model.displayName} API key to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // API Key Input
            TextFormField(
              controller: _apiKeyController,
              obscureText: _obscureApiKey,
              decoration: InputDecoration(
                labelText: 'API Key',
                hintText: 'sk-...',
                prefixIcon: Icon(Icons.key_rounded, color: widget.model.color),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureApiKey
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureApiKey = !_obscureApiKey;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: widget.model.color, width: 2),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerLow,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an API key';
                }
                if (value.length < 10) {
                  return 'API key seems too short';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Get API Key Link
            InkWell(
              onTap: () {
                String url = '';
                switch (widget.model) {
                  case AIModel.chatgpt:
                    url = 'https://platform.openai.com/api-keys';
                    break;
                  case AIModel.claude:
                    url = 'https://console.anthropic.com/';
                    break;
                  case AIModel.gemini:
                    url = 'https://makersuite.google.com/app/apikey';
                    break;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Visit: $url'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.open_in_new_rounded,
                      size: 16,
                      color: widget.model.color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Get your API key from ${widget.model.displayName}',
                      style: TextStyle(
                        color: widget.model.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Test Connection Button
            FilledButton.icon(
              onPressed: _isTesting ? null : _testConnection,
              icon: _isTesting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.wifi_rounded),
              label: Text(
                _isTesting ? 'Testing...' : 'Test Connection',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: widget.model.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            // Test Result
            if (_testResult != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _testSuccess!
                      ? colorScheme.primaryContainer
                      : colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _testSuccess!
                        ? colorScheme.primary.withOpacity(0.3)
                        : colorScheme.error.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _testSuccess!
                          ? Icons.check_circle_rounded
                          : Icons.error_rounded,
                      color: _testSuccess!
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _testResult!,
                        style: TextStyle(
                          color: _testSuccess!
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onErrorContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Save Button
            OutlinedButton.icon(
              onPressed: _saveConfiguration,
              icon: const Icon(Icons.save_rounded),
              label: const Text(
                'Save Configuration',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: widget.model.color,
                side: BorderSide(color: widget.model.color, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Additional Info
            Card(
              elevation: 0,
              color: colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: colorScheme.outlineVariant.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Important Information',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• Your API key is stored locally on your device\n'
                      '• Never share your API key with others\n'
                      '• You can change or remove it anytime\n'
                      '• API usage may incur costs from the provider\n'
                      '• Test connection verifies your key validity',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
