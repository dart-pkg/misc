//import 'dart:io' as io__;
//import 'dart:async' as async__;
//import 'dart:convert' as convert__;

/// Makes a command line string from List of String (arg list).
String makeCommandLine(List<String> commandList) {
  String command = commandList[0];
  for (int i = 1; i < commandList.length; i++) {
    String arg = commandList[i];
    // if (!(arg.startsWith('"') || arg.startsWith("'") || arg.startsWith('`')) &&
    //     (commandList[i].contains(' ') || commandList[i].contains(r'\'))) {
    //   command += ' "${commandList[i]}"';
    // } else {
    //   command += ' ${commandList[i]}';
    // }
    command += ' $arg';
  }
  return command;
}

/// Split a command line string into List of String (arg list).
List<String> splitCommandLine(String command) {
  final split = _split(command);
  final result = <String>[];
  for (int i = 0; i < split.length; i++) {
    String arg = split[i];
    // if ((arg.startsWith('"') && arg.endsWith('"')) ||
    //     (arg.startsWith("'") && arg.endsWith("'"))) {
    //   arg = arg.substring(1, arg.length - 1);
    // }
    result.add(arg);
  }
  return result;
}

List<String> _split(String command) {
  final ret = <String>[];
  command = command.trim();
  while (command.isNotEmpty) {
    var regexp = RegExp(r"""[^'"-\s]+""");
    if (command[0] == '-') {
      //regexp = RegExp(r"""--?[^'"-\s]+""");
      regexp = RegExp(r"""--?[^'"\s]+""");
    } else if (command[0] == "'") {
      regexp = RegExp(r"""'[^']+'""");
    } else if (command[0] == '"') {
      regexp = RegExp(r'''"[^"]+"''');
    }
    final match = regexp.matchAsPrefix(command);
    if (match != null) {
      var part = command.substring(match.start, match.end);
      ret.add(part);
      command = command.substring(match.end).trim();
    } else {
      throw Exception('Cannot parse $command');
    }
  }
  return ret;
}
