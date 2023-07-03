
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'exerecord.dart';
import 'main.dart';
import 'mealrecord.dart';
import 'weightrecord.dart';

Future<List<ExeRecord>> fetchExe() async {
  var url = Uri.http(serverUrl, '/get_exe');
  final response = await http.get(url, headers: {'cookie': cookie});
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body)["data"];
    return jsonResponse.map((data) => ExeRecord.fromJson(data)).toList();
  } else {
    throw Exception('Unexpected error occured!');
  }
}

Future<List<MealRecord>> fetchMeal() async {
  var url = Uri.http(serverUrl, '/get_meal');
  final response = await http.get(url, headers: {'cookie': cookie});
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body)["data"];
    return jsonResponse.map((data) => MealRecord.fromJson(data)).toList();
  } else {
    throw Exception('Unexpected error occured!');
  }
}

Future<List<WeightRecord>> fetchWeight() async {
  var url = Uri.http(serverUrl, '/get_wei');
  final response = await http.get(url, headers: {'cookie': cookie});
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body)["data"];
    return jsonResponse.map((data) => WeightRecord.fromJson(data)).toList();
  } else {
    throw Exception('Unexpected error occured!');
  }
}

Future<String> fetchAnalysis() async {
  var url = Uri.http(serverUrl, '/get_chat');
  Map<String, String>? userHeader = {
    'Connection': 'Keep-Alive',
    'cookie': cookie
  };
  final response = await http.get(url, headers: userHeader);
  if (response.statusCode == 200) {
    String report =
        json.decode(response.body)["data"]["choices"][0]["text"].substring(1);
    return report;
  } else {
    throw Exception('Unexpected error occured!');
  }
}
