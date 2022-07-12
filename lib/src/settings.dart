import 'package:meta/meta.dart';
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

  @protected
  bool hasKey(String key) => _prefs.containsKey(key);

  @protected
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

  @protected
  void setObject<T extends JsonObject>(String key, T? value) {
    if (value == null) {
      _objectCache.remove(key);
      _prefs.remove(key);
    } else {
      _objectCache[key] = value;
      _prefs.setString(key, value.serializeAsJson());
    }
  }

  @protected
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

  @protected
  void setList<T extends JsonObject>(String key, List<T>? value) {
    if (value == null || value.isEmpty) {
      _objectCache.remove(key);
      _prefs.remove(key);
    } else {
      _objectCache[key] = value;
      _prefs.setString(key, value.serializeAsJson());
    }
  }

  @protected
  String? getString(String key) {
    return _prefs.getString(key);
  }

  @protected
  void setString(String key, String? value) {
    value == null ? _prefs.remove(key) : _prefs.setString(key, value);
  }

  @protected
  int getInt(String key, [int defaultValue = 0]) {
    return _prefs.getInt(key) ?? defaultValue;
  }

  @protected
  void setInt(String key, int? value) {
    value == null ? _prefs.remove(key) : _prefs.setInt(key, value);
  }

  @protected
  double getDouble(String key, [double defaultValue = 0]) {
    return _prefs.getDouble(key) ?? defaultValue;
  }

  @protected
  void setDouble(String key, double? value) {
    value == null ? _prefs.remove(key) : _prefs.setDouble(key, value);
  }

  @protected
  bool getBool(String key, [bool defaultValue = false]) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  @protected
  void setBool(String key, bool? value) {
    value == null ? _prefs.remove(key) : _prefs.setBool(key, value);
  }

  @protected
  List<String>? getStringList(String key) => _prefs.getStringList(key);

  @protected
  void setStringList(String key, List<String>? value) =>
      value == null ? _prefs.remove(key) : _prefs.setStringList(key, value);

  @protected
  int? getNullableInt(String key) {
    return _prefs.getInt(key);
  }

  @protected
  double? getNullableDouble(String key) {
    return _prefs.getDouble(key);
  }

  @protected
  List<int>? getIntList(String key) {
    final cache = _objectCache[key];
    if (cache != null) {
      return cache as List<int>;
    }
    final list = getStringList(key);
    if (list == null || list.isEmpty) {
      return null;
    }
    final result = list.map(int.parse).toList();
    _objectCache[key] = result;
    return result;
  }

  @protected
  void setIntList(String key, List<int>? value) {
    if (value == null || value.isEmpty) {
      _objectCache.remove(key);
      _prefs.remove(key);
    } else {
      _objectCache[key] = value;
      _prefs.setStringList(
        key,
        value.map((e) => e.toString()).toList(growable: false),
      );
    }
  }

  @protected
  List<double>? getDoubleList(String key) {
    final cache = _objectCache[key];
    if (cache != null) {
      return cache as List<double>;
    }
    final list = getStringList(key);
    if (list == null || list.isEmpty) {
      return null;
    }
    final result = list.map(double.parse).toList();
    _objectCache[key] = result;
    return result;
  }

  @protected
  void setDoubleList(String key, List<double>? value) {
    if (value == null || value.isEmpty) {
      _objectCache.remove(key);
      _prefs.remove(key);
    } else {
      _objectCache[key] = value;
      _prefs.setStringList(
        key,
        value.map((e) => e.toString()).toList(growable: false),
      );
    }
  }
}

extension SettingsExt on Settings {
  @protected
  void setDuration(String key, Duration? value) =>
      setInt(key, value?.inMicroseconds);

  @protected
  void getDuration(String key, [Duration defaultValue = Duration.zero]) =>
      getInt(key, defaultValue.inMicroseconds);

  @protected
  DateTime? getDate(String key) {
    return getNullableInt(key)?.toDate();
  }

  @protected
  void setDate(String key, DateTime? value) {
    setInt(key, value?.millisecondsSinceEpoch);
  }

  @protected
  T? getEnum<T extends Enum>(String key, List<T> values) {
    final index = getNullableInt(key);
    if (index == null || index < 0 || index >= values.length) {
      return null;
    }
    return values[index];
  }

  @protected
  void setEnum<T extends Enum>(String key, T? value) =>
      setInt(key, value?.index);
}

extension on int {
  DateTime toDate() => DateTime.fromMillisecondsSinceEpoch(this);
}
