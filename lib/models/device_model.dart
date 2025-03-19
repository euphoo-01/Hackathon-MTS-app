import 'package:flutter/foundation.dart';

enum DeviceStatus {
  normal,
  warning,
  critical,
  offline,
}

class DeviceModel {
  final String id;
  final String userId;
  final String name;
  final String deviceCode;
  final DateTime createdAt;
  final DateTime? lastActive;
  final DeviceSettings settings;
  final DeviceStatus status;
  final List<DeviceReading> readings;
  final DeviceReading? lastReading;

  DeviceModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.deviceCode,
    required this.createdAt,
    this.lastActive,
    required this.settings,
    this.status = DeviceStatus.normal,
    required this.readings,
    this.lastReading,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      deviceCode: json['deviceCode'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'] as String)
          : null,
      settings:
          DeviceSettings.fromJson(json['settings'] as Map<String, dynamic>),
      status: DeviceStatus.values.firstWhere(
        (e) => e.toString() == 'DeviceStatus.${json['status']}',
        orElse: () => DeviceStatus.offline,
      ),
      readings: (json['readings'] as List<dynamic>?)
              ?.map((e) => DeviceReading.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      lastReading: json['lastReading'] != null
          ? DeviceReading.fromJson(json['lastReading'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'deviceCode': deviceCode,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive?.toIso8601String(),
      'settings': settings.toJson(),
      'status': status.toString().split('.').last,
      'readings': readings.map((e) => e.toJson()).toList(),
      'lastReading': lastReading?.toJson(),
    };
  }

  DeviceModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? deviceCode,
    DateTime? createdAt,
    DateTime? lastActive,
    DeviceSettings? settings,
    DeviceStatus? status,
    List<DeviceReading>? readings,
    DeviceReading? lastReading,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      deviceCode: deviceCode ?? this.deviceCode,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      settings: settings ?? this.settings,
      status: status ?? this.status,
      readings: readings ?? this.readings,
      lastReading: lastReading ?? this.lastReading,
    );
  }
}

class DeviceSettings {
  final bool isPulseTrackingEnabled;
  final bool isPressureTrackingEnabled;
  final bool isPositionTrackingEnabled;
  final int measurementIntervalMinutes;

  DeviceSettings({
    this.isPulseTrackingEnabled = true,
    this.isPressureTrackingEnabled = true,
    this.isPositionTrackingEnabled = true,
    this.measurementIntervalMinutes = 30,
  });

  factory DeviceSettings.fromJson(Map<String, dynamic> json) {
    return DeviceSettings(
      isPulseTrackingEnabled: json['isPulseTrackingEnabled'] ?? true,
      isPressureTrackingEnabled: json['isPressureTrackingEnabled'] ?? true,
      isPositionTrackingEnabled: json['isPositionTrackingEnabled'] ?? true,
      measurementIntervalMinutes: json['measurementIntervalMinutes'] ?? 30,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isPulseTrackingEnabled': isPulseTrackingEnabled,
      'isPressureTrackingEnabled': isPressureTrackingEnabled,
      'isPositionTrackingEnabled': isPositionTrackingEnabled,
      'measurementIntervalMinutes': measurementIntervalMinutes,
    };
  }

  DeviceSettings copyWith({
    bool? isPulseTrackingEnabled,
    bool? isPressureTrackingEnabled,
    bool? isPositionTrackingEnabled,
    int? measurementIntervalMinutes,
  }) {
    return DeviceSettings(
      isPulseTrackingEnabled:
          isPulseTrackingEnabled ?? this.isPulseTrackingEnabled,
      isPressureTrackingEnabled:
          isPressureTrackingEnabled ?? this.isPressureTrackingEnabled,
      isPositionTrackingEnabled:
          isPositionTrackingEnabled ?? this.isPositionTrackingEnabled,
      measurementIntervalMinutes:
          measurementIntervalMinutes ?? this.measurementIntervalMinutes,
    );
  }
}

class DeviceReading {
  final String id;
  final String deviceId;
  final DateTime timestamp;
  final int? pulseRate;
  final int? systolicPressure;
  final int? diastolicPressure;
  final int? bodyAngle;
  final bool isAnomaly;

  DeviceReading({
    required this.id,
    required this.deviceId,
    required this.timestamp,
    this.pulseRate,
    this.systolicPressure,
    this.diastolicPressure,
    this.bodyAngle,
    this.isAnomaly = false,
  });

  factory DeviceReading.fromJson(Map<String, dynamic> json) {
    return DeviceReading(
      id: json['id'] ?? '',
      deviceId: json['deviceId'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      pulseRate: json['pulseRate'],
      systolicPressure: json['systolicPressure'],
      diastolicPressure: json['diastolicPressure'],
      bodyAngle: json['bodyAngle'],
      isAnomaly: json['isAnomaly'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceId': deviceId,
      'timestamp': timestamp.toIso8601String(),
      'pulseRate': pulseRate,
      'systolicPressure': systolicPressure,
      'diastolicPressure': diastolicPressure,
      'bodyAngle': bodyAngle,
      'isAnomaly': isAnomaly,
    };
  }
}
