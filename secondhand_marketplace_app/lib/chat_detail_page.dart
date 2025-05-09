import 'package:flutter/material.dart';
import 'dart:math';
import 'constants.dart';

class ChatDetailPage extends StatefulWidget {
  final Map<String, dynamic> chat;

  const ChatDetailPage({super.key, required this.chat});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Sample messages for demonstration
  late List<Map<String, dynamic>> _messages;
  
  @override
  void initState() {
    super.initState();
    // Initialize with sample messages based on the chat
    _initializeMessages();
  }
  
  void _initializeMessages() {
    final random = Random();
    final productName = widget.chat['product']['name'];
    
    _messages = [
      {
        'id': '1',
        'text': 'Hi, I\'m interested in your $productName. Is it still available?',
        'isMe': true,
        'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      },
      {
        'id': '2',
        'text': 'Yes, it\'s still available!',
        'isMe': false,
        'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 45)),
      },
      {
        'id': '3',
        'text': 'Great! What\'s the condition like?',
        'isMe': true,
        'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 30)),
      },
      {
        'id': '4',
        'text': 'It\'s in excellent condition, barely used. I can send more photos if you\'d like.',
        'isMe': false,
        'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 1)),
      },
      {
        'id': '5',
        'text': 'That would be great. Also, would you be open to negotiating on the price?',
        'isMe': true,
        'timestamp': DateTime.now().subtract(const Duration(hours: 23)),
      },
    ];
    
    // Add the last message from the chat list
    if (widget.chat['lastMessage'] != _messages.last['text']) {
      _messages.add({
        'id': '${_messages.length + 1}',
        'text': widget.chat['lastMessage'],
        'isMe': random.nextBool(),
        'timestamp': widget.chat['timestamp'],
      });
    }
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    setState(() {
      _messages.add({
        'id': '${_messages.length + 1}',
        'text': _messageController.text.trim(),
        'isMe': true,
        'timestamp': DateTime.now(),
      });
      _messageController.clear();
    });
    
    // Scroll to bottom after sending message
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
    
    // Simulate a reply after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'id': '${_messages.length + 1}',
            'text': _getRandomReply(),
            'isMe': false,
            'timestamp': DateTime.now(),
          });
        });
        
        // Scroll to bottom after receiving reply
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }
  
  String _getRandomReply() {
    final replies = [
      'Sure, that sounds good!',
      'I can meet tomorrow if that works for you.',
      'Would you like to see more photos?',
      'I can offer a small discount if you can pick it up today.',
      'Thanks for your interest!',
      'Let me think about your offer and get back to you.',
      'Is there anything else you\'d like to know about the item?',
    ];
    
    return replies[Random().nextInt(replies.length)];
  }
  
  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
  
  String _formatMessageDate(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    
    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.charcoalBlack,
      appBar: AppBar(
        backgroundColor: AppColors.deepSlateGray,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.coolGray,
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(widget.chat['profilePic']),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chat['name'],
                    style: TextStyle(color: AppColors.coolGray, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Re: ${widget.chat['product']['name']}',
                    style: TextStyle(
                      color: AppColors.coolGray.withAlpha(150),
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            color: AppColors.coolGray,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: AppColors.deepSlateGray,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.visibility,
                        color: AppColors.mutedTeal,
                      ),
                      title: Text(
                        'View Product',
                        style: TextStyle(color: AppColors.coolGray),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to product details
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Navigate to product details would be implemented here'),
                            backgroundColor: AppColors.mutedTeal,
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.report_outlined,
                        color: AppColors.warmCoral,
                      ),
                      title: Text(
                        'Report User',
                        style: TextStyle(color: AppColors.coolGray),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        // Show report dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Report functionality would be implemented here'),
                            backgroundColor: AppColors.mutedTeal,
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.block,
                        color: AppColors.warmCoral,
                      ),
                      title: Text(
                        'Block User',
                        style: TextStyle(color: AppColors.coolGray),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        // Show block confirmation
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Block functionality would be implemented here'),
                            backgroundColor: AppColors.mutedTeal,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Product info banner
          Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.deepSlateGray.withAlpha(150),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(widget.chat['product']['imageUrl']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.chat['product']['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.coolGray,
                        ),
                      ),
                      Text(
                        'Tap to view product details',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.coolGray.withAlpha(150),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final showDate = index == 0 || 
                    _formatMessageDate(_messages[index]['timestamp']) != 
                    _formatMessageDate(_messages[index - 1]['timestamp']);
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showDate)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.deepSlateGray,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _formatMessageDate(message['timestamp']),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.coolGray.withAlpha(200),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: message['isMe']
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!message['isMe'])
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(widget.chat['profilePic']),
                            ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: message['isMe']
                                    ? AppColors.mutedTeal
                                    : AppColors.deepSlateGray,
                                borderRadius: BorderRadius.circular(16).copyWith(
                                  bottomLeft: message['isMe']
                                      ? const Radius.circular(16)
                                      : const Radius.circular(0),
                                  bottomRight: message['isMe']
                                      ? const Radius.circular(0)
                                      : const Radius.circular(16),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message['text'],
                                    style: TextStyle(
                                      color: message['isMe']
                                          ? Colors.white
                                          : AppColors.coolGray,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatTime(message['timestamp']),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: message['isMe']
                                          ? Colors.white.withAlpha(180)
                                          : AppColors.coolGray.withAlpha(150),
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (message['isMe'])
                            const CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage('https://picsum.photos/id/1005/200/200'),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          
          // Message input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: AppColors.deepSlateGray,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_photo_alternate),
                  color: AppColors.mutedTeal,
                  onPressed: () {
                    // Add photo functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Add photo functionality would be implemented here'),
                        backgroundColor: AppColors.mutedTeal,
                      ),
                    );
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: TextStyle(color: AppColors.coolGray),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: AppColors.coolGray.withAlpha(150)),
                      filled: true,
                      fillColor: AppColors.charcoalBlack,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: AppColors.mutedTeal,
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
