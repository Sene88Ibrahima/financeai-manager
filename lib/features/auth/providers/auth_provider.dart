import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _biometricEnabled = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get biometricEnabled => _biometricEnabled;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _user = _supabase.auth.currentUser;
    await _loadBiometricPreference();
    notifyListeners();
  }

  Future<void> _loadBiometricPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
  }

  Future<void> _saveBiometricPreference(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', enabled);
    _biometricEnabled = enabled;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String nom,
    required String prenom,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'nom': nom,
          'prenom': prenom,
        },
      );

      if (response.user != null) {
        _user = response.user;
        return true;
      }
      return false;
    } catch (e) {
      _setError('Erreur lors de l\'inscription: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _user = response.user;
        return true;
      }
      return false;
    } catch (e) {
      _setError('Erreur lors de la connexion: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithBiometric() async {
    try {
      if (!_biometricEnabled) return false;

      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) return false;

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Utilisez votre empreinte digitale pour vous connecter',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        // Récupérer les identifiants stockés de manière sécurisée
        final prefs = await SharedPreferences.getInstance();
        final storedEmail = prefs.getString('stored_email');
        final storedPasswordHash = prefs.getString('stored_password_hash');

        if (storedEmail != null && storedPasswordHash != null) {
          // Note: En production, utilisez un stockage plus sécurisé comme flutter_secure_storage
          return await signIn(email: storedEmail, password: storedPasswordHash);
        }
      }
      return false;
    } catch (e) {
      _setError('Erreur d\'authentification biométrique: ${e.toString()}');
      return false;
    }
  }

  Future<void> enableBiometric(String email, String password) async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) {
        _setError('L\'authentification biométrique n\'est pas disponible');
        return;
      }

      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        _setError('Aucune méthode biométrique configurée');
        return;
      }

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Configurez l\'authentification biométrique',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        // Stocker les identifiants de manière sécurisée
        final prefs = await SharedPreferences.getInstance();
        final passwordHash = sha256.convert(utf8.encode(password)).toString();
        
        await prefs.setString('stored_email', email);
        await prefs.setString('stored_password_hash', passwordHash);
        await _saveBiometricPreference(true);
        
        notifyListeners();
      }
    } catch (e) {
      _setError('Erreur lors de la configuration biométrique: ${e.toString()}');
    }
  }

  Future<void> disableBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('stored_email');
    await prefs.remove('stored_password_hash');
    await _saveBiometricPreference(false);
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de la déconnexion: ${e.toString()}');
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      _setError('Erreur lors de la réinitialisation: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _setError(null);
  }
}
