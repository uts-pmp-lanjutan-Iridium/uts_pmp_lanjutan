import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

// Layar 2: Home CRUD (placeholder dulu - CRUD transactions menyusul)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.logout();
    // setelah signOut, authStateChanges mengirim null -> main.dart
    // otomatis kembali ke LoginScreen
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final email = auth.user?.email ?? '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventaris Warung'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              _handleLogout(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text('Login berhasil'),
            const SizedBox(height: 4),
            Text(
              email,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'UID: ${auth.user?.uid ?? '-'}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            const Text('TODO: CRUD transactions (Firestore) di sini'),
          ],
        ),
      ),
    );
  }
}
