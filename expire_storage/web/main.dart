import 'dart:convert';
import 'dart:html';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

final class ExpireStorage {
  static bool _checkUnique([List<dynamic> arr = const []]) {
    final checkedArray = arr.asMap().entries;
    return !checkedArray.any((data) {
      var index = data.key;
      var target = jsonEncode(data.value);
      return (checkedArray.any((data) {
        var idx = data.key;
        var object = jsonEncode(data.value);
        return index > idx && object == target;
      }));
    });
  }

  static ({int millisecond, int second, int minute, int hour, int day})
      convertTime(value, [bool isCount = true]) {
    var time = "$value";
    final unit =
        time.replaceFirst(RegExp("(\\d+)(?=[smhd])"), "").toLowerCase();
    final trueValue = int.parse(time.replaceFirst(unit, "").trim());
    var millisecond = trueValue;
    var toSecond = 1000,
        toMinute = toSecond * 60,
        toHour = toMinute * 60,
        toDay = toHour * 24;
    switch (unit) {
      case String s when s.startsWith("s"):
        millisecond = trueValue * toSecond;
        break;
      case String m when m.startsWith("m"):
        millisecond = trueValue * toMinute;
        break;
      case String h when h.startsWith("h"):
        millisecond = trueValue * toHour;
        break;
      case String d when d.startsWith("d"):
        millisecond = trueValue * toDay;
        break;
    }
    return (
      millisecond: millisecond,
      second:
          ((isCount ? millisecond % toMinute : millisecond) / toSecond).floor(),
      minute:
          ((isCount ? millisecond % toHour : millisecond) / toMinute).floor(),
      hour: ((isCount ? millisecond % toDay : millisecond) / toHour).floor(),
      day: (millisecond / toDay).floor(),
    );
  }

  static void setItem(key, value, [String expire = ""]) {
    var exist = getItem(key);
    if (exist != null) {
      var isUnique = _checkUnique([exist, value]);
      if (!isUnique) return;
    }
    if (expire.isNotEmpty) {
      var millisecondsSinceEpoch = DateTime.now().millisecondsSinceEpoch;
      var convertedDate = DateTime.fromMillisecondsSinceEpoch(
          millisecondsSinceEpoch + convertTime(expire).millisecond);
      initializeDateFormatting("vi-VN").then((_) {
        DateFormat formatter = DateFormat("yyyy-MM-dd HH:mm:ss", "vi-VN");
        expire = formatter.format(convertedDate);
        Map<String, Object?> newValue = {
          "payload": value,
          "expire": expire,
        };
        window.localStorage[key] = jsonEncode(newValue);
      });
    } else {
      var newValue = value;
      window.localStorage[key] = jsonEncode(newValue);
    }
  }

  static dynamic getItem(key) {
    String? encoded = window.localStorage[key];
    if (encoded != null) {
      var data = jsonDecode(encoded);
      String? expire = data["expire"];
      if (expire != null) {
        if (DateTime.parse(expire).isBefore(DateTime.now())) {
          window.localStorage.remove(key);
          return "";
        }
        return data["payload"];
      } else {
        return data;
      }
    }
    return "";
  }
}

void main() {
  querySelector('_output')?.text = 'Your Dart app is running.';
  var dateInput = querySelector('.date')! as InputElement;
  var valueInput = querySelector('.value')! as InputElement;

  valueInput.defaultValue = ExpireStorage.getItem("data").toString();

  String? expire;
  dateInput.onChange.listen((event) {
    expire = dateInput.value;
  });

  valueInput.onKeyUp.listen((event) {
    if (event.key == "Enter") {
      print(valueInput.value);
      ExpireStorage.setItem("data", valueInput.value, expire!);
    }
  });
}
