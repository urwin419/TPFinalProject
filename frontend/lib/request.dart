import 'dart:convert';
import 'package:http/http.dart' as http;
import 'main.dart';
import 'other.dart';

Future<void> fetchLatestRecord(context) async {
  try {
    String? cookieValue = await storage.read(key: 'cookie');
    String cookie = cookieValue ?? '';
    final response =
        await http.get(Uri.parse('$serverUrl/query/latest_record'), headers: {
      'cookie': cookie,
      'Content-Type': 'application/json; charset=UTF-8',
      'Connection': 'keep-alive'
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
  try {
    String? cookieValue = await storage.read(key: 'cookie');
    String cookie = cookieValue ?? '';
    final response = await http.get(
        Uri.parse('$serverUrl/query/record?record_type=plan&latest=True'),
        headers: {
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

String _formatDateComponent(int component) {
  return component.toString().padLeft(2, '0');
}

Future<void> fetchScores(context) async {
  try {
    DateTime now = DateTime.now();
    String formattedDate =
        '${now.year}-${_formatDateComponent(now.month)}-${_formatDateComponent(now.day)}';
    String? cookieValue = await storage.read(key: 'cookie');
    String cookie = cookieValue ?? '';
    final response = await http.get(
        Uri.parse('$serverUrl/query/health_scores?date=$formattedDate'),
        headers: {
          'cookie': cookie,
          'Content-Type': 'application/json; charset=UTF-8',
        });
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      List entries = jsonData.entries.toList();
      if (entries.isNotEmpty) {
        MapEntry lastEntry = entries.last;
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

Future<List<Map<String, dynamic>>?> fetchRecord(kind) async {
  String? cookieValue = await storage.read(key: 'cookie');
  String cookie = cookieValue ?? '';
  final response = await http
      .get(Uri.parse('$serverUrl/query/record?record_type=$kind'), headers: {
    'cookie': cookie,
    'Content-Type': 'application/json; charset=UTF-8',
  });
  if (response.statusCode == 200) {
    List<Map<String, dynamic>> jsonResponse =
        json.decode(response.body)["records"].cast<Map<String, dynamic>>();
    return jsonResponse;
  } else {
    throw Exception('Unexpected error occured!');
  }
}

Future<Map<String, dynamic>> fetchPrizes() async {
  try {
    DateTime now = DateTime.now();
    String formattedDate =
        '${now.year}-${_formatDateComponent(now.month)}-${_formatDateComponent(now.day)}';
    String? cookieValue = await storage.read(key: 'cookie');
    String cookie = cookieValue ?? '';
    final response = await http.get(
        Uri.parse('$serverUrl/query/achievement?date=$formattedDate'),
        headers: {
          'cookie': cookie,
          'Content-Type': 'application/json; charset=UTF-8',
        });
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      throw Exception('Unexpected error occured!');
    }
  } catch (e) {
    throw Exception('Unexpected error occured!');
  }
}
