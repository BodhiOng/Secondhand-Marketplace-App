import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'constants.dart';
import 'buyer_home_page.dart';
import 'buyer_purchases_page.dart';
import 'buyer_wallet_page.dart';
import 'buyer_profile_page.dart';
import 'utils/page_transitions.dart';
import 'buyer_chat_detail_page.dart';
import 'services/chat_service.dart';
import 'services/notification_service.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  int _selectedIndex = 4; // Set to 4 for Messages tab
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  // Services
  final ChatService _chatService = ChatService();
  final NotificationService _notificationService = NotificationService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream for chats
  Stream<QuerySnapshot>? _chatsStream;

  // Filter chats based on search query
  List<QueryDocumentSnapshot> _filterChats(List<QueryDocumentSnapshot> chats) {
    if (_searchController.text.isEmpty) {
      return chats;
    }

    final query = _searchController.text.toLowerCase();
    return chats.where((chatDoc) {
      final chat = chatDoc.data() as Map<String, dynamic>;
      final otherParticipantId = (chat['participants'] as List<dynamic>)
          .firstWhere((id) => id != _auth.currentUser?.uid, orElse: () => '');

      // Get other participant's name
      String participantName =
          chat['participantNames']?[otherParticipantId] ?? 'Unknown';

      return participantName.toLowerCase().contains(query) ||
          (chat['product']?['name'] ?? '').toLowerCase().contains(query) ||
          (chat['lastMessage'] ?? '').toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadChats();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
  }

  void _loadChats() {
    if (_auth.currentUser != null) {
      _chatsStream = _chatService.getChats();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      // Navigate directly to HomePage
      Navigator.pushReplacement(
        context,
        DarkPageReplaceRoute(
          page: const MyHomePage(title: 'Secondhand Marketplace'),
        ),
      );
    } else if (index == 1) {
      // Navigate to My Purchases page
      Navigator.pushReplacement(
        context,
        DarkPageReplaceRoute(page: const MyPurchasesPage()),
      );
    } else if (index == 2) {
      // Navigate to Wallet page
      Navigator.pushReplacement(
        context,
        DarkPageReplaceRoute(page: const MyWalletPage()),
      );
    } else if (index == 3) {
      // Navigate to Profile page
      Navigator.pushReplacement(
        context,
        DarkPageReplaceRoute(page: const MyProfilePage()),
      );
    } else if (index == 4) {
      // Already on Messages page, just update index
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      // More than a week ago, show date
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      // Days ago
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      // Hours ago
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      // Minutes ago
      return '${difference.inMinutes}m ago';
    } else {
      // Just now
      return 'Just now';
    }
  }

  void _navigateToChatDetail(DocumentSnapshot chatDoc) {
    final chatData = chatDoc.data() as Map<String, dynamic>;

    // Mark messages as read when navigating to chat detail
    _chatService.markMessagesAsRead(chatDoc.id);

    // Subscribe to notifications for this chat
    _notificationService.subscribeToChat(chatDoc.id);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChatDetailPage(chatId: chatDoc.id, chatData: chatData),
      ),
    ).then((_) {
      // Unsubscribe from notifications when returning from chat detail
      _notificationService.unsubscribeFromChat(chatDoc.id);
    });
  }

  void deleteChat(String chatId) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.deepSlateGray,
            title: Text(
              'Delete Chat',
              style: TextStyle(color: AppColors.coolGray),
            ),
            content: Text(
              'Are you sure you want to delete this chat? This action cannot be undone.',
              style: TextStyle(color: AppColors.coolGray),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.mutedTeal),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  performChatDeletion(chatId);
                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> performChatDeletion(String chatId) async {
    try {
      await _chatService.deleteChat(chatId);

      if (mounted) {
        // Show confirmation snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Chat deleted'),
            backgroundColor: AppColors.mutedTeal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting chat: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: TextStyle(color: AppColors.coolGray),
                  decoration: InputDecoration(
                    hintText: 'Search chats...',
                    hintStyle: TextStyle(
                      color: AppColors.coolGray.withAlpha(150),
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                )
                : const Text('Messages'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body:
          _auth.currentUser == null
              ? const Center(child: Text('Please sign in to view messages'))
              : StreamBuilder<QuerySnapshot>(
                stream: _chatsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading chats: ${snapshot.error}',
                        style: TextStyle(color: AppColors.coolGray),
                      ),
                    );
                  }

                  final chatDocs = snapshot.data?.docs ?? [];
                  final filteredChats = _filterChats(chatDocs);

                  if (filteredChats.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 80,
                            color: AppColors.coolGray.withAlpha(150),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No messages yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.coolGray,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start a conversation by messaging a seller',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.coolGray.withAlpha(150),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredChats.length,
                    itemBuilder: (context, index) {
                      final chatDoc = filteredChats[index];
                      final chatData = chatDoc.data() as Map<String, dynamic>;

                      // Get the other participant's ID (not the current user)
                      final participants = List<String>.from(
                        chatData['participants'] ?? [],
                      );
                      final otherParticipantId = participants.firstWhere(
                        (id) => id != _auth.currentUser?.uid,
                        orElse: () => 'unknown',
                      );

                      // Get participant name from the chat data or use a placeholder
                      final participantNames =
                          chatData['participantNames']
                              as Map<String, dynamic>? ??
                          {};
                      final otherParticipantName =
                          participantNames[otherParticipantId] ??
                          'Unknown User';

                      // Get profile image URL
                      final participantImages =
                          chatData['participantImages']
                              as Map<String, dynamic>? ??
                          {};
                      final profileImageUrl =
                          participantImages[otherParticipantId] ??
                          'https://i.pinimg.com/1200x/2c/47/d5/2c47d5dd5b532f83bb55c4cd6f5bd1ef.jpg';

                      // Get unread count for current user
                      final unreadCountMap = Map<String, dynamic>.from(
                        chatData['unreadCount'] ?? {},
                      );
                      final unreadCount =
                          unreadCountMap[_auth.currentUser?.uid] ?? 0;

                      // Get product data
                      final product =
                          chatData['product'] as Map<String, dynamic>? ?? {};

                      // Get timestamp and format it
                      final timestamp =
                          chatData['lastMessageTimestamp'] as Timestamp?;
                      final dateTime = timestamp?.toDate() ?? DateTime.now();

                      return Dismissible(
                        key: Key(chatDoc.id),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: AppColors.deepSlateGray,
                                title: Text(
                                  'Delete Chat',
                                  style: TextStyle(color: AppColors.coolGray),
                                ),
                                content: Text(
                                  'Are you sure you want to delete this chat?',
                                  style: TextStyle(color: AppColors.coolGray),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(false),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: AppColors.mutedTeal,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                      deleteChat(chatDoc.id);
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.redAccent),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: ListTile(
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: CachedNetworkImageProvider(
                                  profileImageUrl,
                                ),
                              ),
                              if (unreadCount > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColors.mutedTeal,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '$unreadCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  otherParticipantName,
                                  style: TextStyle(
                                    fontWeight:
                                        unreadCount > 0
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    color: AppColors.coolGray,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                _formatTimestamp(dateTime),
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      unreadCount > 0
                                          ? AppColors.mutedTeal
                                          : AppColors.coolGray.withAlpha(150),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                chatData['lastMessage'] ?? '',
                                style: TextStyle(
                                  color:
                                      unreadCount > 0
                                          ? AppColors.coolGray
                                          : AppColors.coolGray.withAlpha(150),
                                  fontWeight:
                                      unreadCount > 0
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      image: DecorationImage(
                                        image: CachedNetworkImageProvider(
                                          product['imageUrl'] ??
                                              'https://upload.wikimedia.org/wikipedia/commons/1/14/No_Image_Available.jpg',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      product['name'] ?? 'Unknown Product',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.coolGray.withAlpha(
                                          150,
                                        ),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () => _navigateToChatDetail(chatDoc),
                        ),
                      );
                    },
                  );
                },
              ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'My Purchases',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            label: 'Messages',
          ),
        ],
        currentIndex: _selectedIndex,
        backgroundColor: AppColors.deepSlateGray,
        selectedItemColor: AppColors.softLemonYellow,
        unselectedItemColor: AppColors.coolGray,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
