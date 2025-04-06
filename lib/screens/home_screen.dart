import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:book_app/providers/book_provider.dart';
import 'package:book_app/screens/favorite_screen.dart';
import 'package:book_app/screens/cart_screen.dart';
import 'package:book_app/screens/profile_screen.dart';
import 'package:book_app/screens/category_books_screen.dart';
import 'package:book_app/widgets/book_item.dart';
import 'package:book_app/screens/book_detail_screen.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreenContent(),
    FavoriteScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Yêu thích'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Giỏ hàng'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  bool _isLoading = true;
  String? _errorMessage;
  List<String> _bannerImages = [];
  int _currentBannerIndex = 0;
  PageController _pageController = PageController();
  Timer? _bannerTimer;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBooks();
    _fetchBannerImages();
    _startBannerAutoScroll();
  }

  void _startBannerAutoScroll() {
    _bannerTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_bannerImages.isNotEmpty) {
        setState(() {
          _currentBannerIndex = (_currentBannerIndex + 1) % _bannerImages.length;
          _pageController.animateToPage(
            _currentBannerIndex,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchBooks() async {
    try {
      await Provider.of<BookProvider>(context, listen: false).fetchBooks();
    } catch (error) {
      setState(() {
        _errorMessage = "Lỗi tải sách. Vui lòng thử lại!";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchBannerImages() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('ads').get();
      setState(() {
        _bannerImages = snapshot.docs.map((doc) => doc['imageUrl'] as String).toList();
      });
    } catch (error) {
      print("Lỗi tải ảnh banner: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final books = bookProvider.books;
    final categories = bookProvider.categories;

    return Scaffold(
      backgroundColor: Colors.orange[50],
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : books.isEmpty
                  ? const Center(child: Text("Không có sách nào!"))
                  : Padding(
                      padding: const EdgeInsets.all(10),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 30),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: "Tìm kiếm sách...",
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide.none,
                                      ),
                                      prefixIcon: Icon(Icons.search),
                                    ),
                                    onChanged: (query) {
                                      bookProvider.searchBooks(query);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            if (_bannerImages.isNotEmpty)
                              SizedBox(
                                height: 150,
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: _bannerImages.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          _bannerImages[index],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            SizedBox(height: 10),
                            ...categories.map((category) {
                              final categoryBooks = books
                                  .where((book) => book.category == category)
                                  .toList();
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      category,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepOrange),
                                    ),
                                  ),
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.7,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                    ),
                                    itemCount: categoryBooks.length,
                                    itemBuilder: (context, index) {
                                      final book = categoryBooks[index];
                                      return BookItem(
                                        key: ValueKey(book.id),
                                        title: book.title,
                                        author: book.author,
                                        imageUrl: book.imageUrl,
                                        bookId: book.id,
                                      );
                                    },
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
    );
  }
}
