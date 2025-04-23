//import 'dart:io' as io__;
//import 'dart:async' as async__;
//import 'dart:convert' as convert__;
import 'package:commandline_splitter2/commandline_splitter2.dart'
    as commandline_splitter2__;

/// Makes a command line string from List of String.
String makeCommandLine(List<String> commandList) {
  String command = commandList[0];
  for (int i = 1; i < commandList.length; i++) {
    String arg = commandList[i];
    if (!(arg.startsWith('"') || arg.startsWith("'") || arg.startsWith('`')) &&
        (commandList[i].contains(' ') || commandList[i].contains(r'\'))) {
      command += ' "${commandList[i]}"';
    } else {
      command += ' ${commandList[i]}';
    }
  }
  return command;
}

List<String> splitCommandLine(String command) {
  final split = commandline_splitter2__.split(command);
  final result = <String>[];
  for (int i = 0; i < split.length; i++) {
    String arg = split[i];
    //echo(arg, 'arg');
    if ((arg.startsWith('"') && arg.endsWith('"')) ||
        (arg.startsWith("'") && arg.endsWith("'"))) {
      arg = arg.substring(1, arg.length - 1);
    }
    result.add(arg);
  }
  return result;
}
