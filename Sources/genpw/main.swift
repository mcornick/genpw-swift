/* Copyright (c) 2020 Mark Cornick

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE. */

import ArgumentParser
import Foundation

struct Genpw: ParsableCommand {
    @Argument(help: .hidden)
    var bareLength: Int?
    @Option(help: "Length to generate.")
    var length = 16
    @Flag(inversion: .prefixedNo, help: "Include uppercase letters.")
    var upper = true
    @Flag(inversion: .prefixedNo, help: "Include lowercase letters.")
    var lower = true
    @Flag(inversion: .prefixedNo, help: "Include digits.")
    var digit = true

    func validate() throws {
        guard upper || lower || digit else {
            throw ValidationError("Cannot exclude all three character classes.")
        }
    }

    func minimumLength() -> Int {
        var minimum = 0
        if upper { minimum += 1 }
        if lower { minimum += 1 }
        if digit { minimum += 1 }
        return minimum
    }

    func isAcceptable(password: String) -> Bool {
        let hasUpper = password.rangeOfCharacter(from: .uppercaseLetters)
        let hasLower = password.rangeOfCharacter(from: .lowercaseLetters)
        let hasDigit = password.rangeOfCharacter(from: .decimalDigits)
        let upperOK = (!upper || hasUpper != nil)
        let lowerOK = (!lower || hasLower != nil)
        let digitOK = (!digit || hasDigit != nil)
        return upperOK && lowerOK && digitOK
    }

    func generate() throws -> String {
        guard length >= minimumLength() else {
            throw ValidationError("Length must be at least \(minimumLength()).")
        }

        let uppers = ["A", "B", "C", "D", "E", "F", "G", "H", "J", "K", "L",
                      "M", "N", "P", "Q", "R", "S", "T", "U", "V", "W", "X",
                      "Y", "Z"]
        let lowers = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k",
                      "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w",
                      "x", "y", "z"]
        let digits = ["2", "3", "4", "5", "6", "7", "8", "9"]

        var candidates: [String] = []
        if upper { candidates += uppers }
        if lower { candidates += lowers }
        if digit { candidates += digits }

        var characters: [String] = []
        let repeats = Int(length / candidates.count) + 1
        for _ in 0 ..< repeats {
            characters += candidates
        }

        var pwChars: [String] = []
        for _ in 0 ..< length {
            let charIndex = Int.random(in: 0 ..< characters.count)
            pwChars.append(characters.remove(at: charIndex))
        }
        let password = pwChars.joined(separator: "")
        return password
    }

    mutating func run() throws {
        if bareLength != nil {
            length = bareLength!
        }

        var password = ""
        while !isAcceptable(password: password) {
            password = try generate()
        }
        print(password)
    }
}

Genpw.main()
