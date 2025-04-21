import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

void main() => runApp(const ChatApp());

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Chat UI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [
  ChatMessage(
    text: "Hey there! How are you doing?",
    isMe: false,
    time: DateTime.now().subtract(const Duration(minutes: 15)),
  ),
  ChatMessage(
    text: "I'm good, thanks! Just working on a Flutter project.",
    isMe: true,
    time: DateTime.now().subtract(const Duration(minutes: 10)),
  ),
  ChatMessage(
    text: "That sounds interesting! What kind of app are you building?",
    isMe: false,
    time: DateTime.now().subtract(const Duration(minutes: 8)),
  ),
  ChatMessage(
    text: "A simple chat UI like this one 😄",
    isMe: true,
    time: DateTime.now().subtract(const Duration(minutes: 5)),
  ),
  ChatMessage(
    text: "Looks great! I love the animations.",
    isMe: false,
    time: DateTime.now().subtract(const Duration(minutes: 2)),
  ),
];

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isMe: true,
        time: DateTime.now(),
      ));
    });

    // Add a fake reply after 1-3 seconds
    Future.delayed(Duration(seconds: 1 + (DateTime.now().second % 3)), () {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          text: _getRandomReply(),
          isMe: false,
          time: DateTime.now(),
        ));
      });
      _scrollToBottom();
    });

    _textController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: 300.ms,
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getRandomReply() {
    final replies = [
      "That's interesting!",
      "Tell me more about that.",
      "I see what you mean.",
      "Nice!",
      "What else is new?",
      "How's your day going?",
      "I was thinking the same thing!",
      "Let's chat more about this later.",
    ];
    return replies[DateTime.now().second % replies.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Chat'),
        centerTitle: true,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _ChatBubble(
                  message: _messages[index],
                  isFirstInSequence: index == 0 || 
                      _messages[index - 1].isMe != _messages[index].isMe,
                  isLastInSequence: index == _messages.length - 1 || 
                      _messages[index + 1].isMe != _messages[index].isMe,
                )
                .animate()
                .fadeIn(duration: 200.ms)
                .move(
                  begin: Offset(_messages[index].isMe ? 50 : -50, 0),
                  curve: Curves.easeOut,
                );
              },
            ),
          ),
          _MessageComposer(
            controller: _textController,
            onSubmitted: _handleSubmitted,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime time;

  
  const ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
  });
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
    required this.isFirstInSequence,
    required this.isLastInSequence,
  });

  final ChatMessage message;
  final bool isFirstInSequence;
  final bool isLastInSequence;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: message.isMe
                  ? theme.colorScheme.primary
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.only(
                topLeft: !message.isMe && isFirstInSequence
                    ? Radius.zero
                    : const Radius.circular(12),
                topRight: message.isMe && isFirstInSequence
                    ? Radius.zero
                    : const Radius.circular(12),
                bottomLeft: Radius.circular(
                    !message.isMe && isLastInSequence ? 0 : 12),
                bottomRight: Radius.circular(
                    message.isMe && isLastInSequence ? 0 : 12),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 14,
            ),
            margin: EdgeInsets.only(
              top: isFirstInSequence ? 6 : 2,
              bottom: isLastInSequence ? 6 : 2,
              left: message.isMe ? 30 : 0,
              right: !message.isMe ? 30 : 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: message.isMe ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('h:mm a').format(message.time),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: message.isMe
                        ? Colors.white.withOpacity(0.7)
                        : Colors.black54,
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

class _MessageComposer extends StatelessWidget {
  const _MessageComposer({
    required this.controller,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.emoji_emotions_outlined),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
              ),
              onSubmitted: onSubmitted,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => onSubmitted(controller.text),
          ),
        ],
      ),
    );
  }
}