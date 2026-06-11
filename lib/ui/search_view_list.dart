import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/product.dart';
import 'search_view_detail.dart';

class SearchViewList extends StatefulWidget {
  const SearchViewList({super.key});

  @override
  State<SearchViewList> createState() => _SearchViewListState();
}

class _SearchViewListState extends State<SearchViewList> {
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  List<Product> _displayedProducts = [];
  
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final int _itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Check if we are close to the bottom of the list
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50) {
      _fetchMore();
    }
  }

  Future<void> _fetchMore() async {
    // If already loading more or we've displayed all items, do nothing
    if (_isLoadingMore || _displayedProducts.length >= _filteredProducts.length) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate network delay to show the loading indicator
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;

    setState(() {
      int nextIndex = _displayedProducts.length;
      int endIndex = min(nextIndex + _itemsPerPage, _filteredProducts.length);
      _displayedProducts.addAll(_filteredProducts.sublist(nextIndex, endIndex));
      _isLoadingMore = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        return product.title.toLowerCase().contains(query) ||
            product.brand.toLowerCase().contains(query) ||
            product.description.toLowerCase().contains(query);
      }).toList();
      
      // Reset displayed products on search
      int endIndex = min(_itemsPerPage, _filteredProducts.length);
      _displayedProducts = _filteredProducts.sublist(0, endIndex);
    });
    
    // Jump to top of list when searching
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  Future<void> _loadProducts() async {
    try {
      final String jsonString = await rootBundle.loadString('lib/json_data/search.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final productResponse = ProductResponse.fromJson(jsonData);
      setState(() {
        _allProducts = productResponse.products;
        _filteredProducts = _allProducts;
        
        // Initial load of 5 items
        int endIndex = min(_itemsPerPage, _filteredProducts.length);
        _displayedProducts = _filteredProducts.sublist(0, endIndex);
        
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Products'),
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
                          hintText: 'Search electronics, apple, oppo...',
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
                          : ListView.builder(
                              controller: _scrollController,
                              // Add 1 to itemCount if we are loading more to show the indicator
                              itemCount: _displayedProducts.length + (_isLoadingMore ? 1 : 0),
                              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                              itemBuilder: (context, index) {
                                // Show loading indicator at the bottom
                                if (index == _displayedProducts.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24.0),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                final product = _displayedProducts[index];
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
                                          builder: (context) => SearchViewDetail(product: product),
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
                  ],
                ),
    );
  }
}
