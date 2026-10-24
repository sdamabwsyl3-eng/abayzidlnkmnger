class DeviceModel {
  final String id;
  final String name;
  final String? model;
  final String setupMode; // fresh_wipe | adopt_existing
  final String status; // linked | setting_up | offline
  final DateTime createdAt;

  DeviceModel({
    required this.id,
    required this.name,
    this.model,
    required this.setupMode,
    required this.status,
    required this.createdAt,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> j) {
    return DeviceModel(
      id: j['id'] as String,
      name: j['name'] as String,
      model: j['model'] as String?,
      setupMode: j['setup_mode'] as String? ?? 'fresh_wipe',
      status: j['status'] as String? ?? 'setting_up',
      createdAt: DateTime.parse(j['created_at'] as String).toLocal(),
    );
  }
}
