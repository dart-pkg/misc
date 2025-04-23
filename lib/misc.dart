import 'dart:io' as io__;
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
Future<String> $(String command, {bool ignoreError = false}) async {
  var completer = async__.Completer<String>();
  String buffer = '';
  String workingDirectory = io__.Directory.current.absolute.path;
  io__.Process.start(shell, ['-c', command]).then((process) {
    print('[$workingDirectory] \$ $command');

    process.stdout.transform(convert__.utf8.decoder).listen((data) {
      io__.stdout.write(data);
      buffer += data;
    });
    process.stderr.transform(convert__.utf8.decoder).listen((data) {
      io__.stderr.write(data);
    });
    process.exitCode.then((code) {
      if ((!ignoreError) && code != 0) {
        throw 'ShellException($command, exitCode $code, workingDirectory: $workingDirectory)';
      }
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
Future<String> $$(List<String> commandList, {bool ignoreError = false}) async {
  String command = makeCommandLine(commandList);
  return $(command, ignoreError: ignoreError);
}
