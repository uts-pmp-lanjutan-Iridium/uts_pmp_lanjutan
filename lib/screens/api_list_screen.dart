import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/api_provider.dart';
import '../providers/item_provider.dart';
import 'api_detail_screen.dart';

// Layar 3: List API (Cek Harga Pasar dari DummyJSON menggunakan Dio)
class ApiListScreen extends StatelessWidget {
  const ApiListScreen({super.key});

  String _formatRupiah(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return 'Rp $buffer';
  }

  Future<void> _retryFetch(BuildContext context) async {
    final apiProvider = context.read<ApiProvider>();
    await apiProvider.fetchProducts();

    if (context.mounted && apiProvider.state == ViewState.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(apiProvider.errorMessage),
          backgroundColor: const Color(0xFFB91C1C),
          action: SnackBarAction(
            label: 'COBA LAGI',
            textColor: Colors.white,
            onPressed: () => apiProvider.fetchProducts(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Referensi Harga Pasar',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            Text(
              'Sumber data publik DummyJSON (Groceries)',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 21),
            tooltip: 'Muat Ulang Data Pasar',
            onPressed: () => _retryFetch(context),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      body: Consumer<ApiProvider>(
        builder: (context, apiProv, _) {
          // 1. STATE: LOADING (Tampilkan Loading Spinner)
          if (apiProv.state == ViewState.loading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                  SizedBox(height: 16),
                  Text('Mengambil referensi harga pasar...'),
                ],
              ),
            );
          }

          // 2. STATE: ERROR (Tampilkan pesan error & tombol Retry + Snackbar)
          if (apiProv.state == ViewState.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: scheme.errorContainer.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.wifi_off_rounded,
                          size: 36,
                          color: scheme.error,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Gagal Memuat Harga Pasar',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        apiProv.errorMessage,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(160, 44),
                        ),
                        onPressed: () => _retryFetch(context),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // 3. STATE: EMPTY (Tampilkan Empty State)
          if (apiProv.state == ViewState.empty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 48,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  const Text('Data produk pasar tidak tersedia.'),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _retryFetch(context),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Muat Ulang'),
                  ),
                ],
              ),
            );
          }

          // 4. STATE: LOADED (Tampilkan Daftar Produk dari DummyJSON)
          return RefreshIndicator(
            onRefresh: () => _retryFetch(context),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: apiProv.products.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final product = apiProv.products[index];

                    return Material(
                      color: scheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: scheme.outlineVariant.withValues(alpha: 0.55),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ApiDetailScreen(product: product),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  color: const Color(0xFFF3F4F6),
                                  child: product.thumbnail.isNotEmpty
                                      ? Image.network(
                                          product.thumbnail,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) => Icon(
                                            Icons.shopping_bag_outlined,
                                            color: scheme.onSurfaceVariant,
                                          ),
                                        )
                                      : Icon(
                                          Icons.shopping_bag_outlined,
                                          color: scheme.onSurfaceVariant,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.title,
                                      style: textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Text(
                                          _formatRupiah(product.priceIdr),
                                          style: TextStyle(
                                            color: scheme.primary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13.5,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '(\$${product.priceUsd.toStringAsFixed(2)})',
                                          style: textTheme.bodySmall?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: scheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
