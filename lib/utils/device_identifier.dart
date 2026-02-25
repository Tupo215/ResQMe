import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Generates and persists a UUID v4 as the device identifier.
/// On first run it creates one and saves it; on subsequent runs it reuses the saved one.
class DeviceIdentifier {
  static const _key = 'device_identifier';

  static Future<String> get() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString(_key);
    if (id == null || id.isEmpty) {
      id = _generateUuidV4();
      await prefs.setString(_key, id);
    }
    return id;
  }

  static String _generateUuidV4() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    // Set version 4
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    // Set variant bits
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    String hex(int n) => n.toRadixString(16).padLeft(2, '0');
    return '${hex(bytes[0])}${hex(bytes[1])}${hex(bytes[2])}${hex(bytes[3])}'
        '-${hex(bytes[4])}${hex(bytes[5])}'
        '-${hex(bytes[6])}${hex(bytes[7])}'
        '-${hex(bytes[8])}${hex(bytes[9])}'
        '-${hex(bytes[10])}${hex(bytes[11])}${hex(bytes[12])}${hex(bytes[13])}${hex(bytes[14])}${hex(bytes[15])}';
  }
}
