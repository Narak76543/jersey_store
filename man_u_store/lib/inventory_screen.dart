import 'dart:ui';
import 'package:flutter/material.dart';
import 'api.dart';
import 'model.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late final ApiService api;
  bool loading = true;
  List<Product> products = [];
  String? errorMsg;

  @override
  void initState() {
    super.initState();

    api = ApiService(baseUrl: 'http://192.168.0.198:8000');
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      errorMsg = null;
    });
    try {
      final data = await api.fetchProducts();
      setState(() => products = data);
    } catch (e) {
      setState(() => errorMsg = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _confirmDelete(Product p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1A1F2E).withOpacity(0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Confirm Deletion'),
          content: Text('Remove ${p.name}?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDF2531)),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );

    if (ok == true) {
      try {
        await api.deleteProduct(int.parse(p.id!));
        _load();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _openEdit(Product p) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => _EditJerseyDialog(product: p, onUpdated: _load),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F1A),
        elevation: 0,
        title: const Text('Man U Store Inventory', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFDF2531)))
          : RefreshIndicator(
        onRefresh: _load,
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.70, // Adjust to fit vertical content
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final p = products[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Section
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            child: Image.network(p.imageUrl, fit: BoxFit.contain),
                          ),
                        ),
                        Positioned(
                          top: 4, right: 4,
                          child: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Color(0xFFDF2531), size: 18),
                            onPressed: () => _confirmDelete(p),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Text Section
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(p.category, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('\$${p.price}', style: const TextStyle(color: Color(0xFFDF2531), fontWeight: FontWeight.bold)),
                            GestureDetector(
                              onTap: () => _openEdit(p),
                              child: const Icon(Icons.edit_note, color: Colors.white70, size: 20),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EditJerseyDialog extends StatelessWidget {
  final Product product;
  final VoidCallback onUpdated;
  const _EditJerseyDialog({required this.product, required this.onUpdated});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F2E).withOpacity(0.8),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white12),
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Edit Jersey', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Image.network(product.imageUrl, height: 100),
                const SizedBox(height: 20),
                _buildSimpleField('Name', product.name),
                _buildSimpleField('Price', product.price.toString()),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDF2531)),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Save Changes'),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: TextEditingController(text: value),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.black26,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}