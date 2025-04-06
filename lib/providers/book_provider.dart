import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class BookProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Book> _books = [];
  List<Book> _filteredBooks = []; // Danh sách sách đã lọc theo tìm kiếm
  final Set<String> _favoriteBookIds = {}; // Lưu danh sách sách yêu thích

  List<Book> get books => List.unmodifiable(_filteredBooks.isEmpty ? _books : _filteredBooks);

  List<Book> get favoriteBooks =>
      _books.where((book) => _favoriteBookIds.contains(book.id)).toList();

  List<String> get categories =>
      _books.map((book) => book.category).toSet().toList();

  Future<void> fetchBooks() async {
    try {
      final querySnapshot = await _firestore.collection('books').get();
      _books = querySnapshot.docs.map((doc) {
        return Book(
          id: doc.id,
          title: doc['title'],
          author: doc['author'],
          price: doc['price'].toDouble(),
          imageUrl: doc['imageUrl'],
          category: doc['category'],
          description: doc['description'],
        );
      }).toList();
      _filteredBooks = List.from(_books); // Khởi tạo danh sách lọc
      notifyListeners();
    } catch (error) {
      print("Lỗi tải sách từ Firestore: $error");
      throw error;
    }
  }

  void searchBooks(String query) {
    if (query.isEmpty) {
      _filteredBooks = List.from(_books);
    } else {
      _filteredBooks = _books.where((book) =>
        book.title.toLowerCase().contains(query.toLowerCase()) ||
        book.author.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    notifyListeners();
  }

  Book findById(String id) {
    return _books.firstWhere((book) => book.id == id);
  }

  bool isFavorite(String bookId) {
    return _favoriteBookIds.contains(bookId);
  }

  void toggleFavorite(String bookId) {
    if (_favoriteBookIds.contains(bookId)) {
      _favoriteBookIds.remove(bookId);
    } else {
      _favoriteBookIds.add(bookId);
    }
    notifyListeners();
  }
}
