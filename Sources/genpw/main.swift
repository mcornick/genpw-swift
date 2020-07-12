let characters = [ "A", "B", "C", "D", "E", "F", "G", "H", "J", "K", "L", "M",
    "N", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c",
    "d", "e", "f", "g", "h", "i", "j", "k", "m", "n", "o", "p", "q", "r", "s",
    "t", "u", "v", "w", "x", "y", "z", "2", "3", "4", "5", "6", "7", "8", "9" ]
let arguments = CommandLine.arguments
var length = 0
if(arguments.count > 1) {
    length = Int(arguments[1]) ?? 16
} else {
    length = 16
}

var pw = [""]
for _ in 0..<length {
    let i = Int.random(in: 0..<characters.count)
    pw.append(characters[i])
}

let password = pw.joined(separator: "")
print(password)
