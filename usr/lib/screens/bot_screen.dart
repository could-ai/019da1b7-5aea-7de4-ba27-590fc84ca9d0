import 'package:flutter/material.dart';

class BotScreen extends StatefulWidget {
  const BotScreen({super.key});

  @override
  State<BotScreen> createState() => _BotScreenState();
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class _BotScreenState extends State<BotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hello! I'm your CalmStudy Assistant. How can I help you today? I can explain homework, summarize texts, or help you understand complex topics.",
      isUser: false,
    ),
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text.trim();
    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
    });
    _controller.clear();

    // Mock bot response
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          text: _generateMockResponse(userMessage),
          isUser: false,
        ));
      });
    });
  }

  String _generateMockResponse(String userText) {
    final lowerText = userText.toLowerCase();
    if (lowerText.contains('summary') || lowerText.contains('summarize')) {
      return "Here's a brief summary of what you asked: This topic focuses on understanding the core principles without getting bogged down in details. Make sure to review the main keywords and their definitions.";
    } else if (lowerText.contains('homework') || lowerText.contains('assignment')) {
      return "For this assignment, I recommend breaking it down into 3 smaller tasks. Start with the easiest one to build momentum. Do you need help understanding a specific question?";
    } else if (lowerText.contains('explain') || lowerText.contains('what is')) {
      return "That's a great question! Simply put, it's a concept that helps explain how certain systems work. Let me know if you want a more detailed breakdown.";
    } else {
      return "I understand. As an intelligent assistant, I'm here to support your learning process. Could you provide a bit more context or paste the text you want me to analyze?";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intelligent Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bot can explain homework, create summaries, and provide learning support.')),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _ChatBubble(message: msg);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask for a summary, explanation...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: message.isUser 
              ? Theme.of(context).colorScheme.primaryContainer 
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16.0).copyWith(
            bottomRight: message.isUser ? const Radius.circular(0) : null,
            bottomLeft: !message.isUser ? const Radius.circular(0) : null,
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser 
                ? Theme.of(context).colorScheme.onPrimaryContainer 
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
