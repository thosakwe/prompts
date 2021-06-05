import 'package:prompts/prompts.dart' as prompts;

void main() {
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
      names: ['m', 't', 'i', 'f', 'S']);
  print('You chose: $album');

  album = prompts.chooseShorthand('Pick a classic album', albums);
  print('You chose: $album');

  album = prompts.choose('Pick another', albums, interactive: false);
  print('You chose: $album');

  album = prompts.choose('Pick yet another', albums,
      names: ['m', 't', 'i', 'f', 's'], interactive: false);
  print('You chose: $album');
}
