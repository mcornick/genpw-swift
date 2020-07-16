# genpw (in Swift)

This is a port of my [genpw](https://github.com/markcornick/genpw)
program from Go to Swift. I'm doing this to learn some Swift, not to provide
a 1:1 port. Nevertheless, aside from a few differences in command line
flags, it now has feature parity with the Go version.

Passwords are, by default, chosen from the union of three character
classes:

- all upper-case letters except I and O
- all lower-case letters except l
- the digits 2 through 9

0 and O are not used to avoid confusion with each other when passwords
are displayed in sans-serif fonts. I, l, and 1 are not used for the same
reason.

Options can be given to omit any one or any two of these character
classes. For instance, you can omit uppercase letters and digits by
passing `--no-upper --no-digit` to `genpw`. This will return a
password composed only of lowercase letters.

Passwords are guaranteed to contain at least one of each selected
character class. The default length is 16. genpw will create a password
of any length greater than or equal to the number of character classes
selected.

If the password length is less than or equal to the total number of
characters selected, genpw will not repeat characters within the
generated password.

## Installation

This package targets Swift 5.2. On macOS, make sure you have Xcode 11.5
installed. On Linux, make sure you've installed Swift 5.2 from the
[Swift download site](https://swift.org/download/#releases).

Run `swift build -c release` in the top level directory. Copy the generated
`.build/release/genpw` binary to wherever you like.

## Usage

```bash
$ genpw -help
USAGE: genpw [--length <length>] [--upper] [--no-upper] [--lower] [--no-lower] [--digit] [--no-digit]

OPTIONS:
  --length <length>       Length to generate. (default: 16)
  --upper/--no-upper      Include uppercase letters. (default: true)
  --lower/--no-lower      Include lowercase letters. (default: true)
  --digit/--no-digit      Include digits. (default: true)
  -h, --help              Show help information.

$ genpw
h6ECtbDZPnRddHV7
$ genpw --length 8
XdWod8f8
$ genpw --length 64
QhESpeyPDidxV9kFNCrJqeMa4XUYbET4B3s5oGA8kYsV6XwDKHrCL7wojGZm9gj5
$ genpw --length 0
Error: Length must be at least 3.
$ genpw --no-lower
387HNFDEUW4YGMZA
$ genpw --no-upper --length 8
hcsym6tj
$ genpw --no-lower --no-upper --length 32
92992759356835354563826487673794
$ genpw --no-lower --no-upper --no-digit
Error: Cannot exclude all three character classes.
```

## License

genpw is available as open source under the terms of the MIT License.
