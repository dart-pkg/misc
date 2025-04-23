import 'dart:io';
import 'dart:async' as async__;
import 'dart:convert' as convert__;

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

/// Executable name for $() and $$() (default is `bash')
String shell = 'bash';

/// Execute command (string) in bash
Future<String> $(String command) async {
  var completer = async__.Completer<String>();
  String buffer = '';
  Process.start(shell, ['-c', command]).then((process) {
    print('\$ $command');

    process.stdout.transform(convert__.utf8.decoder).listen((data) {
      stdout.write(data);
      buffer += data;
    });
    process.stderr.transform(convert__.utf8.decoder).listen((data) {
      stderr.write(data);
    });
    process.exitCode.then((code) {
      if (buffer.endsWith('\r\n')) {
        buffer = buffer.substring(0, buffer.length - 2);
      } else if (buffer.endsWith('\n')) {
        buffer = buffer.substring(0, buffer.length - 1);
      } else if (buffer.endsWith('\r')) {
        buffer = buffer.substring(0, buffer.length - 1);
      }
      buffer = buffer.replaceAll('\r\n', '\n');
      buffer = buffer.replaceAll('\r', '\n');
      completer.complete(buffer);
    });
  });
  return completer.future;
}

/// Execute command (list of string) in bash
Future<String> $$(List<String> commandList) async {
  String command = makeCommandLine(commandList);
  return $(command);
}
