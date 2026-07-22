import 'package:flutter/material.dart';
import '../models/product.dart';
import '../controllers/product_controller.dart';
import 'product_form_screen.dart';

class ProductScreen extends StatefulWidget {
  final String token;
  const ProductScreen({super.key, required this.token});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  bool isLoading = true;
  final ProductController _productController = ProductController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredProducts = products;
      } else {
        filteredProducts = products.where((p) => 
          p.name.toLowerCase().contains(query) || 
          p.productCode.toLowerCase().contains(query)
        ).toList();
      }
    });
  }

  Future<void> _fetchProducts() async {
    try {
      final fetchedProducts = await _productController.fetchActiveProducts(widget.token);
      if (mounted) {
        setState(() {
          products = fetchedProducts;
          filteredProducts = fetchedProducts;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductFormScreen(token: widget.token),
            ),
          );
          if (result == true) {
            _fetchProducts(); // Refresh list after create
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Products',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredProducts.isEmpty
                    ? const Center(child: Text('No products found.'))
                    : ListView.builder(
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: InkWell(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductFormScreen(
                                      token: widget.token,
                                      product: product,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  _fetchProducts(); // Refresh list after update
                                }
                              },
                              child: ListTile(
                                title: Text(product.name.isNotEmpty ? product.name : 'Unknown Product'),
                                subtitle: Text(
                                  'Code: ${product.productCode.isNotEmpty ? product.productCode : 'N/A'}\n'
                                  'Price: \$${product.price.toStringAsFixed(2)}',
                                ),
                                isThreeLine: true,
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
