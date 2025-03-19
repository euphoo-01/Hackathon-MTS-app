import 'package:flutter/material.dart';
import 'package:healarm/controllers/auth_controller.dart';
import 'package:healarm/models/user_model.dart';
import 'package:healarm/theme/app_theme.dart';
import 'package:healarm/widgets/glass_card.dart';
import 'package:healarm/widgets/app_logo.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isLoading = false;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    setState(() {
      _isLoading = true;
    });

    try {
      _user = await authController.getCurrentUser();
      if (_user != null) {
        _usernameController.text = _user!.username;
        _emailController.text = _user!.email;
        _phoneController.text = _user!.phone ?? '';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки данных: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authController =
            Provider.of<AuthController>(context, listen: false);
        final updatedUser = UserModel(
          id: _user!.id,
          email: _emailController.text,
          username: _usernameController.text,
          phone: _phoneController.text,
          avatar: _user!.avatar,
          isVerified: _user!.isVerified,
        );

        await authController.updateProfile(updatedUser);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Профиль успешно обновлен')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка обновления профиля: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text(
              'Профиль',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontFamily: 'Baloo2',
                fontSize: 24,
              ),
            ),
            const Spacer(),
            const AppLogo(size: 24),
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Декоративные элементы фона
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor.withOpacity(0.05),
                ),
              ),
            ),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _user == null
                    ? const Center(child: Text('Пользователь не найден'))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),

                            // Форма редактирования
                            Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.cardLightColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 15,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Личные данные',
                                      style: AppTheme.headingStyle.copyWith(
                                        fontSize: 20,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _usernameController,
                                      style: TextStyle(
                                          color: AppTheme.textDarkColor),
                                      decoration: InputDecoration(
                                        labelText: 'Имя пользователя',
                                        labelStyle: TextStyle(
                                            color: AppTheme.textDarkColor),
                                        prefixIcon: Icon(Icons.person,
                                            color: AppTheme.textDarkColor),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppTheme.textDarkColor
                                                  .withOpacity(0.3)),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Пожалуйста, введите имя пользователя';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _emailController,
                                      style: TextStyle(
                                          color: AppTheme.textDarkColor),
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        labelStyle: TextStyle(
                                            color: AppTheme.textDarkColor),
                                        prefixIcon: Icon(Icons.email,
                                            color: AppTheme.textDarkColor),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppTheme.textDarkColor
                                                  .withOpacity(0.3)),
                                        ),
                                      ),
                                      readOnly: true,
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _phoneController,
                                      style: TextStyle(
                                          color: AppTheme.textDarkColor),
                                      decoration: InputDecoration(
                                        labelText: 'Телефон',
                                        labelStyle: TextStyle(
                                            color: AppTheme.textDarkColor),
                                        prefixIcon: Icon(Icons.phone,
                                            color: AppTheme.textDarkColor),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppTheme.textDarkColor
                                                  .withOpacity(0.3)),
                                        ),
                                      ),
                                      keyboardType: TextInputType.phone,
                                    ),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed:
                                            _isLoading ? null : _updateProfile,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppTheme.primaryColor,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: _isLoading
                                            ? const CircularProgressIndicator()
                                            : const Text(
                                                'Сохранить изменения',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Кнопка выхода
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final authController =
                                      Provider.of<AuthController>(context,
                                          listen: false);
                                  await authController.logout();
                                  if (context.mounted) {
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/login',
                                      (route) => false,
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Выйти',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
