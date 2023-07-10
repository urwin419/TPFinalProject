import 'dart:convert';
import 'package:http/http.dart' as http;
import 'main.dart';

Future<void> fetchLatestRecord(context) async {
  var url = Uri.http(serverUrl, '/query/latest_record');
  try {
    final response = await http.get(url, headers: {
      'cookie': cookie,
      'Content-Type': 'application/json; charset=UTF-8',
    });
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      latestRecord = jsonData;
    } else {
      showAutoHideAlertDialog(context, ["Query Failed"]);
    }
  } catch (e) {
    showAutoHideAlertDialog(context, ["Failed", "Server unavailable now"]);
  }
}

Future<void> fetchPlan(context) async {
  var url = Uri.http(
      serverUrl, '/query/record', {'record_type': 'plan', 'latest': 'True'});
  try {
    final response = await http.get(url, headers: {
      'cookie': cookie,
      'Content-Type': 'application/json; charset=UTF-8',
    });
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      plan = jsonData['record'];
    } else {
      showAutoHideAlertDialog(context, ["Query Failed"]);
    }
  } catch (e) {
    showAutoHideAlertDialog(context, ["Failed", "Server unavailable now"]);
  }
}

Future<void> fetchScores(context) async {
  var url = Uri.http(
    serverUrl,
    '/query/health_scores',
  );
  try {
    final response = await http.get(url, headers: {
      'cookie': cookie,
      'Content-Type': 'application/json; charset=UTF-8',
    });
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      List entries = jsonData.entries.toList();
      if (entries.isNotEmpty) {
        MapEntry lastEntry = entries.last;
        scoreweek = lastEntry.key;
        scores = lastEntry.value;
      } else {
        showAutoHideAlertDialog(context, ["MAP EMPTY"]);
      }
    } else {
      showAutoHideAlertDialog(context, ["Query Failed"]);
    }
  } catch (e) {
    showAutoHideAlertDialog(context, ["Failed", "Server unavailable now"]);
  }
}

Future<List<dynamic>> fetchRecord(kind) async {
  var url = Uri.http(serverUrl, '/query/record', {'record_type': kind});
  final response = await http.get(url, headers: {
    'cookie': cookie,
    'Content-Type': 'application/json; charset=UTF-8',
  });
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body)["records"];
    return jsonResponse;
  } else {
    throw Exception('Unexpected error occured!');
  }
}

Future<List<dynamic>> fetchQAHistory() async {
  var url = Uri.http(serverUrl, '/query/qa_history', {'num': '10'});
  try {
    final response = await http.get(url, headers: {
      'cookie': cookie,
      'Content-Type': 'application/json; charset=UTF-8',
    });
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      List qaHistory = jsonData['history'];
      if (qaHistory.isNotEmpty) {
        return qaHistory;
      } else {
        return [
          {
            "answer": "Ask your first question!",
            "qa_time": "2023-07-09T00:00:00",
            "question": "COME!"
          }
        ];
      }
    } else {
      throw Exception('Unexpected error occured!');
    }
  } catch (e) {
    throw Exception('Unexpected error occured!');
  }
}
