import 'package:flutter/material.dart';
import 'package:healarm/controllers/auth_controller.dart';
import 'package:healarm/controllers/device_controller.dart';
import 'package:healarm/models/device_model.dart';
import 'package:healarm/screens/add_device_screen.dart';
import 'package:healarm/screens/device_detail_screen.dart';
import 'package:healarm/screens/profile_screen.dart';
import 'package:healarm/theme/app_theme.dart';
import 'package:healarm/widgets/glass_card.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DeviceModel> _filteredDevices = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadDevices();

    _searchController.addListener(() {
      _filterDevices();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadDevices() {
    Future.microtask(() {
      final authController =
          Provider.of<AuthController>(context, listen: false);
      final deviceController =
          Provider.of<DeviceController>(context, listen: false);

      if (authController.currentUser != null) {
        deviceController.setCurrentUser(authController.currentUser!.id);
        deviceController.loadUserDevices(authController.currentUser!.id);
      }
    });
  }

  void _filterDevices() {
    final deviceController =
        Provider.of<DeviceController>(context, listen: false);
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredDevices = deviceController.devices;
        _isSearching = false;
      } else {
        _filteredDevices = deviceController.devices
            .where((device) => device.name.toLowerCase().contains(query))
            .toList();
        _isSearching = true;
      }
    });
  }

  Color _getStatusColor(DeviceStatus status) {
    switch (status) {
      case DeviceStatus.normal:
        return AppTheme.successColor;
      case DeviceStatus.warning:
        return AppTheme.warningColor;
      case DeviceStatus.critical:
        return AppTheme.errorColor;
      case DeviceStatus.offline:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authController = Provider.of<AuthController>(context);
    final deviceController = Provider.of<DeviceController>(context);

    // Если мы не фильтруем, используем все устройства
    if (!_isSearching) {
      _filteredDevices = deviceController.devices;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Декоративные элементы фона
            Positioned(
              top: 0,
              right: 0,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                  maxHeight: MediaQuery.of(context).size.width * 0.8,
                ),
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        blurRadius: 100,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6,
                  maxHeight: MediaQuery.of(context).size.width * 0.6,
                ),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.accentColor.withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentColor.withOpacity(0.2),
                        blurRadius: 100,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.3,
              left: MediaQuery.of(context).size.width * 0.3,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.4,
                  maxHeight: MediaQuery.of(context).size.width * 0.4,
                ),
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.successColor.withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.successColor.withOpacity(0.2),
                        blurRadius: 100,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Основное содержимое
            CustomScrollView(
              slivers: [
                // Шапка (AppBar)
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  floating: true,
                  title: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'He',
                          style: AppTheme.headingStyle.copyWith(
                            fontSize: 24,
                            color: AppTheme.primaryColor.withOpacity(0.6),
                            fontFamily: 'Baloo2',
                          ),
                        ),
                        TextSpan(
                          text: 'alarm',
                          style: AppTheme.headingStyle.copyWith(
                            fontSize: 24,
                            color: AppTheme.primaryColor,
                            fontFamily: 'Baloo2',
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    // Кнопка профиля
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 16),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            authController.currentUser?.name
                                    .substring(0, 1)
                                    .toUpperCase() ??
                                'U',
                            style: AppTheme.subheadingStyle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Контент
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Приветствие пользователя
                        Text(
                          'Привет, ${authController.currentUser?.name ?? 'пользователь'}!',
                          style: AppTheme.subheadingStyle,
                        ).animate().fade(duration: 400.ms),

                        const SizedBox(height: 8),

                        Text(
                          'Ваши устройства и их состояние',
                          style: AppTheme.captionStyle,
                        ).animate().fade(delay: 200.ms, duration: 400.ms),

                        const SizedBox(height: 24),

                        // Поиск устройств
                        GlassCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          hasShadow: true,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search,
                                color: AppTheme.textLightColor,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: const InputDecoration(
                                    hintText: 'Поиск устройств',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                      color: AppTheme.textLightColor,
                                    ),
                                  ),
                                ),
                              ),
                              if (_searchController.text.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                ),
                            ],
                          ),
                        ).animate().fade(delay: 300.ms, duration: 400.ms),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Список устройств в стиле Bento UI
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: deviceController.isLoading
                      ? SliverToBoxAdapter(
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : _filteredDevices.isEmpty
                          ? SliverToBoxAdapter(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 40),
                                  Text(
                                    _isSearching
                                        ? 'Устройства не найдены'
                                        : 'У вас пока нет устройств',
                                    style: AppTheme.bodyStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  if (!_isSearching)
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const AddDeviceScreen(),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.add),
                                      label: const Text('Добавить устройство'),
                                    ),
                                ],
                              ),
                            )
                          : SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent:
                                    MediaQuery.of(context).size.width < 600
                                        ? MediaQuery.of(context).size.width - 32
                                        : 200,
                                childAspectRatio: 1,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                mainAxisExtent: 200,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final device = _filteredDevices[index];
                                  final status = device.status;

                                  return GestureDetector(
                                    onTap: () {
                                      deviceController.setCurrentDevice(device);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DeviceDetailScreen(
                                            deviceId: device.id,
                                          ),
                                        ),
                                      );
                                    },
                                    child: BentoGridItem(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                flex: 4,
                                                child: Text(
                                                  device.name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color:
                                                      _getStatusColor(status),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          const Divider(
                                            color: Colors.white30,
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.favorite_border,
                                                color: device.settings
                                                        .isPulseTrackingEnabled
                                                    ? AppTheme.primaryColor
                                                    : Colors.grey,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  device.settings
                                                          .isPulseTrackingEnabled
                                                      ? 'Пульс активен'
                                                      : 'Пульс откл.',
                                                  style: TextStyle(
                                                    color: device.settings
                                                            .isPulseTrackingEnabled
                                                        ? AppTheme.textDarkColor
                                                        : Colors.grey,
                                                    fontSize: 14,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.speed_outlined,
                                                color: device.settings
                                                        .isPressureTrackingEnabled
                                                    ? AppTheme.primaryColor
                                                    : Colors.grey,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  device.settings
                                                          .isPressureTrackingEnabled
                                                      ? 'Давление активно'
                                                      : 'Давление откл.',
                                                  style: TextStyle(
                                                    color: device.settings
                                                            .isPressureTrackingEnabled
                                                        ? AppTheme.textDarkColor
                                                        : Colors.grey,
                                                    fontSize: 14,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.screen_rotation_outlined,
                                                color: device.settings
                                                        .isPositionTrackingEnabled
                                                    ? AppTheme.primaryColor
                                                    : Colors.grey,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  device.settings
                                                          .isPositionTrackingEnabled
                                                      ? 'Положение активно'
                                                      : 'Положение откл.',
                                                  style: TextStyle(
                                                    color: device.settings
                                                            .isPositionTrackingEnabled
                                                        ? AppTheme.textDarkColor
                                                        : Colors.grey,
                                                    fontSize: 14,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ).animate().fadeIn(
                                          delay: Duration(
                                              milliseconds: 100 * index),
                                          duration:
                                              const Duration(milliseconds: 400),
                                        ),
                                  );
                                },
                                childCount: _filteredDevices.length,
                              ),
                            ),
                ),

                // Пространство внизу для корректного отображения FAB
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: deviceController.devices.isEmpty && !_isSearching
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddDeviceScreen(),
                  ),
                );
              },
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add),
            ),
    );
  }
}

class BentoGridItem extends StatelessWidget {
  final Widget child;
  final bool isPrimary;
  final LinearGradient? gradient;
  final double? height;

  const BentoGridItem({
    super.key,
    required this.child,
    this.isPrimary = false,
    this.gradient,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          color: AppTheme.textDarkColor,
          fontSize: 14,
        ),
        child: child,
      ),
    );
  }
}
