
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

// P04 - AuthProvider
// Tanggung jawab: register, login, logout, dan memantau auth state
// lewat Stream<User?> (authStateChanges).
class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // subscription ke Stream<User?> dari Firebase Auth
  StreamSubscription<User?>? _authSubscription;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Stream<User?> diekspos juga supaya bisa dipakai StreamBuilder kalau perlu
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  AuthProvider() {
    _listenAuthState();
  }

  // Auth state listener (P01 Stream + P04)
  // Setiap kali status login berubah (login / logout / token expired),
  // Firebase memancarkan event ke stream ini.
  void _listenAuthState() {
    _authSubscription?.cancel();

    _authSubscription = _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> register(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _user = cred.user;
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _pesanError(e.code);
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _user = cred.user;
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _pesanError(e.code);
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    // _user otomatis jadi null lewat authStateChanges listener
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _pesanError(String code) {
    if (code == 'user-not-found' ||
        code == 'invalid-credential' ||
        code == 'wrong-password') {
      return 'Email atau password salah';
    } else if (code == 'email-already-in-use') {
      return 'Email sudah digunakan';
    } else if (code == 'weak-password') {
      return 'Password minimal 6 karakter';
    } else if (code == 'invalid-email') {
      return 'Format email salah';
    } else if (code == 'user-disabled') {
      return 'Akun telah dinonaktifkan';
    } else if (code == 'configuration-not-found' ||
        code == 'operation-not-allowed') {
      return 'Auth belum aktif di console: enable Email/Password dulu';
    } else if (code == 'network-request-failed') {
      return 'Tidak ada koneksi internet';
    } else if (code == 'too-many-requests') {
      return 'Terlalu banyak percobaan, coba lagi nanti';
    }
    return 'Gagal ($code)';
  }

  // Wajib: dispose subscription supaya tidak memory leak
  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
