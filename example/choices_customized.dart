import 'package:io/ansi.dart';
import 'package:prompts/prompts.dart' as prompts;

void main(List<String> args) {
  var albums = [
    'Music of My Mind',
    'Talking Book',
    'Innervisions',
    "Fulfillingness' First Finale",
    'Songs in the Key of Life'
  ];
  var album = prompts.choose('Pick your favorite classic album', albums,
      interactive: true,
      defaultsTo: 'Innervisions',
      names: ['m', 't', 'i', 'f', 'S'],
      selectedColor: backgroundCyan,
      selectedPrefix: '✅',
      unSelectedColor: cyan);
  prompts.printSelectMessage('You chose:', album,
      prefixColor: backgroundLightGreen, showColor: green);

  album = prompts.chooseShorthand('Pick a classic album', albums,
      inputColor: red, names: ['m', 't', 'i', 'f', 'S']);
  print('You chose: $album');

  album = prompts.choose(
    'Pick another',
    albums,
    interactive: false,
    nonInteractiveMenuColor: backgroundLightGreen,
  );
  print('You chose: $album');

  album = prompts.choose('Pick yet another', albums,
      names: ['m', 't', 'i', 'f', 's'], interactive: false);
  print('You chose: $album');
}
