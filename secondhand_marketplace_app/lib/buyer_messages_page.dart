import 'package:flutter/material.dart';
import 'constants.dart';
import 'buyer_home_page.dart';
import 'buyer_purchases_page.dart';
import 'buyer_wallet_page.dart';
import 'buyer_profile_page.dart';
import 'utils/page_transitions.dart';
import 'chat_detail_page.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  int _selectedIndex = 4; // Set to 4 for Messages tab
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  
  // Sample chat data
  final List<Map<String, dynamic>> _chats = [
    {
      'id': '1',
      'name': 'John Seller',
      'profilePic': 'https://picsum.photos/id/1005/200/200',
      'lastMessage': 'Is the iPhone still available?',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
      'unread': 2,
      'product': {
        'name': 'iPhone 13 Pro',
        'imageUrl': 'https://picsum.photos/id/1/200/200',
      },
    },
    {
      'id': '2',
      'name': 'Sarah Williams',
      'profilePic': 'https://picsum.photos/id/1027/200/200',
      'lastMessage': 'I can offer RM 400 for the sofa. Let me know if that works for you.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'unread': 0,
      'product': {
        'name': 'Leather Sofa',
        'imageUrl': 'https://picsum.photos/id/2/200/200',
      },
    },
    {
      'id': '3',
      'name': 'Mike Johnson',
      'profilePic': 'https://picsum.photos/id/1012/200/200',
      'lastMessage': 'Great! I can meet tomorrow at 3pm.',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'unread': 0,
      'product': {
        'name': 'Nike Air Jordan',
        'imageUrl': 'https://picsum.photos/id/3/200/200',
      },
    },
    {
      'id': '4',
      'name': 'Emma Davis',
      'profilePic': 'https://picsum.photos/id/1014/200/200',
      'lastMessage': 'Thanks for the quick delivery!',
      'timestamp': DateTime.now().subtract(const Duration(days: 3)),
      'unread': 0,
      'product': {
        'name': 'LEGO Star Wars Set',
        'imageUrl': 'https://picsum.photos/id/6/200/200',
      },
    },
    {
      'id': '5',
      'name': 'David Brown',
      'profilePic': 'https://picsum.photos/id/1025/200/200',
      'lastMessage': 'Do you have any other bikes for sale?',
      'timestamp': DateTime.now().subtract(const Duration(days: 5)),
      'unread': 0,
      'product': {
        'name': 'Mountain Bike',
        'imageUrl': 'https://picsum.photos/id/5/200/200',
      },
    },
  ];
  
  List<Map<String, dynamic>> get _filteredChats {
    if (_searchController.text.isEmpty) {
      return _chats;
    }
    
    final query = _searchController.text.toLowerCase();
    return _chats.where((chat) {
      return chat['name'].toLowerCase().contains(query) ||
             chat['product']['name'].toLowerCase().contains(query) ||
             chat['lastMessage'].toLowerCase().contains(query);
    }).toList();
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
        DarkPageReplaceRoute(page: const MyHomePage(title: 'Secondhand Marketplace')),
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
  
  void _navigateToChatDetail(Map<String, dynamic> chat) {
    // In a real app, this would navigate to a chat detail page
    // For now, we'll just mark the chat as read
    setState(() {
      final index = _chats.indexWhere((c) => c['id'] == chat['id']);
      if (index != -1) {
        _chats[index]['unread'] = 0;
      }
    });
    
    // Navigate to chat detail page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailPage(chat: chat),
      ),
    );
  }
  
  void _deleteChat(String chatId) {
    setState(() {
      _chats.removeWhere((chat) => chat['id'] == chatId);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Conversation deleted'),
        backgroundColor: AppColors.mutedTeal,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: () {
            // In a real app, this would restore the deleted chat
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Undo functionality would be implemented here'),
                backgroundColor: AppColors.mutedTeal,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.charcoalBlack,
      appBar: AppBar(
        backgroundColor: AppColors.deepSlateGray,
        title: !_isSearching
            ? Text(
                'Messages',
                style: TextStyle(color: AppColors.coolGray),
              )
            : TextField(
                controller: _searchController,
                style: TextStyle(color: AppColors.coolGray),
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  hintStyle: TextStyle(color: AppColors.coolGray.withAlpha(150)),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: AppColors.coolGray,
            ),
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
      body: _filteredChats.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: AppColors.coolGray.withAlpha(100),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchController.text.isEmpty
                        ? 'No conversations yet'
                        : 'No results found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.coolGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchController.text.isEmpty
                        ? 'Start browsing items to chat with sellers'
                        : 'Try a different search term',
                    style: TextStyle(
                      color: AppColors.coolGray.withAlpha(200),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: _filteredChats.length,
              separatorBuilder: (context, index) => Divider(
                color: AppColors.coolGray.withAlpha(50),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final chat = _filteredChats[index];
                return Dismissible(
                  key: Key(chat['id']),
                  background: Container(
                    color: AppColors.warmCoral,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: AppColors.deepSlateGray,
                          title: Text(
                            'Delete Conversation',
                            style: TextStyle(color: AppColors.coolGray),
                          ),
                          content: Text(
                            'Are you sure you want to delete this conversation?',
                            style: TextStyle(color: AppColors.coolGray),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: AppColors.coolGray),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text(
                                'Delete',
                                style: TextStyle(color: AppColors.warmCoral),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) {
                    _deleteChat(chat['id']);
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: NetworkImage(chat['profilePic']),
                        ),
                        if (chat['unread'] > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.warmCoral,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                chat['unread'].toString(),
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
                            chat['name'],
                            style: TextStyle(
                              fontWeight: chat['unread'] > 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: AppColors.coolGray,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatTimestamp(chat['timestamp']),
                          style: TextStyle(
                            fontSize: 12,
                            color: chat['unread'] > 0
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
                          chat['lastMessage'],
                          style: TextStyle(
                            color: chat['unread'] > 0
                                ? AppColors.coolGray
                                : AppColors.coolGray.withAlpha(150),
                            fontWeight: chat['unread'] > 0
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
                                  image: NetworkImage(chat['product']['imageUrl']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                chat['product']['name'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.coolGray.withAlpha(150),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () => _navigateToChatDetail(chat),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
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
            icon: Icon(Icons.chat_outlined),
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
