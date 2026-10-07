import 'package:shared_preferences/shared_preferences.dart';
import '../domain/services.dart';

class PreferencesSettingsStore implements SettingsStore {
  PreferencesSettingsStore(this.preferences);
  final SharedPreferences preferences;
  @override
  int? getInt(String key) => preferences.getInt(key);
  @override
  double? getDouble(String key) => preferences.getDouble(key);
  @override
  bool? getBool(String key) => preferences.getBool(key);
  @override
  String? getString(String key) => preferences.getString(key);
  @override
  Future<bool> setInt(String key, int value) => preferences.setInt(key, value);
  @override
  Future<bool> setDouble(String key, double value) =>
      preferences.setDouble(key, value);
  @override
  Future<bool> setBool(String key, bool value) =>
      preferences.setBool(key, value);
  @override
  Future<bool> setString(String key, String value) =>
      preferences.setString(key, value);
}
