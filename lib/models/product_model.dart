class Product {
  final int? id;
  final String name;
  final int price;
  final String description;
  final String? githubUrl;
  final String? createdAt;
  final String? updatedAt;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.description,
    this.githubUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // FIX: Handle price yang bisa berupa string "150000.00" atau double/num
    num priceValue = 0;
    if (json['price'] is int) {
      priceValue = json['price'] as int;
    } else if (json['price'] is double) {
      priceValue = json['price'] as double;
    } else if (json['price'] is String) {
      priceValue = double.tryParse(json['price']) ?? 0;
    } else if (json['price'] is num) {
      priceValue = json['price'] as num;
    }
    
    // Konversi ke int (bulatkan jika desimal)
    final intPrice = priceValue.toInt();
    
    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      price: intPrice,
      description: json['description'] ?? '',
      githubUrl: json['github_url'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'description': description,
    };
  }

  Map<String, dynamic> toSubmitJson(String githubUrl) {
    return {
      'name': name,
      'price': price,
      'description': description,
      'github_url': githubUrl,
    };
  }
}