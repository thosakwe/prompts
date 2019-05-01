import 'package:prompts/prompts.dart' as prompts;

main() {
  var albums = [
    'Music of My Mind',
    'Talking Book',
    'Innervisions',
    "Fulfillingness' First Finale",
    'Songs in the Key of Life'
  ];

  var album = prompts.chooseShorthand('Pick a classic album', albums);
  print('You chose: $album');

  album = prompts.choose('Pick another', albums);
  print('You chose: $album');

  album = prompts
      .choose('Pick yet another', albums, names: ['m', 't', 'i', 'f', 's']);
  print('You chose: $album');
}
