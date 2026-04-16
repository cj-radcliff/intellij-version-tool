import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> fetchAndSaveReleases({
  required String code,
  required String type,
  required String outputPath,
}) async {
  final url = 'https://data.services.jetbrains.com/products/releases?code=$code&type=$type';
  print('Fetching data from $url...');

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      if (data.isEmpty) {
        print('No data found for code: $code and type: $type');
        return;
      }

      final String productKey = data.keys.first;
      final List<dynamic> releases = List.from(data[productKey] ?? []);

      // Sort releases by date descending (most recent first)
      releases.sort((a, b) {
        final dateA = a['date'] ?? '';
        final dateB = b['date'] ?? '';
        return dateB.compareTo(dateA);
      });

      final buffer = StringBuffer();
      buffer.writeln('# JetBrains Releases: $productKey ($type)');
      buffer.writeln('');
      buffer.writeln('| Version | Build | Date |');
      buffer.writeln('| --- | --- | --- |');

      for (var release in releases) {
        final version = release['version'] ?? 'N/A';
        final build = release['build'] ?? 'N/A';
        final date = release['date'] ?? 'N/A';
        
        buffer.writeln('| $version | $build | $date |');
      }

      final file = File(outputPath);
      await file.writeAsString(buffer.toString());
      print('Markdown table generated and saved to $outputPath');
    } else {
      print('Failed to fetch data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('An error occurred: $e');
    rethrow;
  }
}
