//import 'dart:io' as io__;
//import 'dart:async' as async__;
//import 'dart:convert' as convert__;

import 'package:string_scanner/string_scanner.dart';

/// Makes a command line string from List of String (arg list).
String makeCommandLine(List<String> commandList) {
  String command = '"${commandList[0]}"';
  for (int i = 1; i < commandList.length; i++) {
    String arg = commandList[i];
    // if (!(arg.startsWith('"') || arg.startsWith("'") || arg.startsWith('`')) &&
    //     (commandList[i].contains(' ') || commandList[i].contains(r'\'))) {
    //   command += ' "${commandList[i]}"';
    // } else {
    //   command += ' ${commandList[i]}';
    // }
    if (arg.startsWith('|') || arg.startsWith('&') || arg.startsWith('>')) {
      command += ' $arg';
    } else {
      command += ' "$arg"';
    }
  }
  return command;
}

// /// Split a command line string into List of String (arg list).
// List<String> splitCommandLine(String command) {
//   final split = _split(command);
//   final result = <String>[];
//   for (int i = 0; i < split.length; i++) {
//     String arg = split[i];
//     if ((arg.startsWith('"') && arg.endsWith('"')) ||
//         (arg.startsWith("'") && arg.endsWith("'"))) {
//       arg = arg.substring(1, arg.length - 1);
//     }
//     result.add(arg);
//   }
//   return result;
// }
//
// List<String> _split(String command) {
//   final ret = <String>[];
//   command = command.trim();
//   while (command.isNotEmpty) {
//     var regexp = RegExp(r"""[^'"-\s]+""");
//     if (command[0] == '-') {
//       //regexp = RegExp(r"""--?[^'"-\s]+""");
//       regexp = RegExp(r"""--?[^'"\s]+""");
//     } else if (command[0] == "'") {
//       regexp = RegExp(r"""'[^']+'""");
//     } else if (command[0] == '"') {
//       regexp = RegExp(r'''"[^"]+"''');
//     }
//     final match = regexp.matchAsPrefix(command);
//     if (match != null) {
//       var part = command.substring(match.start, match.end);
//       ret.add(part);
//       command = command.substring(match.end).trim();
//     } else {
//       throw Exception('Cannot parse $command');
//     }
//   }
//   return ret;
// }

/// "Horizontal Tab" control character, common name.
const int _charcodeTab = 0x09;

/// "Line feed" control character.
const int _charcodeLf = 0x0A;
// Visible characters.
/// Space character.
const int _charcodeSpace = 0x20;

/// Character `"`.
const int _charcodeDoubleQuote = 0x22;

/// Character `#`.
const int _charcodeHash = 0x23;

/// Character `$`.
const int _charcodeDollar = 0x24;

/// Character `'`.
const int _charcodeSingleQuote = 0x27;

/// Character `\`.
const int _charcodeBackslash = 0x5C;

/// Character `` ` ``.
const int _charcodeBackquote = 0x60;

/// Splits [command] into tokens according to [the POSIX shell
/// specification][spec].
///
/// [spec]: http://pubs.opengroup.org/onlinepubs/9699919799/utilities/contents.html
///
/// This returns the unquoted values of quoted tokens. For example,
/// `shellSplit('foo "bar baz"')` returns `["foo", "bar baz"]`. It does not
/// currently support here-documents. It does *not* treat dynamic features such
/// as parameter expansion specially. For example, `shellSplit("foo $(bar
/// baz)")` returns `["foo", "$(bar", "baz)"]`.
///
/// This will discard any comments at the end of [command].
///
/// Throws a [FormatException] if [command] isn't a valid shell command.
List<String> splitCommandLine(String command) {
  final scanner = StringScanner(command);
  final results = <String>[];
  final token = StringBuffer();

  // Whether a token is being parsed, as opposed to a separator character. This
  // is different than just [token.isEmpty], because empty quoted tokens can
  // exist.
  var hasToken = false;

  while (!scanner.isDone) {
    final next = scanner.readChar();
    switch (next) {
      case _charcodeBackslash:
        // Section 2.2.1: A <backslash> that is not quoted shall preserve the
        // literal value of the following character, with the exception of a
        // <newline>. If a <newline> follows the <backslash>, the shell shall
        // interpret this as line continuation. The <backslash> and <newline>
        // shall be removed before splitting the input into tokens. Since the
        // escaped <newline> is removed entirely from the input and is not
        // replaced by any white space, it cannot serve as a token separator.
        if (scanner.scanChar(_charcodeLf)) break;

        hasToken = true;
        token.writeCharCode(scanner.readChar());
        break;

      case _charcodeSingleQuote:
        hasToken = true;
        // Section 2.2.2: Enclosing characters in single-quotes ( '' ) shall
        // preserve the literal value of each character within the
        // single-quotes. A single-quote cannot occur within single-quotes.
        final firstQuote = scanner.position - 1;
        while (!scanner.scanChar(_charcodeSingleQuote)) {
          _checkUnmatchedQuote(scanner, firstQuote);
          token.writeCharCode(scanner.readChar());
        }
        break;

      case _charcodeDoubleQuote:
        hasToken = true;
        // Section 2.2.3: Enclosing characters in double-quotes ( "" ) shall
        // preserve the literal value of all characters within the
        // double-quotes, with the exception of the characters backquote,
        // <dollar-sign>, and <backslash>.
        //
        // (Note that this code doesn't preserve special behavior of backquote
        // or dollar sign within double quotes, since those are dynamic
        // features.)
        final firstQuote = scanner.position - 1;
        while (!scanner.scanChar(_charcodeDoubleQuote)) {
          _checkUnmatchedQuote(scanner, firstQuote);

          if (scanner.scanChar(_charcodeBackslash)) {
            _checkUnmatchedQuote(scanner, firstQuote);

            // The <backslash> shall retain its special meaning as an escape
            // character (see Escape Character (Backslash)) only when followed
            // by one of the following characters when considered special:
            //
            //     $ ` " \ <newline>
            final next = scanner.readChar();
            if (next == _charcodeLf) continue;
            if (next == _charcodeDollar ||
                next == _charcodeBackquote ||
                next == _charcodeDoubleQuote ||
                next == _charcodeBackslash) {
              token.writeCharCode(next);
            } else {
              token
                ..writeCharCode(_charcodeBackslash)
                ..writeCharCode(next);
            }
          } else {
            token.writeCharCode(scanner.readChar());
          }
        }
        break;

      case _charcodeHash:
        // Section 2.3: If the current character is a '#' [and the previous
        // characters was not part of a word], it and all subsequent characters
        // up to, but excluding, the next <newline> shall be discarded as a
        // comment. The <newline> that ends the line is not considered part of
        // the comment.
        if (hasToken) {
          token.writeCharCode(_charcodeHash);
          break;
        }

        while (!scanner.isDone && scanner.peekChar() != _charcodeLf) {
          scanner.readChar();
        }
        break;

      case _charcodeSpace:
      case _charcodeTab:
      case _charcodeLf:
        // ignore: invariant_booleans
        if (hasToken) results.add(token.toString());
        hasToken = false;
        token.clear();
        break;

      default:
        hasToken = true;
        token.writeCharCode(next);
        break;
    }
  }

  if (hasToken) results.add(token.toString());
  return results;
}

/// Throws a [FormatException] if [scanner] is done indicating that a closing
/// quote matching the one at position [openingQuote] is missing.
void _checkUnmatchedQuote(StringScanner scanner, int openingQuote) {
  if (!scanner.isDone) return;
  final type =
      scanner.substring(openingQuote, openingQuote + 1) == '"'
          ? 'double'
          : 'single';
  scanner.error('Unmatched $type quote.', position: openingQuote, length: 1);
}
