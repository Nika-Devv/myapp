import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/product.dart';
import 'product_view_detail.dart';

class ProductViewList extends StatefulWidget {
  const ProductViewList({super.key});

  @override
  State<ProductViewList> createState() => _ProductViewListState();
}

class _ProductViewListState extends State<ProductViewList> {
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        return product.title.toLowerCase().contains(query) ||
            product.brand.toLowerCase().contains(query) ||
            product.description.toLowerCase().contains(query);
      }).toList();
      _currentPage = 1; // Reset to first page on search
    });
  }

  Future<void> _loadProducts() async {
    try {
      final String jsonString = await rootBundle.loadString('lib/json_data/products.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final productResponse = ProductResponse.fromJson(jsonData);
      setState(() {
        _allProducts = productResponse.products;
        _filteredProducts = _allProducts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      debugPrint('Error loading products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (_filteredProducts.length / _itemsPerPage).ceil();
    if (_currentPage > totalPages && totalPages > 0) {
      _currentPage = totalPages;
    }

    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = min(startIndex + _itemsPerPage, _filteredProducts.length);
    final displayedProducts = _filteredProducts.isNotEmpty
        ? _filteredProducts.sublist(startIndex, endIndex)
        : <Product>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error: $_errorMessage', style: const TextStyle(color: Colors.red)),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _filteredProducts.isEmpty
                          ? const Center(child: Text('No products found.'))
                          : Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: displayedProducts.length,
                                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                                    itemBuilder: (context, index) {
                                      final product = displayedProducts[index];
                                      return Card(
                                        elevation: 4,
                                        margin: const EdgeInsets.only(bottom: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(12),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ProductViewDetail(product: product),
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: Image.network(
                                                    product.thumbnail,
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) =>
                                                        Container(
                                                      width: 100,
                                                      height: 100,
                                                      color: Colors.grey[200],
                                                      child: const Icon(Icons.image_not_supported),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        product.title,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        product.brand.isNotEmpty ? product.brand : 'Unknown Brand',
                                                        style: TextStyle(
                                                          color: Colors.grey.shade700,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        '\$${product.price.toStringAsFixed(2)}',
                                                        style: const TextStyle(
                                                          color: Colors.blueAccent,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        product.description,
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(fontSize: 14),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                // Pagination controls
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: _currentPage > 1
                                            ? () => setState(() => _currentPage--)
                                            : null,
                                        icon: const Icon(Icons.chevron_left),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        'Page $_currentPage of $totalPages',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      IconButton(
                                        onPressed: _currentPage < totalPages
                                            ? () => setState(() => _currentPage++)
                                            : null,
                                        icon: const Icon(Icons.chevron_right),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
    );
  }
}
