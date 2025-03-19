import 'package:flutter/foundation.dart';

class UserModel {
  final String id;
  final String email;
  final String username;
  final String? phone;
  final String? avatar;
  final bool isVerified;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.phone,
    this.avatar,
    this.isVerified = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      phone: json['phone'],
      avatar: json['avatar'],
      isVerified: json['is_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'phone': phone,
      'avatar': avatar,
      'is_verified': isVerified,
    };
  }

  // Геттер для совместимости с другими частями кода
  String get name => username;
} 