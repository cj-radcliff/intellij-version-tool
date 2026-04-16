import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> fetchAndSaveReleases({
  required String code,
  required String type,
  required String outputPath,
  List<String> extraColumns = const [],
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

      // Sort releases by date descending
      releases.sort((a, b) {
        final dateA = a['date'] ?? '';
        final dateB = b['date'] ?? '';
        return dateB.compareTo(dateA);
      });

      // Determine columns
      List<String> columnKeys = ['version', 'build', 'date'];
      bool showAll = extraColumns.contains('all');

      if (showAll) {
        final Set<String> allKeys = {};
        for (var release in releases) {
          if (release is Map<String, dynamic>) {
            allKeys.addAll(release.keys);
          }
        }
        columnKeys = allKeys.toList()..sort();
        // Move core columns to the front if they exist
        for (var core in ['version', 'build', 'date'].reversed) {
          if (columnKeys.contains(core)) {
            columnKeys.remove(core);
            columnKeys.insert(0, core);
          }
        }
      } else {
        for (var col in extraColumns) {
          if (!columnKeys.contains(col) && col.isNotEmpty) {
            columnKeys.add(col);
          }
        }
      }

      final buffer = StringBuffer();
      buffer.writeln('# JetBrains Releases: $productKey ($type)');
      buffer.writeln('');
      
      // Header
      buffer.writeln('| ${columnKeys.join(' | ')} |');
      buffer.writeln('| ${columnKeys.map((_) => '---').join(' | ')} |');

      for (var release in releases) {
        if (release is Map<String, dynamic>) {
          final row = columnKeys.map((key) {
            final value = release[key];
            if (value == null) return 'N/A';
            if (value is Map || value is List) {
              // Flatten complex objects for the table
              return jsonEncode(value).replaceAll('|', '\\|');
            }
            return value.toString().replaceAll('|', '\\|');
          }).join(' | ');
          buffer.writeln('| $row |');
        }
      }

      final file = File(outputPath);
      await file.writeAsString(buffer.toString());
      print('Markdown table with ${columnKeys.length} columns generated and saved to $outputPath');
    } else {
      print('Failed to fetch data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('An error occurred: $e');
    rethrow;
  }
}
