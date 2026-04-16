import 'dart:io';
import 'package:args/args.dart';
import 'package:intellij_version_tool/intellij_version_tool.dart' as tool;

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('code', abbr: 'c', defaultsTo: 'IU', help: 'Product code (e.g., IU, IC, PS)')
    ..addOption('type', abbr: 't', defaultsTo: 'release', help: 'Release type (e.g., release, eap, beta)')
    ..addOption('output', abbr: 'o', help: 'Output file path (positional argument takes precedence)');

  final ArgResults argResults;
  try {
    argResults = parser.parse(arguments);
  } catch (e) {
    print('Error: $e');
    printUsage(parser);
    exit(1);
  }

  // Position 0 is the output file path, or use the --output option
  String? outputPath;
  if (argResults.rest.isNotEmpty) {
    outputPath = argResults.rest[0];
  } else if (argResults.wasParsed('output')) {
    outputPath = argResults['output'];
  }

  if (outputPath == null) {
    print('Error: Missing output file path.');
    printUsage(parser);
    exit(1);
  }

  final code = argResults['code'];
  final type = argResults['type'];

  try {
    await tool.fetchAndSaveReleases(
      code: code,
      type: type,
      outputPath: outputPath,
    );
  } catch (e) {
    exit(1);
  }
}

void printUsage(ArgParser parser) {
  print('Usage: dart run bin/intellij_version_tool.dart [options] <output_file_path>');
  print(parser.usage);
}
