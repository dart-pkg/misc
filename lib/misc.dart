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
