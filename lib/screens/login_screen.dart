import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

// Layar 1: Login / Register (satu layar, mode di-toggle)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isRegisterMode = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }
    if (!value.contains('@')) {
      return 'Format email salah';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    FocusScope.of(context).unfocus();

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text;
    final password = _passwordController.text;

    bool success;
    if (_isRegisterMode) {
      success = await auth.register(email, password);
    } else {
      success = await auth.login(email, password);
    }

    if (!mounted) {
      return;
    }

    if (!success && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage!),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
    // Kalau success, tidak perlu navigate manual:
    // authStateChanges di AuthProvider akan memicu rebuild di main.dart
    // dan otomatis menampilkan HomeScreen.
  }

  void _toggleMode() {
    setState(() {
      _isRegisterMode = !_isRegisterMode;
    });
  }

  void _togglePassword() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    String title;
    String subtitle;
    String buttonText;
    String togglePrompt;
    String toggleAction;

    if (_isRegisterMode) {
      title = 'Buat Akun';
      subtitle = 'Daftar untuk mulai mengelola stok warung';
      buttonText = 'Daftar';
      togglePrompt = 'Sudah punya akun? ';
      toggleAction = 'Masuk';
    } else {
      title = 'Selamat Datang';
      subtitle = 'Masuk untuk mengelola inventaris warung';
      buttonText = 'Masuk';
      togglePrompt = 'Belum punya akun? ';
      toggleAction = 'Daftar';
    }

    IconData passwordIcon;
    if (_obscurePassword) {
      passwordIcon = Icons.visibility_off_outlined;
    } else {
      passwordIcon = Icons.visibility_outlined;
    }

    return Scaffold(
      body: Stack(
        children: [
          // ===== Background gradient di bagian atas =====
          Container(
            height: 320,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.primary,
                  scheme.primary.withValues(alpha: 0.75),
                ],
              ),
            ),
          ),

          // Dekorasi lingkaran transparan
          Positioned(
            top: -60,
            right: -40,
            child: _circleDecoration(180, scheme.onPrimary.withValues(alpha: 0.08)),
          ),
          Positioned(
            top: 120,
            left: -70,
            child: _circleDecoration(160, scheme.onPrimary.withValues(alpha: 0.06)),
          ),

          // ===== Konten =====
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ---- Brand ----
                      Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: scheme.onPrimary,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.storefront_rounded,
                              size: 38,
                              color: scheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Inventaris Warung',
                            style: textTheme.headlineSmall?.copyWith(
                              color: scheme.onPrimary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kelola stok & harga dalam satu aplikasi',
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onPrimary.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // ---- Card Form ----
                      Container(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 30,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Email
                              Text(
                                'Email',
                                style: textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                                validator: _validateEmail,
                                decoration: const InputDecoration(
                                  hintText: 'nama@email.com',
                                  prefixIcon: Icon(Icons.mail_outline_rounded),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Password
                              Text(
                                'Password',
                                style: textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.password],
                                validator: _validatePassword,
                                onFieldSubmitted: (_) {
                                  _handleSubmit();
                                },
                                decoration: InputDecoration(
                                  hintText: 'Minimal 6 karakter',
                                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                                  suffixIcon: IconButton(
                                    icon: Icon(passwordIcon),
                                    onPressed: _togglePassword,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Tombol submit
                              Consumer<AuthProvider>(
                                builder: (context, auth, _) {
                                  Widget buttonChild;
                                  VoidCallback? onPressed;

                                  if (auth.isLoading) {
                                    buttonChild = SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        color: scheme.onPrimary,
                                      ),
                                    );
                                    onPressed = null;
                                  } else {
                                    buttonChild = Text(buttonText);
                                    onPressed = _handleSubmit;
                                  }

                                  return FilledButton(
                                    onPressed: onPressed,
                                    child: buttonChild,
                                  );
                                },
                              ),
                              const SizedBox(height: 20),

                              // Toggle Login / Register
                              Center(
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      togglePrompt,
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _toggleMode,
                                      child: Text(
                                        toggleAction,
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: scheme.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      Text(
                        'UTS Pemrograman Multi Platform Lanjutan',
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleDecoration(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}