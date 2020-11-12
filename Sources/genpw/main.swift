/*
 Copyright (c) 2020 Mark Cornick

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
 SOFTWARE.
 */

import ArgumentParser
import Foundation

// The command, implemented with ArgumentParser.
struct Genpw: ParsableCommand {
    // ArgumentParser definitions.
    @Option(name: [.short, .long],
            help: "Length to generate.")
    var length = 16
    @Flag(name: [.customShort("U"), .long],
          help: "Exclude uppercase letters.")
    var noUpper = false
    @Flag(name: [.customShort("u"), .long],
          help: "Exclude lowercase letters.")
    var noLower = false
    @Flag(name: [.customShort("d"), .long],
          help: "Exclude digits.")
    var noDigit = false

    /**
     Validates options and flags.

     - Throws: `ValidationError` if length is too short or all three
               character classes are excluded.
     */

    func validate() throws {
        guard length >= minimumLength() else {
            throw ValidationError("Length must be at least \(minimumLength()).")
        }
        guard !noUpper || !noLower || !noDigit else {
            throw ValidationError("Cannot exclude all three character classes.")
        }
    }

    /**
     Returns minimum length based on flags selected.

     - Returns: An Int counting the flags selected.
     */
    func minimumLength() -> Int {
        var minimum = 0
        if !noUpper { minimum += 1 }
        if !noLower { minimum += 1 }
        if !noDigit { minimum += 1 }
        return minimum
    }

    /** Tests that all requested classes are present.
     - Parameter password: The proposed password to check.

     - Returns: A Bool indicating acceptability.
     */
    func isAcceptable(password: String) -> Bool {
        let hasUpper = password.rangeOfCharacter(from: .uppercaseLetters)
        let hasLower = password.rangeOfCharacter(from: .lowercaseLetters)
        let hasDigit = password.rangeOfCharacter(from: .decimalDigits)
        let upperOK = (noUpper || hasUpper != nil)
        let lowerOK = (noLower || hasLower != nil)
        let digitOK = (noDigit || hasDigit != nil)
        return upperOK && lowerOK && digitOK
    }

    /** Generate a password.

     - Returns: The password as a String.
     */
    func generate() -> String {
        // The characters from which we assemble passwords.
        let uppers = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K",
                      "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V",
                      "W", "X", "Y", "Z"]
        let lowers = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k",
                      "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v",
                      "w", "x", "y", "z"]
        let digits = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

        // Combine the selected character classes to make a single array.
        var selections: [String] = []
        if !noUpper { selections += uppers }
        if !noLower { selections += lowers }
        if !noDigit { selections += digits }

        // Assemble a pool large enough to accomodate the requested length.
        var pool: [String] = []
        let repeats = Int(length / selections.count) + 1
        for _ in 0 ..< repeats {
            pool += selections
        }

        // Assemble a set of characters from the pool to make a password.
        var password: [String] = []
        for _ in 0 ..< length {
            let charIndex = Int.random(in: 0 ..< pool.count)
            password.append(pool.remove(at: charIndex))
        }

        // Return the password as a string.
        return password.joined(separator: "")
    }

    /// Main function.
    func run() {
        // Generate passwords until we get an acceptable one.
        var password = ""
        while !isAcceptable(password: password) {
            password = generate()
        }

        // Print it.
        print(password)
    }
}

Genpw.main()
