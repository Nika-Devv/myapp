class Product {
  final int id;
  final String name;
  final String productCode;
  final double price;
  final double cost;
  final double stockQuantity;
  final String description;
  final String status;

  // DummyJSON / old fields
  final String _title;
  final String _brand;
  final String _category;
  final String _thumbnail;
  final List<String> _images;
  final int _stock;
  final double _rating;
  final String _sku;
  final String _warrantyInformation;
  final String _shippingInformation;

  Product({
    this.id = 0,
    this.name = '',
    this.productCode = '',
    this.price = 0.0,
    this.cost = 0.0,
    this.stockQuantity = 0.0,
    this.description = '',
    this.status = '',
    String? title,
    String? brand,
    String? category,
    String? thumbnail,
    List<String>? images,
    int? stock,
    double? rating,
    String? sku,
    String? warrantyInformation,
    String? shippingInformation,
  })  : _title = title ?? '',
        _brand = brand ?? '',
        _category = category ?? '',
        _thumbnail = thumbnail ?? '',
        _images = images ?? [],
        _stock = stock ?? 0,
        _rating = rating ?? 0.0,
        _sku = sku ?? '',
        _warrantyInformation = warrantyInformation ?? '',
        _shippingInformation = shippingInformation ?? '';

  // Getters that fallback gracefully
  String get title => _title.isNotEmpty ? _title : (name.isNotEmpty ? name : 'Unknown Product');
  String get brand => _brand.isNotEmpty ? _brand : 'Unknown Brand';
  String get category => _category.isNotEmpty ? _category : 'Uncategorized';
  String get thumbnail => _thumbnail.isNotEmpty ? _thumbnail : 'https://via.placeholder.com/150';
  List<String> get images => _images.isNotEmpty ? _images : ['https://via.placeholder.com/150'];
  int get stock => _stock > 0 ? _stock : stockQuantity.toInt();
  double get rating => _rating;
  String get sku => _sku.isNotEmpty ? _sku : (productCode.isNotEmpty ? productCode : 'N/A');
  String get warrantyInformation => _warrantyInformation.isNotEmpty ? _warrantyInformation : 'No warranty';
  String get shippingInformation => _shippingInformation.isNotEmpty ? _shippingInformation : 'Standard shipping';

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      productCode: json['productCode'] ?? '',
      price: json['price']?.toDouble() ?? 0.0,
      cost: json['cost']?.toDouble() ?? 0.0,
      stockQuantity: json['stockQuantity']?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      title: json['title'],
      brand: json['brand'],
      category: json['category'],
      thumbnail: json['thumbnail'],
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      stock: json['stock'],
      rating: json['rating']?.toDouble(),
      sku: json['sku'],
      warrantyInformation: json['warrantyInformation'],
      shippingInformation: json['shippingInformation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != 0) 'id': id,
      'name': name,
      'productCode': productCode,
      'price': price,
      'cost': cost,
      'stockQuantity': stockQuantity,
      'description': description,
      'status': status.isNotEmpty ? status : 'ACT', // Default to ACT
    };
  }
}

class ProductResponse {
  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  ProductResponse({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      products: List<Product>.from(
          json['products']?.map((x) => Product.fromJson(x)) ?? []),
      total: json['total'] ?? 0,
      skip: json['skip'] ?? 0,
      limit: json['limit'] ?? 0,
    );
  }
}
