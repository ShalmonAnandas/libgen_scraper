import 'dart:io';
import 'package:http/http.dart';
import 'package:http/io_client.dart' as http;

class APIClient {
  http.IOClient getApiClient() {
    final httpClient = HttpClient();

    return http.IOClient(httpClient);
  }

  Future<Response> getRequest(
      {required http.IOClient ioClient,
      required String url,
      Map<String, String>? headers}) async {
    try {
      return await ioClient.get(Uri.parse(url), headers: headers);
    } catch (e) {
      return Response("HTTP ERROR", 0);
    } finally {
      ioClient.close();
    }
  }
}
