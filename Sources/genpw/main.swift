let arguments = CommandLine.arguments
var length = 0
if(arguments.count > 1) {
    length = Int(arguments[1]) ?? 16
} else {
    length = 16
}

var pw = [""]
for _ in 0..<length {
    pw.append("X")
}

let password = pw.joined(separator: "")
print(password)
