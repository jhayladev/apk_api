class Product {
  final int? id;
  final String title;
  final String description;
  final String category;
  final String brand;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String thumbnail;
  final List<String> images;
  final List<String> tags;

  const Product({
    this.id,
    required this.title,
    this.description = "",
    this.category = "",
    this.brand = "",
    this.price = 0,
    this.discountPercentage = 0,
    this.rating = 0,
    this.stock = 0,
    this.thumbnail = "",
    this.images = const [],
    this.tags = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json["id"] as num?)?.toInt(),
      title: "${json["title"] ?? ""}",
      description: "${json["description"] ?? ""}",
      category: "${json["category"] ?? ""}",
      brand: "${json["brand"] ?? ""}",
      price: (json["price"] as num?)?.toDouble() ?? 0,
      discountPercentage: (json["discountPercentage"] as num?)?.toDouble() ?? 0,
      rating: (json["rating"] as num?)?.toDouble() ?? 0,
      stock: (json["stock"] as num?)?.toInt() ?? 0,
      thumbnail: "${json["thumbnail"] ?? ""}",
      images: List<String>.from(json["images"] ?? const []),
      tags: List<String>.from(json["tags"] ?? const []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "category": category,
      "brand": brand,
      "price": price,
      "discountPercentage": discountPercentage,
      "rating": rating,
      "stock": stock,
      "thumbnail": thumbnail,
      "images": images,
      "tags": tags,
    };
  }

  Map<String, dynamic> paraEnvio() {
    return {
      "title": title,
      "description": description,
      "category": category,
      "brand": brand,
      "price": price,
      "stock": stock,
    };
  }

  double get precioFinal => price * (1 - discountPercentage / 100);

  String get imagenPrincipal {
    if (thumbnail.isNotEmpty) return thumbnail;
    if (images.isNotEmpty) return images.first;
    return "";
  }
}

class ProductsPage {
  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  const ProductsPage({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ProductsPage.fromJson(Map<String, dynamic> json) {
    final lista = (json["products"] as List? ?? const [])
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
    return ProductsPage(
      products: lista,
      total: (json["total"] as num?)?.toInt() ?? lista.length,
      skip: (json["skip"] as num?)?.toInt() ?? 0,
      limit: (json["limit"] as num?)?.toInt() ?? lista.length,
    );
  }
}

class ProductCategory {
  final String slug;
  final String name;

  const ProductCategory({required this.slug, required this.name});

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      slug: "${json["slug"] ?? ""}",
      name: "${json["name"] ?? ""}",
    );
  }
}

class ProductoResultado {
  final Product? producto;
  final bool eliminado;

  const ProductoResultado({this.producto, this.eliminado = false});
}
