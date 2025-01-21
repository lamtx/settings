import 'dart:convert';

import 'package:ext/ext.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class Settings {
  Settings(this._prefs);

  final SharedPreferences _prefs;
  final _objectCache = <String, Object>{};

  bool hasKey(String key) => _prefs.containsKey(key);

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

  List<String>? getStringList(String key) => _prefs.getStringList(key);

  void setStringList(String key, List<String>? value) =>
      value == null ? _prefs.remove(key) : _prefs.setStringList(key, value);

  int? getNullableInt(String key) {
    return _prefs.getInt(key);
  }

  double? getNullableDouble(String key) {
    return _prefs.getDouble(key);
  }

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

  Map<String, V>? getMap<V>(String key) {
    final cache = _objectCache[key];
    if (cache != null) {
      return cache as Map<String, V>;
    }
    final s = getString(key);
    if (s == null || s.isEmpty) {
      return null;
    }
    final dynamic map = json.decode(s);
    if (map is Map) {
      final forceCast = Map<String, V>.from(map);
      _objectCache[key] = forceCast;
      return forceCast;
    } else {
      throw Exception("The provided json is not a map");
    }
  }

  void setMap<V>(String key, Map<String, V>? value) {
    if (value == null) {
      _objectCache.remove(key);
      _prefs.remove(key);
    } else {
      _objectCache[key] = value;
      _prefs.setString(key, json.encode(value));
    }
  }
}

extension SettingsExt on Settings {
  Duration getDuration(String key, [Duration defaultValue = Duration.zero]) =>
      Duration(microseconds: getInt(key, defaultValue.inMicroseconds));

  void setDuration(String key, Duration? value) =>
      setInt(key, value?.inMicroseconds);

  DateTime? getDate(String key) {
    return getNullableInt(key)?.toDate();
  }

  void setDate(String key, DateTime? value) {
    setInt(key, value?.millisecondsSinceEpoch);
  }

  T? getEnum<T extends Enum>(String key, List<T> values) {
    final index = getNullableInt(key);
    if (index == null || index < 0 || index >= values.length) {
      return null;
    }
    return values[index];
  }

  void setEnum<T extends Enum>(String key, T? value) =>
      setInt(key, value?.index);

  T? getJson<T extends Object>(String key, JsonObjectFactory<T> fromJson) {
    final cache = _objectCache[key];
    if (cache != null) {
      return cache as T;
    }
    final json = getString(key);
    if (json == null || json.isEmpty) {
      return null;
    }
    final result = fromJson.parseObject(json);
    _objectCache[key] = result;
    return result;
  }

  void setJson<T extends ToJson>(String key, T? value) {
    if (value == null) {
      _objectCache.remove(key);
      _prefs.remove(key);
    } else {
      _objectCache[key] = value;
      _prefs.setString(key, value.serializeAsJson());
    }
  }

  List<T>? getList<T>(String key, JsonObjectFactory<T> parser) {
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

  void setList<T extends ToJson>(String key, List<T>? value) {
    if (value == null || value.isEmpty) {
      _objectCache.remove(key);
      _prefs.remove(key);
    } else {
      _objectCache[key] = value;
      _prefs.setString(key, value.serializeAsJson());
    }
  }
}
