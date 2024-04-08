import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DbHelper {
  late Box box;
  late SharedPreferences preferences;

  DbHelper() {
    openBox();
  }

  openBox() {
    box = Hive.box('money');
  }

  // add data to box
  Future<void> addData(
      int amount, DateTime date, String type, String note) async {
    var value = {
      'amount': amount,
      'date': date,
      'type': type,
      'note': note,
    };

    box.add(value);
  }

  // delete data from box
  Future<void> deleteData(int index) async {
    box.deleteAt(index);
  }

  Future<void> addName(String name) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString('name', name);
  }

  getName() async {
    preferences = await SharedPreferences.getInstance();
    return preferences.getString('name');
  }
}
