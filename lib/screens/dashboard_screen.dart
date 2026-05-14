import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import '../widgets/progress_snackbar.dart';
import 'add_product_screen.dart';
import 'submit_task_screen.dart';
import 'login_screen.dart';
import 'product_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;

  static const _grad = [Color(0xFF7C3AED), Color(0xFF3B82F6)];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final p = await ApiService.getProducts();
      if (!mounted) return;
      setState(() {
        _products = p;
        _isLoading = false;
      });
      print('Products loaded: ${p.length} items');
      for (var prod in p) {
        print('Product: ${prod.name}, price: ${prod.price}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _softDelete(int index, int? productId) async {
    // Hapus dari UI dulu
    final removedProduct = _products[index];
    final removedId = productId;
    setState(() => _products.removeAt(index));

    // Tampilkan SnackBar dengan animasi progress 3 detik
    await showProgressSnackBar(
      context,
      message: '"${removedProduct.name}" dihapus dari tampilan',
      duration: const Duration(seconds: 3),
      onDismissed: () {
        print('SnackBar dismissed after 3 seconds');
      },
    );

    // Jika ada ID, panggil API delete (soft delete di server)
    if (removedId != null) {
      try {
        await ApiService.deleteProduct(removedId);
        print('Product $removedId deleted from server');
      } catch (e) {
        print('Failed to delete from server: $e');
        // Restore jika gagal (tapi karena sudah lewat 3 detik, kita tampilkan error snackbar baru)
        if (mounted) {
          setState(() => _products.insert(index, removedProduct));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menghapus dari server'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  String _fmt(int p) {
    final s = p.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    return 'Rp $b';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: _drawer(),
      appBar: AppBar(
        title: const Text(
          'Draft Produk',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E1E2E),
        surfaceTintColor: Colors.white,
      ),
      body: _body(),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: _grad,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _grad[0].withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () async {
            final r = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (_) => const AddProductScreen()),
            );
            if (r == true) _fetch();
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          hoverElevation: 0,
          focusElevation: 0,
          highlightElevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _drawer() {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: _grad,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.storefront_rounded, color: Colors.white, size: 32),
                  SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PBM Praktikum',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Manajemen Produk',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _dItem(
              Icons.dashboard_rounded,
              'Dashboard',
              () => Navigator.pop(context),
            ),
            _dItem(Icons.upload_file_rounded, 'Submit Tugas Final', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubmitTaskScreen()),
              );
            }),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: Colors.grey.shade200),
            ),
            _dItem(
              Icons.logout_rounded,
              'Keluar',
              _logout,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _dItem(IconData ic, String l, VoidCallback onTap, {Color? color}) {
    final c = color ?? const Color(0xFF1E1E2E);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(ic, color: c, size: 22),
        title: Text(
          l,
          style: TextStyle(color: c, fontWeight: FontWeight.w500, fontSize: 14),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }

  Widget _body() {
    if (_isLoading)
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
      );
    if (_error != null)
      return _empty(
        Icons.error_outline_rounded,
        'Terjadi Kesalahan',
        _error!,
        act: 'Coba Lagi',
        onAct: _fetch,
      );
    if (_products.isEmpty)
      return _empty(
        Icons.inventory_2_outlined,
        'Belum Ada Produk',
        'Tambahkan draft produk pertama Anda\ndengan menekan tombol + di bawah.',
      );
    return RefreshIndicator(
      color: const Color(0xFF7C3AED),
      onRefresh: _fetch,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        itemCount: _products.length,
        itemBuilder: (_, i) => _card(_products[i], i),
      ),
    );
  }

  Widget _empty(
    IconData ic,
    String t,
    String s, {
    String? act,
    VoidCallback? onAct,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F0FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(ic, size: 40, color: const Color(0xFF7C3AED)),
            ),
            const SizedBox(height: 24),
            Text(
              t,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E1E2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              s,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
            if (act != null) ...[
              const SizedBox(height: 24),
              TextButton(
                onPressed: onAct,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF7C3AED),
                ),
                child: Text(act),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _card(Product p, int i) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _grad[0].withValues(alpha: 0.12),
                      _grad[1].withValues(alpha: 0.12),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Color(0xFF7C3AED),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E1E2E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F0FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _fmt(p.price),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _delDlg(i, p.id),
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
                splashRadius: 20,
                tooltip: 'Hapus',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _delDlg(int index, int? productId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Produk?',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Text(
          '"${_products[index].name}" akan dihapus dari tampilan.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade500)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _softDelete(index, productId);
            },
            child: const Text(
              'Hapus',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
