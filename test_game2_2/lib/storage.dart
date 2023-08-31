import 'package:shared_preferences/shared_preferences.dart';

class DataStorage {
  Future<void> saveData(int experience, int level, int attackPower) async {
    final prefs = await SharedPreferences.getInstance();

    prefs
      ..setInt('experience', experience)
      ..setInt('level', level)
      ..setInt('attackPower', attackPower);
  }

  Future<Map<String, int>> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final experience = prefs.getInt('experience') ?? 0;
    final level = prefs.getInt('level') ?? 1;
    final attackPower = prefs.getInt('attackPower') ?? 10;

    return {
      'experience': experience,
      'level': level,
      'attackPower': attackPower,
    };
  }

  Future<void> resetData() async {
    final prefs = await SharedPreferences.getInstance();

    prefs
      ..remove('experience')
      ..remove('level')
      ..remove('attackPower');
  }
}
