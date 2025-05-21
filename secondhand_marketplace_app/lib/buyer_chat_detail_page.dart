import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'constants.dart';
import 'services/chat_service.dart';

class ChatDetailPage extends StatefulWidget {
  final String chatId;
  final Map<String, dynamic> chatData;

  const ChatDetailPage({
    super.key,
    required this.chatId,
    required this.chatData,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  // Services
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream for messages
  Stream<QuerySnapshot>? _messagesStream;

  // Loading state
  bool _isLoading = false;
  bool _isSendingImage = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    // Mark messages as read when opening the chat
    _chatService.markMessagesAsRead(widget.chatId);

    // Set up messages stream
    _messagesStream = _chatService.getMessages(widget.chatId);

    // Scroll to bottom when new messages arrive
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _chatService.sendMessage(widget.chatId, text);
      _messageController.clear();

      // Scroll to bottom after sending
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending message: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndSendImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image == null) return;

      setState(() {
        _isSendingImage = true;
      });

      // Convert XFile to File
      final File imageFile = File(image.path);

      // Upload and send the image
      await _chatService.sendImageMessage(widget.chatId, imageFile);

      // Scroll to bottom after sending
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollToBottom();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSendingImage = false;
      });
    }
  }

  String _formatTime(DateTime timestamp) {
    return DateFormat('h:mm a').format(timestamp);
  }

  String _formatMessageDate(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d, yyyy').format(timestamp);
    }
  }

  Widget _buildMessageItem(DocumentSnapshot messageDoc) {
    final messageData = messageDoc.data() as Map<String, dynamic>;
    final senderId = messageData['senderId'] as String;
    final isMe = senderId == _auth.currentUser?.uid;
    final timestamp =
        (messageData['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
    final text = messageData['text'] as String;
    final imageUrl = messageData['imageUrl'] as String?;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: CachedNetworkImageProvider(
                  _getOtherParticipantImage(),
                ),
              ),
            ),

          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10.0,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.mutedTeal : AppColors.deepSlateGray,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageUrl != null)
                        GestureDetector(
                          onTap: () {
                            // Show full image in dialog
                            showDialog(
                              context: context,
                              builder:
                                  (context) => Dialog(
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      fit: BoxFit.contain,
                                      placeholder:
                                          (context, url) => const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                      errorWidget:
                                          (context, url, error) =>
                                              const Icon(Icons.error),
                                    ),
                                  ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              width: 200,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) =>
                                      const Icon(Icons.error),
                            ),
                          ),
                        ),
                      if (text != 'Image')
                        Text(
                          text,
                          style: TextStyle(
                            color: isMe ? Colors.white : AppColors.coolGray,
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 4.0,
                    left: 4.0,
                    right: 4.0,
                  ),
                  child: Text(
                    _formatTime(timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.coolGray.withAlpha(150),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (isMe)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: CachedNetworkImageProvider(
                  _auth.currentUser?.photoURL ??
                      'https://i.pinimg.com/1200x/2c/47/d5/2c47d5dd5b532f83bb55c4cd6f5bd1ef.jpg',
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getOtherParticipantImage() {
    final participants = List<String>.from(
      widget.chatData['participants'] ?? [],
    );
    final otherParticipantId = participants.firstWhere(
      (id) => id != _auth.currentUser?.uid,
      orElse: () => 'unknown',
    );

    final participantImages =
        widget.chatData['participantImages'] as Map<String, dynamic>? ?? {};
    return participantImages[otherParticipantId] ??
        'https://i.pinimg.com/1200x/2c/47/d5/2c47d5dd5b532f83bb55c4cd6f5bd1ef.jpg';
  }

  String _getOtherParticipantName() {
    final participants = List<String>.from(
      widget.chatData['participants'] ?? [],
    );
    final otherParticipantId = participants.firstWhere(
      (id) => id != _auth.currentUser?.uid,
      orElse: () => 'unknown',
    );

    final participantNames =
        widget.chatData['participantNames'] as Map<String, dynamic>? ?? {};
    return participantNames[otherParticipantId] ?? 'Unknown User';
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.chatData['product'] as Map<String, dynamic>? ?? {};
    final productName = product['name'] ?? 'Unknown Product';
    final productImage =
        product['imageUrl'] ??
        'https://upload.wikimedia.org/wikipedia/commons/1/14/No_Image_Available.jpg';

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: CachedNetworkImageProvider(
                _getOtherParticipantImage(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getOtherParticipantName(),
                    style: TextStyle(fontSize: 16, color: AppColors.coolGray),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: AppColors.deepSlateGray,
                builder:
                    (context) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Product Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.coolGray,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: productImage,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      productName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.coolGray,
                                      ),
                                    ),
                                    if (product['price'] != null)
                                      Text(
                                        'RM ${product['price']}',
                                        style: TextStyle(
                                          color: AppColors.mutedTeal,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.mutedTeal,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(40),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              // Navigate to product details page
                            },
                            child: const Text('View Product'),
                          ),
                        ],
                      ),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.deepSlateGray,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: productImage,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.coolGray,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (product['price'] != null)
                        Text(
                          'RM ${product['price']}',
                          style: TextStyle(color: AppColors.mutedTeal),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading messages: ${snapshot.error}',
                      style: TextStyle(color: AppColors.coolGray),
                    ),
                  );
                }

                final messages = snapshot.data?.docs ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet. Say hello!',
                      style: TextStyle(
                        color: AppColors.coolGray.withAlpha(150),
                      ),
                    ),
                  );
                }

                // Group messages by date
                final groupedMessages = <String, List<DocumentSnapshot>>{};
                for (final message in messages) {
                  final messageData = message.data() as Map<String, dynamic>;
                  final timestamp =
                      (messageData['timestamp'] as Timestamp?)?.toDate() ??
                      DateTime.now();
                  final dateString = _formatMessageDate(timestamp);

                  if (!groupedMessages.containsKey(dateString)) {
                    groupedMessages[dateString] = [];
                  }

                  groupedMessages[dateString]!.add(message);
                }

                // Build the list with date headers
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: groupedMessages.length,
                  itemBuilder: (context, index) {
                    final date = groupedMessages.keys.elementAt(index);
                    final dateMessages = groupedMessages[date]!;

                    return Column(
                      children: [
                        // Date header
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.deepSlateGray,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                date,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.coolGray.withAlpha(180),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Messages for this date
                        ...dateMessages.map(
                          (message) => _buildMessageItem(message),
                        ),
                      ],
                    );
                  },
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
                  onPressed: _isSendingImage ? null : _pickAndSendImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: TextStyle(color: AppColors.coolGray),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(
                        color: AppColors.coolGray.withAlpha(150),
                      ),
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
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon:
                      _isLoading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.mutedTeal,
                              ),
                            ),
                          )
                          : const Icon(Icons.send),
                  color: AppColors.mutedTeal,
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
