import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healarm/models/user_model.dart';
import 'package:healarm/services/api_service.dart';

class AuthController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthController() {
    _loadCurrentUser();
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  // Загрузка текущего пользователя из SharedPreferences
  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('currentUser');

      if (userJson != null) {
        _currentUser = UserModel.fromJson(jsonDecode(userJson));
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      print('Ошибка загрузки пользователя: $e');
    }
  }

  // Сохранение данных пользователя в SharedPreferences
  Future<void> _saveUserData() async {
    try {
      if (_currentUser != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'currentUser', jsonEncode(_currentUser!.toJson()));
      }
    } catch (e) {
      _error = e.toString();
      print('Ошибка сохранения пользователя: $e');
    }
  }

  // Очистка ошибки
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Вход в аккаунт
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Для тестирования
      await Future.delayed(const Duration(seconds: 1));
      _currentUser = UserModel(
        id: '1',
        email: email,
        username: 'Тестовый Пользователь',
      );

      // Сохраняем данные в SharedPreferences
      await _saveUserData();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Регистрация нового пользователя
  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Для тестирования
      await Future.delayed(const Duration(seconds: 1));
      _currentUser = UserModel(
        id: '1',
        email: email,
        username: username,
      );

      // Сохраняем данные в SharedPreferences
      await _saveUserData();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Выход из аккаунта
  Future<bool> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Удаляем данные из SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('currentUser');

      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Получение текущего пользователя
  Future<UserModel?> getCurrentUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }

    try {
      await _loadCurrentUser();
      return _currentUser;
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  // Обновление профиля пользователя
  Future<bool> updateProfile(UserModel user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Для тестирования
      await Future.delayed(const Duration(seconds: 1));
      _currentUser = user;

      // Сохраняем данные в SharedPreferences
      await _saveUserData();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Изменение пароля
  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Для тестирования
      await Future.delayed(const Duration(seconds: 1));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
