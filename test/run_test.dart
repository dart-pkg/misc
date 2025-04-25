import 'package:test/test.dart';
import 'package:output/output.dart';
import 'package:misc/misc.dart' as misc;

void main() {
  group('Run', () {
    test('run1', () {
      String cmd1 = misc.joinCommandLine(['ls', '-l', '~/cmd']);
      echo(cmd1, 'cmd1');
      expect(cmd1 == r'''ls -l ~/cmd''', isTrue);
      String cmd2 = misc.joinCommandLine(['ls', '-l', './abc xyz']);
      echo(cmd2, 'cmd2');
      expect(cmd2 == r'''ls -l ./abc xyz''', isTrue);
      String cmd3 = misc.joinCommandLine(['ls', '-l', r'C:\mydir']);
      echo(cmd3, 'cmd3');
      expect(cmd3 == r'''ls -l C:\mydir''', isTrue);
      String cmd4 = misc.joinCommandLine([
        'find',
        '.',
        '-name',
        '*.dart',
        '|',
        'wc',
        '-l',
      ]);
      echo(cmd4, 'cmd4');
      expect(cmd4 == r'''find . -name *.dart | wc -l''', isTrue);
      String cmd5 = misc.joinCommandLine(['ls', ';', 'ls']);
      echo(cmd5, 'cmd15');
      expect(cmd5 == r'''ls ; ls''', isTrue);
    });
    test('run2', () {
      echoJson(
        misc.splitCommandLine(
          'dart pub deps --no-dev --style list | sed "/^ .*/d"',
        ),
      );
      echoJson(
        misc.splitCommandLine('find . -name "*.dart" -exec grep abc {} \\;'),
      );
      echoJson(
        misc.splitCommandLine(
          'echo `find . -name "*.dart" -exec grep abc {} \\;`',
        ),
      );
    });
  });
}
