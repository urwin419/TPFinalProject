import 'dart:convert';
import 'package:http/http.dart' as http;
import 'main.dart';

Future<void> fetchLatestRecord(context) async {
  try {
    final response =
        await http.get(Uri.parse('$serverUrl/query/latest_record'), headers: {
      'cookie': cookie,
      'Content-Type': 'application/json; charset=UTF-8',
      'Connection': 'keep-alive'
    });
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      latestRecord = jsonData;
      print(response.body);
    } else {
      showAutoHideAlertDialog(context, ["Query Failed"]);
    }
  } catch (e) {
    showAutoHideAlertDialog(context, ["Failed", "Server unavailable now"]);
  }
}

Future<void> fetchPlan(context) async {
  try {
    final response = await http.get(
        Uri.parse('$serverUrl/query/record?record_type=plan&latest=True'),
        headers: {
          'cookie': cookie,
          'Content-Type': 'application/json; charset=UTF-8',
        });
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      plan = jsonData['record'];
      print(response.body);
    } else {
      showAutoHideAlertDialog(context, ["Query Failed"]);
    }
  } catch (e) {
    showAutoHideAlertDialog(context, ["Failed", "Server unavailable now"]);
  }
}

Future<void> fetchScores(context) async {
  try {
    final response =
        await http.get(Uri.parse('$serverUrl/query/health_scores'), headers: {
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
  final response = await http.get(
      Uri.parse('$serverUrl/query/health_scores?record_type=$kind'),
      headers: {
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
  try {
    final response = await http
        .get(Uri.parse('$serverUrl/query/qa_history?num=10'), headers: {
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
