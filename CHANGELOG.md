# 1.3.1
* Completely disable interactive selection on Windows.
  * https://github.com/thosakwe/prompts/pull/3

# 1.3.0
* Make `choose` only print options once, and instead add `prompt`.
* Add `names` to `choose`.
* `conceal` was `true` in `chooseShorthand`; revert to `false`.
* *Always* use `AnsiCode.wrap`, to prevent "hanging colors."
* Always heed the `color` flag.
* Use VT100 codes for clearing lines, etc. (smoother, no jank)
    * http://www.climagic.org/mirrors/VT100_Escape_Codes.html

# 1.2.0
* Add password reading options.
* Pin against Dart 2.

# 1.1.0
* Add pretty colors to `get`.

# 1.0.0
Initial version
