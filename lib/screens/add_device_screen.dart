import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:healarm/controllers/auth_controller.dart';
import 'package:healarm/controllers/device_controller.dart';
import 'package:healarm/theme/app_theme.dart';
import 'package:healarm/widgets/glass_card.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _deviceNameController = TextEditingController();
  final _deviceCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _deviceNameController.dispose();
    _deviceCodeController.dispose();
    super.dispose();
  }

  void _addDevice() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authController =
          Provider.of<AuthController>(context, listen: false);
      final deviceController =
          Provider.of<DeviceController>(context, listen: false);

      // Используем правильный метод из контроллера
      deviceController
          .addDevice(_deviceNameController.text, _deviceCodeController.text)
          .then((success) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Устройство успешно добавлено'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Ошибка добавления устройства: ${deviceController.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceController = Provider.of<DeviceController>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLightColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Добавление устройства',
          style: AppTheme.subheadingStyle.copyWith(fontSize: 20),
        ),
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
      ),
      body: Stack(
        children: [
          // Декоративные элементы фона
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withOpacity(0.1),
              ),
            ),
          ),

          // Основное содержимое
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Иллюстрация
                Icon(
                  Icons.device_hub,
                  size: 180,
                  color: AppTheme.primaryColor,
                ).animate().fade(duration: 600.ms),

                const SizedBox(height: 24),

                Text(
                  'Подключение NB-IoT устройства',
                  style: AppTheme.subheadingStyle,
                  textAlign: TextAlign.center,
                ).animate().fade(delay: 200.ms, duration: 400.ms),

                const SizedBox(height: 8),

                Text(
                  'Введите информацию о вашем устройстве',
                  style: AppTheme.captionStyle,
                  textAlign: TextAlign.center,
                ).animate().fade(delay: 300.ms, duration: 400.ms),

                const SizedBox(height: 32),

                // Форма добавления устройства
                GlassCard(
                  hasShadow: true,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Название устройства
                        TextFormField(
                          controller: _deviceNameController,
                          decoration: const InputDecoration(
                            labelText: 'Название устройства',
                            prefixIcon: Icon(Icons.device_hub_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Пожалуйста, введите название устройства';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Код устройства
                        TextFormField(
                          controller: _deviceCodeController,
                          decoration: const InputDecoration(
                            labelText: 'Код устройства',
                            prefixIcon: Icon(Icons.qr_code),
                            helperText:
                                'Код указан в документации к устройству',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Пожалуйста, введите код устройства';
                            }
                            if (value.length < 6) {
                              return 'Код устройства должен содержать не менее 6 символов';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Информация о устройстве
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Устройство должно быть активировано и подключено к сети для корректной работы. '
                                  'Код устройства можно найти в документации или на корпусе устройства.',
                                  style: AppTheme.captionStyle.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Сообщение об ошибке
                        if (deviceController.error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              deviceController.error!,
                              style: const TextStyle(
                                color: AppTheme.errorColor,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        // Кнопка добавления
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _addDevice,
                          icon: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Icon(Icons.add),
                          label: const Text('Добавить устройство'),
                        ),
                      ],
                    ),
                  ),
                ).animate().fade(delay: 400.ms, duration: 600.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
