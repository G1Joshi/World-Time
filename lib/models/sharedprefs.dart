import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPreferences? _pref;

  static SharedPreferences get pref {
    final instance = _pref;
    if (instance == null) {
      throw StateError(
        'SharedPrefs has not been initialized. Call await SharedPrefs.init() before accessing preferences.',
      );
    }
    return instance;
  }

  static set pref(SharedPreferences instance) {
    _pref = instance;
  }

  static bool get isInitialized => _pref != null;

  static Future<void> init() async {
    _pref = await SharedPreferences.getInstance();
  }

  static Future<void> setData(String location, String gmt) async {
    await pref.setString('location', location);
    await pref.setString('gmt', gmt);
  }

  static Future<Map<String, String>> getData() async {
    return {
      'location': pref.getString('location') ?? 'india',
      'gmt': pref.getString('gmt') ?? '+05:30',
    };
  }

  static String get selectedLocationId => pref.getString('location') ?? 'india';

  static Future<void> setSelectedLocationId(
    String locationId,
    String gmt,
  ) async {
    await setData(locationId, gmt);
  }

  static bool get is24HourFormat => pref.getBool('is_24_hour') ?? false;

  static Future<void> set24HourFormat(bool value) async {
    await pref.setBool('is_24_hour', value);
  }

  static bool get isAnalogClock => pref.getBool('is_analog_clock') ?? false;

  static Future<void> setAnalogClock(bool value) async {
    await pref.setBool('is_analog_clock', value);
  }

  static List<String> get favorites {
    return pref.getStringList('favorite_locations') ?? <String>[];
  }

  static Future<bool> toggleFavorite(String locationId) async {
    final current = List<String>.from(favorites);
    final normalized = locationId.toLowerCase().trim();
    final bool isNowFav;
    if (current.contains(normalized)) {
      current.remove(normalized);
      isNowFav = false;
    } else {
      current.add(normalized);
      isNowFav = true;
    }
    await pref.setStringList('favorite_locations', current);
    return isNowFav;
  }

  static bool isFavorite(String locationId) {
    return favorites.contains(locationId.toLowerCase().trim());
  }

  static List<String> get recents {
    return pref.getStringList('recent_locations') ?? <String>[];
  }

  static Future<void> addRecent(String locationId) async {
    final normalized = locationId.toLowerCase().trim();
    final current = List<String>.from(recents);
    current.remove(normalized);
    current.insert(0, normalized);
    if (current.length > 5) {
      current.removeLast();
    }
    await pref.setStringList('recent_locations', current);
  }

  static String get sortOrder => pref.getString('sort_order') ?? 'alphabetical';

  static Future<void> setSortOrder(String order) async {
    await pref.setString('sort_order', order);
  }

  static Future<void> resetData() async {
    await pref.clear();
  }
}
