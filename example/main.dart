import 'package:io/ansi.dart';
import 'package:prompts/prompts.dart' as prompts;

void main() {
  // Easily get a single line.
  var name = prompts.get('Enter your name');
  print('Hello, $name!');

  var password = prompts.get(
    'Enter a password',
    conceal: true,
    hintText: 'Make sure to keep this super secure!',
  );
  print('TOP-SECRET: $password');

  // ... Or many lines.
  print('Tell me about yourself.');
  var bio = prompts.get(
    "Enter some lines, using '\\' to escape line breaks",
    allowMultiline: true,
    inputColor: resetAll,
  );
  print('About $name:\n$bio');

  // Supports default values.
  name = prompts.get('Enter your REAL name', defaultsTo: name);
  print('Hello, $name!');

  // "High-level" prompts are built upon [get].
  // For example, we can prompt for confirmation trivially.
  bool shouldDownload = prompts.getBool('Really download this package?');

  if (!shouldDownload) {
    print('Not downloading.');
  } else {
    print('Downloading...!');
  }

  // Or, get an integer, WITH validation.
  int age = prompts.getInt('How old are you?', defaultsTo: 23, chevron: false);
  print('$name, you\'re $age? Cool!');

  // We can choose from various values.
  // There are two methods - shorthand and regular.
  var rgb = [Color.red, Color.green, Color.blue];
  Color color = prompts.chooseShorthand('Tell me your favorite color', rgb);
  print('You chose: ${color.about}');

  // Displays an interactive selection in the terminal.
  //
  // If you pass `interactive: false`, then the standard chooser prints
  // to multiple lines, but is often
  // clearer to read, and has more obvious semantics.
  //
  // You can also optionaly pass short `names`.
  color = prompts.choose('Choose another color', rgb,
      defaultsTo: Color.blue, names: ['r', 'g', 'b']);
  print(color.about);
}

class Color {
  final String name, description;

  const Color(this.name, this.description);

  static const Color red = Color('Red', 'The color of apples.'),
      blue = Color('Blue', 'The color of the sky.'),
      green = Color('Green', 'The color of leaves.');

  String get about => '$name - $description';

  @override
  String toString() => name;
}
