import 'dart:io';
import 'package:charcode/ascii.dart';
import 'package:io/ansi.dart';

final String _ansi = String.fromCharCode($esc);

/// Prompt the user, and return the first line read.
/// This is the core of [Prompter], and the basis for all other
/// functions.
///
/// A function to [validate] may be passed. If `null`, it defaults
/// to checking if the string is not empty.
///
/// A default value may be given as [defaultsTo]. If present, the [message]
/// will have `' ($defaultsTo)'` append to it.
///
/// If [chevron] is `true` (default), then a `>` will be appended to the prompt.
///
/// If [color] is `true` (default), then pretty ANSI colors will be used in the prompt.
///
/// [inputColor] may be used to give a color to the user's input as they type.
///
/// If [allowMultiline] is `true` (default: `false`), then lines ending in a
/// backslash (`\`) will be interpreted as a signal that another line of
/// input is to come. This is helpful for building REPL's.
String get(String message,
    {bool Function(String) validate,
    String defaultsTo,
    @deprecated bool colon = true,
    bool chevron = true,
    bool color = true,
    bool allowMultiline = false,
    bool conceal = false,
    AnsiCode inputColor = cyan}) {
  try {
    validate ??= (s) => s.trim().isNotEmpty;

    if (defaultsTo != null) {
      var oldValidate = validate;
      validate = (s) => s.trim().isEmpty || oldValidate(s);
    }

    var prefix = "?";
    var code = cyan;
    var currentChevron = '\u00BB';
    var oldEchoMode = stdin.echoMode;

    void writeIt() {
      var msg = color
          ? (code.wrap(prefix) + " " + wrapWith(message, [darkGray, styleBold]))
          : message;
      stdout.write(msg);
      if (defaultsTo != null) stdout.write(' ($defaultsTo)');
      if (chevron && colon)
        stdout.write(
            color ? lightGray.wrap(' $currentChevron') : ' $currentChevron');
      stdout.write(' ');
      stdout.write(color ? inputColor?.escape ?? '' : '');
    }

    while (true) {
      if (message.isNotEmpty) {
        writeIt();
      }

      var buf = StringBuffer();
      if (conceal) stdin.echoMode = false;

      while (true) {
        var line = stdin.readLineSync().trim();

        if (!line.endsWith('\\')) {
          buf.writeln(line);
          break;
        } else {
          buf.writeln(line.substring(0, line.length - 1));
        }
      }

      if (conceal) {
        stdin.echoMode = oldEchoMode;
        stdout.writeln();
      }

      // Reset
      stdout.write(color ? resetAll.escape : '');

      var line = buf.toString().trim();

      if (validate(line)) {
        String out;

        if (defaultsTo != null) {
          out = line.isEmpty ? defaultsTo : line;
        } else {
          out = line;
        }

        if (color) {
          var toWrite = line;
          if (conceal) {
            var asterisks = List.filled(line.length, $asterisk);
            toWrite = String.fromCharCodes(asterisks);
          }

          prefix = '\u2714';
          code = green;
          currentChevron = '\u2025';
          stdout.write(color ? '${_ansi}[F' : '');
          writeIt();
          stdout.write(color ? darkGray.escape : '');
          stdout.writeln(toWrite);
          stdout.write(color ? resetAll.escape : '');
        }

        return out;
      } else {
        code = red;
        prefix = "\u2717";
        stdout.write(color ? '${_ansi}[F' : '');

        // Clear the line.
        if (color) {
          stdout.write('\r');
          stdout.write(resetAll.escape);

          for (int i = 0; i < stdout.terminalColumns; i++) {
            stdout.write(' ');
          }

          stdout.write('\r');
        }
      }
    }
  } finally {
    stdout.write(resetAll.wrap(''));
  }
}

/// Presents a yes/no prompt to the user.
///
/// If [appendYesNo] is `true`, then a `(y/n)`, `(Y/n)` or `(y/N)` is
/// appended to the [message], depending on its value.
///
/// [color], [inputColor], [conceal], and [chevron] are forwarded to [get].
bool getBool(String message,
    {bool defaultsTo = false,
    bool appendYesNo = true,
    bool color = true,
    bool chevron = true,
    bool conceal = false,
    @deprecated bool colon = true,
    AnsiCode inputColor = cyan}) {
  if (appendYesNo)
    message +=
        defaultsTo == null ? ' (y/n)' : (defaultsTo ? ' (Y/n)' : ' (y/N)');
  var result = get(
    message,
    color: color,
    inputColor: inputColor,
    conceal: conceal,
    chevron: chevron && colon,
    validate: (s) {
      s = s.trim().toLowerCase();
      return (defaultsTo != null && s.isEmpty) ||
          s.startsWith('y') ||
          s.startsWith('n');
    },
  );
  result = result.toLowerCase();

  if (result.isEmpty)
    return defaultsTo;
  else if (result == 'y') return true;
  return false;
}

/// Prompts the user to enter an integer.
///
/// An optional [radix] may be provided.
///
/// [color], [defaultsTo], [inputColor], [conceal], and [chevron] are forwarded to [get].
int getInt(String message,
    {int defaultsTo,
    int radix = 10,
    bool color = true,
    bool chevron = true,
    bool conceal = false,
    @deprecated bool colon = true,
    AnsiCode inputColor = cyan}) {
  return int.parse(get(
    message,
    defaultsTo: defaultsTo?.toString(),
    chevron: chevron && colon,
    inputColor: inputColor,
    color: color,
    conceal: conceal,
    validate: (s) => int.tryParse(s, radix: radix) != null,
  ));
}

/// Prompts the user to enter a double.
///
/// [color], [defaultsTo], [inputColor], [conceal], and [chevron] are forwarded to [get].
double getDouble(String message,
    {double defaultsTo,
    bool color = true,
    bool chevron = true,
    @deprecated bool colon = true,
    bool conceal = false,
    AnsiCode inputColor = cyan}) {
  return double.parse(get(
    message,
    defaultsTo: defaultsTo?.toString(),
    chevron: chevron && colon,
    inputColor: inputColor,
    color: color,
    conceal: conceal,
    validate: (s) => double.tryParse(s) != null,
  ));
}

/// Displays to the user a list of [options], and returns
/// once one has been chosen.
///
/// Each option will be prefixed with a number, corresponding
/// to its index + `1`.
///
/// A default option may be provided by means of [defaultsTo].
///
/// [color], [defaultsTo], [inputColor], [conceal], and [chevron] are forwarded to [get].
///
/// Example:
///
/// ```
/// Choose a color:
///
/// 1) Red
/// 2) Blue
/// 3) Green
/// ```
T choose<T>(String message, Iterable<T> options,
    {T defaultsTo,
    bool chevron = true,
    @deprecated bool colon = true,
    AnsiCode inputColor = cyan,
    bool color = true,
    bool conceal = false}) {
  assert(options.isNotEmpty);

  var map = <T, String>{};
  for (var option in options) map[option] = option.toString();

  if (chevron && colon) message += ':';

  var b = StringBuffer();

  b..writeln(message)..writeln();

  for (int i = 0; i < options.length; i++) {
    var key = map.keys.elementAt(i);
    b.write('${i + 1}) ${map[key]}');
    if (key == defaultsTo) b.write(' [Default - Press Enter]');
    b.writeln();
  }

  b.writeln();

  var line = get(
    b.toString(),
    chevron: false,
    inputColor: inputColor,
    color: color,
    conceal: conceal,
    validate: (s) {
      if (s.isEmpty) return defaultsTo != null;
      if (map.values.contains(s)) return true;
      int i = int.tryParse(s);
      if (i == null) return false;
      return i >= 1 && i <= options.length;
    },
  );

  if (line.isEmpty) return defaultsTo;
  int i = int.tryParse(line);
  if (i != null) return map.keys.elementAt(i - 1);
  return map.keys.elementAt(map.values.toList(growable: false).indexOf(line));
}

/// Similar to [choose], but opts for a shorthand syntax that fits into one line,
/// rather than a multi-line prompt.
///
/// Acceptable inputs include:
/// * The full value of `toString()` for any one option
/// * The first character (case-insensitive) of `toString()` for an option
///
/// A default option may be provided by means of [defaultsTo].
///
/// [color], [defaultsTo], [inputColor], and [chevron] are forwarded to [get].
T chooseShorthand<T>(String message, Iterable<T> options,
    {T defaultsTo,
    bool chevron = true,
    @deprecated bool colon = true,
    AnsiCode inputColor = cyan,
    bool color = true,
    bool conceal = true}) {
  assert(options.isNotEmpty);

  var b = StringBuffer(message);
  if (chevron && colon) b.write(':');
  b.write(' (');
  var firstChars = <String>[], strings = <String>[];
  int i = 0;

  for (var option in options) {
    var str = option.toString();
    if (i++ > 0) b.write('/');

    if (defaultsTo != null) {
      if (defaultsTo == option)
        str = str[0].toUpperCase() + str.substring(1);
      else
        str = str[0].toLowerCase() + str.substring(1);
    }

    b.write(str);
    firstChars.add(str[0].toLowerCase());
    strings.add(str);
  }

  b.write(')');

  T value;

  get(
    b.toString(),
    chevron: chevron && colon,
    inputColor: inputColor,
    color: color,
    conceal: conceal,
    validate: (s) {
      if (s.isEmpty) return (value = defaultsTo) != null;

      if (strings.contains(s)) {
        value = options.elementAt(strings.indexOf(s));
        return true;
      }

      if (firstChars.contains(s[0].toLowerCase())) {
        value = options.elementAt(firstChars.indexOf(s[0].toLowerCase()));
        return true;
      }

      return false;
    },
  );

  return value;
}
