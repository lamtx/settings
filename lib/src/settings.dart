import 'package:ext/ext.dart';
import 'package:net/net.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  factory Settings() => _instance ??= Settings._();

  Settings._();

  static Settings? _instance;

  late final SharedPreferences _prefs;
  final _objectCache = <String, Object>{};

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool hasKey(String key) => _prefs.containsKey(key);

  T? getObject<T extends Object>(String key, DataParser<T> parser) {
    final cache = _objectCache[key];
    if (cache != null) {
      return cache as T;
    }
    final json = getString(key);
    if (json == null || json.isEmpty) {
      return null;
    }
    final result = parser.parseObject(json);
    _objectCache[key] = result;
    return result;
  }

  void setObject<T extends JsonObject>(String key, T? value) {
    if (value == null) {
      _objectCache.remove(key);
      _prefs.remove(key);
    } else {
      _objectCache[key] = value;
      _prefs.setString(key, value.serializeAsJson());
    }
  }

  List<T>? getList<T>(String key, DataParser<T> parser) {
    final cache = _objectCache[key];
    if (cache != null) {
      return cache as List<T>;
    }
    final json = getString(key);
    if (json == null || json.isEmpty) {
      return null;
    }
    final result = parser.parseList(json);
    _objectCache[key] = result;
    return result;
  }

  void setList<T extends JsonObject>(String key, List<T>? value) {
    if (value == null || value.isEmpty) {
      _objectCache.remove(key);
      _prefs.remove(key);
    } else {
      _objectCache[key] = value;
      _prefs.setString(key, value.serializeAsJson());
    }
  }

  T? getEnum<T>(String key, List<T> values) {
    final index = _prefs.getInt(key);
    if (index == null || index < 0 || index >= values.length) {
      return null;
    }
    return values[index];
  }

  void setEnum<T>(String key, T value) {
    assert(() {
      if (value == null) {
        return true;
      }
      final dynamic d = value;
      final index = d.index as Object;
      return index is int;
    }(), "$value is not an enum");
    if (value == null) {
      _prefs.remove(key);
    }
    _prefs.setInt(key, (value as dynamic).index as int);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  void setString(String key, String? value) {
    value == null ? _prefs.remove(key) : _prefs.setString(key, value);
  }

  int getInt(String key, [int defaultValue = 0]) {
    return _prefs.getInt(key) ?? defaultValue;
  }

  void setInt(String key, int? value) {
    value == null ? _prefs.remove(key) : _prefs.setInt(key, value);
  }

  double getDouble(String key, [double defaultValue = 0]) {
    return _prefs.getDouble(key) ?? defaultValue;
  }

  void setDouble(String key, double? value) {
    value == null ? _prefs.remove(key) : _prefs.setDouble(key, value);
  }

  bool getBool(String key, [bool defaultValue = false]) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  void setBool(String key, bool? value) {
    value == null ? _prefs.remove(key) : _prefs.setBool(key, value);
  }

  DateTime? getDate(String key) {
    return _prefs.getInt(key)?.toDate();
  }

  void setDate(String key, DateTime? value) {
    value == null
        ? _prefs.remove(key)
        : _prefs.setInt(key, value.millisecondsSinceEpoch);
  }
}
