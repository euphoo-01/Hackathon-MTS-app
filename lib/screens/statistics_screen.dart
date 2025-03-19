import 'package:flutter/material.dart';
import 'package:healarm/controllers/device_controller.dart';
import 'package:healarm/models/device_model.dart';
import 'package:healarm/theme/app_theme.dart';
import 'package:healarm/widgets/glass_card.dart';
import 'package:healarm/widgets/app_logo.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatefulWidget {
  final String? deviceId;

  const StatisticsScreen({Key? key, this.deviceId}) : super(key: key);

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<DeviceModel> _devices = [];
  DeviceModel? _selectedDevice;
  String _timeRange = 'day';
  bool _isLoading = false;
  List<DeviceReading> _filteredReadings = [];
  final DateFormat _dateFormat = DateFormat('dd.MM HH:mm');
  final DateFormat _shortDateFormat = DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _timeRange = 'day';
    _loadDevices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final deviceController =
          Provider.of<DeviceController>(context, listen: false);

      // Используем Future.microtask, чтобы избежать вызова notifyListeners во время построения
      Future.microtask(() async {
        final devices = await deviceController.getAllDevices();

        if (mounted) {
          setState(() {
            _devices = devices;
            if (widget.deviceId != null) {
              final deviceIndex =
                  _devices.indexWhere((device) => device.id == widget.deviceId);
              if (deviceIndex != -1) {
                _selectedDevice = _devices[deviceIndex];
              } else if (_devices.isNotEmpty) {
                _selectedDevice = _devices.first;
              }
            } else if (_devices.isNotEmpty) {
              _selectedDevice = _devices.first;
            }

            if (_selectedDevice != null) {
              _filterReadings();
            }

            _isLoading = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки устройств: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterReadings() {
    if (_selectedDevice?.readings == null ||
        _selectedDevice!.readings!.isEmpty) {
      _filteredReadings = [];
      return;
    }

    final now = DateTime.now();
    DateTime startDate;

    // Определяем начальную дату в зависимости от выбранного периода
    switch (_timeRange) {
      case 'day':
        startDate = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 1));
        break;
      case 'week':
        startDate = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 7));
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 30));
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 7));
    }

    // Фильтруем показания за выбранный период
    _filteredReadings = _selectedDevice!.readings!
        .where((reading) => reading.timestamp.isAfter(startDate))
        .toList();

    // Сортируем показания по времени
    _filteredReadings.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  void _onDeviceChanged(DeviceModel? device) {
    setState(() {
      _selectedDevice = device;
      if (_selectedDevice != null) {
        _filterReadings();
      } else {
        _filteredReadings = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Text(
              'Статистика',
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _devices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.device_unknown,
                          size: 64,
                          color: AppTheme.textLightColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Нет доступных устройств',
                          style: TextStyle(
                            color: AppTheme.textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Добавьте устройство для просмотра статистики',
                          style: TextStyle(
                            color: AppTheme.textLightColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // Выбор устройства
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: DropdownButtonFormField<DeviceModel>(
                          value: _selectedDevice,
                          decoration: InputDecoration(
                            labelText: 'Выберите устройство',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: _devices.map((device) {
                            return DropdownMenuItem(
                              value: device,
                              child: Text(device.name),
                            );
                          }).toList(),
                          onChanged: (device) {
                            setState(() {
                              _selectedDevice = device;
                              _filterReadings();
                            });
                          },
                        ),
                      ),

                      // Вкладки со статистикой
                      Expanded(
                        child: DefaultTabController(
                          length: 3,
                          child: Column(
                            children: [
                              Container(
                                color: Colors.white,
                                child: TabBar(
                                  labelColor: AppTheme.primaryColor,
                                  unselectedLabelColor: AppTheme.textLightColor,
                                  indicatorColor: AppTheme.primaryColor,
                                  tabs: const [
                                    Tab(text: 'Пульс'),
                                    Tab(text: 'Давление'),
                                    Tab(text: 'Положение'),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    _buildPulseTab(),
                                    _buildPressureTab(),
                                    _buildPositionTab(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildPulseTab() {
    if (_selectedDevice == null) {
      return const Center(child: Text('Выберите устройство'));
    }

    if (_filteredReadings.isEmpty) {
      return const Center(child: Text('Нет данных за выбранный период'));
    }

    final pulseReadings =
        _filteredReadings.where((r) => r.pulseRate != null).toList();

    if (pulseReadings.isEmpty) {
      return const Center(
          child: Text('Нет данных о пульсе за выбранный период'));
    }

    // Находим минимальное и максимальное значения для графика
    final minPulse = pulseReadings.map((r) => r.pulseRate!).reduce(
          (min, value) => min < value ? min : value,
        );
    final maxPulse = pulseReadings.map((r) => r.pulseRate!).reduce(
          (max, value) => max > value ? max : value,
        );

    // Средний пульс
    final avgPulse =
        pulseReadings.map((r) => r.pulseRate!).reduce((a, b) => a + b) /
            pulseReadings.length;

    // Аномальные показания
    final anomalies = pulseReadings.where((r) => r.isAnomaly).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCards(
            avgValue: avgPulse.toStringAsFixed(0),
            minValue: minPulse.toString(),
            maxValue: maxPulse.toString(),
            unit: 'уд/мин',
            anomalyCount: anomalies.length,
          ),
          const SizedBox(height: 20),
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'График пульса',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildChart(
                    pulseReadings.asMap().entries.map((entry) {
                      final reading = entry.value;
                      return FlSpot(
                        entry.key.toDouble(),
                        reading.pulseRate!.toDouble(),
                      );
                    }).toList(),
                    'Пульс',
                    AppTheme.primaryColor,
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(
                begin: 0.2,
                end: 0,
                duration: 500.ms,
                curve: Curves.easeOutQuad,
              ),
        ],
      ),
    );
  }

  Widget _buildPressureTab() {
    if (_selectedDevice == null) {
      return const Center(child: Text('Выберите устройство'));
    }

    if (_filteredReadings.isEmpty) {
      return const Center(child: Text('Нет данных за выбранный период'));
    }

    final pressureReadings = _filteredReadings
        .where((r) => r.systolicPressure != null && r.diastolicPressure != null)
        .toList();

    if (pressureReadings.isEmpty) {
      return const Center(
          child: Text('Нет данных о давлении за выбранный период'));
    }

    // Средние значения
    final avgSystolic = pressureReadings
            .map((r) => r.systolicPressure!)
            .reduce((a, b) => a + b) /
        pressureReadings.length;
    final avgDiastolic = pressureReadings
            .map((r) => r.diastolicPressure!)
            .reduce((a, b) => a + b) /
        pressureReadings.length;

    // Аномальные показания
    final anomalies = pressureReadings.where((r) => r.isAnomaly).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCards(
            avgValue:
                '${avgSystolic.toStringAsFixed(0)}/${avgDiastolic.toStringAsFixed(0)}',
            minValue: '-',
            maxValue: '-',
            unit: 'мм рт.ст.',
            anomalyCount: anomalies.length,
          ),
          const SizedBox(height: 20),
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'График артериального давления',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildChart(
                    pressureReadings.asMap().entries.map((entry) {
                      final reading = entry.value;
                      return FlSpot(
                        entry.key.toDouble(),
                        reading.systolicPressure!.toDouble(),
                      );
                    }).toList(),
                    'Систолическое',
                    Colors.red,
                  ),
                  const SizedBox(height: 8),
                  _buildChart(
                    pressureReadings.asMap().entries.map((entry) {
                      final reading = entry.value;
                      return FlSpot(
                        entry.key.toDouble(),
                        reading.diastolicPressure!.toDouble(),
                      );
                    }).toList(),
                    'Диастолическое',
                    Colors.blue,
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(
                begin: 0.2,
                end: 0,
                duration: 500.ms,
                curve: Curves.easeOutQuad,
              ),
        ],
      ),
    );
  }

  Widget _buildPositionTab() {
    if (_selectedDevice == null) {
      return const Center(child: Text('Выберите устройство'));
    }

    if (_filteredReadings.isEmpty) {
      return const Center(child: Text('Нет данных за выбранный период'));
    }

    final positionReadings =
        _filteredReadings.where((r) => r.bodyAngle != null).toList();

    if (positionReadings.isEmpty) {
      return const Center(
          child: Text('Нет данных о положении тела за выбранный период'));
    }

    return const Center(
      child: Text('График положения тела будет доступен в следующей версии'),
    );
  }

  Widget _buildStatCards({
    required String avgValue,
    required String minValue,
    required String maxValue,
    required String unit,
    required int anomalyCount,
  }) {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Среднее',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$avgValue $unit',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(
                begin: 0.1,
                end: 0,
                delay: 100.ms,
                duration: 300.ms,
                curve: Curves.easeOutQuad,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Мин/Макс',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$minValue - $maxValue',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(
                begin: 0.1,
                end: 0,
                delay: 200.ms,
                duration: 300.ms,
                curve: Curves.easeOutQuad,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Аномалии',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    anomalyCount.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: anomalyCount > 0 ? Colors.redAccent : null,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(
                begin: 0.1,
                end: 0,
                delay: 300.ms,
                duration: 300.ms,
                curve: Curves.easeOutQuad,
              ),
        ),
      ],
    );
  }

  Widget _buildChart(List<FlSpot> spots, String label, Color color) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: spots.length > 10 ? (spots.length / 5).toDouble() : 1,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 &&
                      value.toInt() < _filteredReadings.length) {
                    final date = _filteredReadings[value.toInt()].timestamp;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _timeRange == 'day'
                            ? _shortDateFormat.format(date)
                            : _dateFormat.format(date),
                        style: TextStyle(
                          color: AppTheme.textDarkColor,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: color,
              barWidth: 2,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: color.withOpacity(0.1),
              ),
            ),
          ],
          lineTouchData: LineTouchData(enabled: false),
        ),
      ),
    );
  }
}
