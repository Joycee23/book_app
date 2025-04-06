class Book {
  final String id;
  final String title;
  final String author;
  final String imageUrl;
  final double price;
  final String category;
  final String description;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.price,
    required this.category,
    this.description = 'Chưa có mô tả.', // ✅ Giá trị mặc định nếu không có mô tả
  });

  // Chuyển đổi từ JSON sang Book object
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'].toString(),
      title: json['title'],
      author: json['author'],
      imageUrl: json['imageUrl'],
      price: (json['price'] as num).toDouble(), // Đảm bảo chuyển đổi sang double
      category: json['category'],
      description: json['description'] ?? 'Chưa có mô tả.', // ✅ Giá trị mặc định
    );
  }

  // Chuyển đổi từ Book object sang JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "author": author,
      "imageUrl": imageUrl,
      "price": price,
      "category": category,
      "description": description,
    };
  }
}
