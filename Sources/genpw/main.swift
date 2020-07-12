import ArgumentParser

struct Genpw: ParsableCommand {
    @Option(help: "Length to generate (default 16.)")
    var length: Int?
    @Flag(name: [.customLong("no-upper")], help: "Exclude uppercase letters.")
    var noUpper = false
    @Flag(name: [.customLong("no-lower")], help: "Exclude lowercase letters.")
    var noLower = false
    @Flag(name: [.customLong("no-digit")], help: "Exclude digits.")
    var noDigit = false

    func run() throws {
        if (noUpper && noLower && noDigit) {
            throw RuntimeError("Cannot exclude all three character classes.")
        }

        let uppers = [ "A", "B", "C", "D", "E", "F", "G", "H", "J", "K", "L",
                       "M", "N", "P", "Q", "R", "S", "T", "U", "V", "W", "X",
                       "Y", "Z" ]
        let lowers = [ "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k",
                       "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w",
                       "x", "y", "z" ]
        let digits = [ "2", "3", "4", "5", "6", "7", "8", "9" ]

        var characters: [String] = []
        if (!noUpper) {
            characters += uppers
        }
        if (!noLower) {
            characters += lowers
        }
        if (!noDigit) {
            characters += digits
        }

        var pw = [""]

        let passes = length ?? 16
        for _ in 0..<passes {
            let i = Int.random(in: 0..<characters.count)
            pw.append(characters[i])
        }
        let password = pw.joined(separator: "")
        print(password)
    }
}

struct RuntimeError: Error, CustomStringConvertible {
    var description: String
    init(_ description: String) {
        self.description = description
    }
}

Genpw.main()
