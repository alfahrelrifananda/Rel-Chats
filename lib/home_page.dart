import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'model_setup_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;
  
  // Track configuration status for each model
  Map<AIModel, bool> _modelConfigStatus = {
    AIModel.chatgpt: false,
    AIModel.claude: false,
    AIModel.gemini: false,
  };

  final List<ChatSession> _recentChats = [
    ChatSession(
      id: '1',
      title: 'Flutter Development Help',
      lastMessage: 'How do I implement Material 3 design in my Flutter app?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      model: AIModel.chatgpt,
    ),
    ChatSession(
      id: '2',
      title: 'Code Review',
      lastMessage: 'Can you review this Dart code for performance improvements?',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      model: AIModel.claude,
    ),
    ChatSession(
      id: '3',
      title: 'API Integration',
      lastMessage: 'What are the best practices for implementing REST APIs?',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      model: AIModel.gemini,
    ),
    ChatSession(
      id: '4',
      title: 'State Management',
      lastMessage: 'Comparing Provider vs Riverpod for state management',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      model: AIModel.chatgpt,
    ),
    ChatSession(
      id: '5',
      title: 'Firebase Setup',
      lastMessage: 'Help me configure Firebase Authentication in Flutter',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      model: AIModel.gemini,
    ),
    ChatSession(
      id: '6',
      title: 'Widget Optimization',
      lastMessage: 'How to optimize widget rebuilds in complex layouts?',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      model: AIModel.claude,
    ),
    ChatSession(
      id: '7',
      title: 'Navigation Patterns',
      lastMessage: 'Best practices for deep linking and navigation',
      timestamp: DateTime.now().subtract(const Duration(days: 7)),
      model: AIModel.chatgpt,
    ),
    ChatSession(
      id: '8',
      title: 'Testing Strategies',
      lastMessage: 'Unit testing vs integration testing in Flutter',
      timestamp: DateTime.now().subtract(const Duration(days: 10)),
      model: AIModel.claude,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadConfigurationStatus();
  }

  Future<void> _loadConfigurationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _modelConfigStatus = {
        AIModel.chatgpt: prefs.getString('${AIModel.chatgpt.name}_api_key') != null,
        AIModel.claude: prefs.getString('${AIModel.claude.name}_api_key') != null,
        AIModel.gemini: prefs.getString('${AIModel.gemini.name}_api_key') != null,
      };
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _selectedIndex = index);
                },
                children: [
                  _buildChatsView(),
                  _buildModelsView(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                _showNewChatDialog(context);
              },
              child: const Icon(Icons.edit_rounded),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum_rounded),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.apps_outlined),
            selectedIcon: Icon(Icons.apps_rounded),
            label: 'Models',
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 20, 0, 0),
      child: Row(
        children: [
          Text(
            'Rel Chats',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildChatsView() {
    final colorScheme = Theme.of(context).colorScheme;

    if (_recentChats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 80,
              color: colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a new chat to get going',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _recentChats.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final chat = _recentChats[index];
        return _ChatCard(chat: chat);
      },
    );
  }

  Widget _buildModelsView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ModelCard(
          model: AIModel.chatgpt,
          isConfigured: _modelConfigStatus[AIModel.chatgpt] ?? false,
          onTap: () => _showModelConfig(AIModel.chatgpt),
        ),
        const SizedBox(height: 12),
        _ModelCard(
          model: AIModel.claude,
          isConfigured: _modelConfigStatus[AIModel.claude] ?? false,
          onTap: () => _showModelConfig(AIModel.claude),
        ),
        const SizedBox(height: 12),
        _ModelCard(
          model: AIModel.gemini,
          isConfigured: _modelConfigStatus[AIModel.gemini] ?? false,
          onTap: () => _showModelConfig(AIModel.gemini),
        ),
      ],
    );
  }

  void _showNewChatDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Conversation',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select your preferred AI model',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _ModelSelectionTile(
                model: AIModel.chatgpt,
                isConfigured: _modelConfigStatus[AIModel.chatgpt] ?? false,
                onSetup: () {
                  Navigator.pop(context);
                  _showModelConfig(AIModel.chatgpt);
                },
              ),
              const SizedBox(height: 12),
              _ModelSelectionTile(
                model: AIModel.claude,
                isConfigured: _modelConfigStatus[AIModel.claude] ?? false,
                onSetup: () {
                  Navigator.pop(context);
                  _showModelConfig(AIModel.claude);
                },
              ),
              const SizedBox(height: 12),
              _ModelSelectionTile(
                model: AIModel.gemini,
                isConfigured: _modelConfigStatus[AIModel.gemini] ?? false,
                onSetup: () {
                  Navigator.pop(context);
                  _showModelConfig(AIModel.gemini);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showModelConfig(AIModel model) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ModelSetupPage(model: model)),
    );
    // Reload configuration status after returning from setup page
    _loadConfigurationStatus();
  }

}

class _ChatCard extends StatelessWidget {
  const _ChatCard({required this.chat});

  final ChatSession chat;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: chat.model.color.withOpacity(0.2),
                    child: Icon(
                      chat.model.icon,
                      size: 20,
                      color: chat.model.color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chat.title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _formatTimestamp(chat.timestamp),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 11,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        chat.lastMessage,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class _ModelCard extends StatelessWidget {
  const _ModelCard({
    required this.model,
    required this.isConfigured,
    required this.onTap,
  });

  final AIModel model;
  final bool isConfigured;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: model.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(model.icon, color: model.color, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.displayName,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          model.description,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isConfigured
                            ? colorScheme.primaryContainer
                            : colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isConfigured
                                ? Icons.check_circle_rounded
                                : Icons.warning_rounded,
                            size: 16,
                            color: isConfigured
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isConfigured ? 'Ready to use' : 'Setup required',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isConfigured
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onErrorContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.settings_rounded,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModelSelectionTile extends StatelessWidget {
  const _ModelSelectionTile({
    required this.model,
    required this.isConfigured,
    required this.onSetup,
  });

  final AIModel model;
  final bool isConfigured;
  final VoidCallback onSetup;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: model.color.withOpacity(0.3), width: 2),
      ),
      child: InkWell(
        onTap: () {
          if (isConfigured) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Starting chat with ${model.displayName}'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          } else {
            onSetup();
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: model.color.withOpacity(0.2),
                child: Icon(model.icon, color: model.color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isConfigured ? model.tagline : 'Setup required',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isConfigured 
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.error,
                        fontWeight: isConfigured ? FontWeight.normal : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isConfigured ? Icons.arrow_forward_rounded : Icons.settings_rounded,
                color: model.color,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class ChatSession {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime timestamp;
  final AIModel model;

  ChatSession({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.timestamp,
    required this.model,
  });
}