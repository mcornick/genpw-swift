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

import class Foundation.Bundle
import XCTest

@available(OSX 10.13, *)
final class genpwTests: XCTestCase {
    func execute(arguments: [String]) throws -> (Int32, String) {
        let binary = productsDirectory.appendingPathComponent("genpw")
        let process = Process()
        process.executableURL = binary
        process.arguments = arguments
        let pipe = Pipe()
        process.standardOutput = pipe
        try process.run()
        process.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        let password = output!.trimmingCharacters(in: .whitespacesAndNewlines)
        return (process.terminationStatus, password)
    }

    /// Assert that no provided length uses a default length.
    func testDefaultLength() throws {
        let (_, output) = try execute(arguments: [])
        XCTAssertEqual(16, output.count)
    }

    /// Assert that a valid provided length uses that length.
    func testValidLengthOption() throws {
        let (_, output) = try execute(arguments: ["--length", "8"])
        XCTAssertEqual(8, output.count)
    }

    /// Assert that an invalid provided length fails.
    func testInvalidLengthOption() throws {
        let (status, _) = try execute(arguments: ["--length", "eight"])
        XCTAssertEqual(64, status)
    }

    /// Assert that a length that is too short fails.
    func testLengthOptionTooShort() throws {
        let (status, _) = try execute(arguments: ["--length", "0"])
        XCTAssertEqual(64, status)
    }

    /// Helper for flag tests.
    func doFlagAssertions(password: String, wantUpper: Bool, wantLower: Bool, wantDigit: Bool) {
        let hasUpper = password.rangeOfCharacter(from: .uppercaseLetters) != nil ? true : false
        let hasLower = password.rangeOfCharacter(from: .lowercaseLetters) != nil ? true : false
        let hasDigit = password.rangeOfCharacter(from: .decimalDigits) != nil ? true : false
        XCTAssertEqual(wantUpper, hasUpper)
        XCTAssertEqual(wantLower, hasLower)
        XCTAssertEqual(wantDigit, hasDigit)
    }

    /// Assert that --no-upper excludes uppercase and includes lowercase and digits.
    func testNoUpperFlag() throws {
        let (_, output) = try execute(arguments: ["--no-upper"])
        doFlagAssertions(password: output, wantUpper: false, wantLower: true, wantDigit: true)
    }

    /// Assert that --no-lower excludes lowercase and includes uppercase and hasDigit.
    func testNoLowerFlag() throws {
        let (_, output) = try execute(arguments: ["--no-lower"])
        doFlagAssertions(password: output, wantUpper: true, wantLower: false, wantDigit: true)
    }

    /// Assert that --no-digit excludes hasDigit and includes lowercase and uppercase.
    func testNoDigitFlag() throws {
        let (_, output) = try execute(arguments: ["--no-digit"])
        doFlagAssertions(password: output, wantUpper: true, wantLower: true, wantDigit: false)
    }

    /// Assert that --no-upper --no-lower excludes uppercase and lowercase and includes digits.
    func testNoUpperFlagNoLowerFlag() throws {
        let (_, output) = try execute(arguments: ["--no-upper", "--no-lower"])
        doFlagAssertions(password: output, wantUpper: false, wantLower: false, wantDigit: true)
    }

    /// Assert that --no-upper --no-digit excludes uppercase and digits and includes lowercase.
    func testNoUpperFlagNoDigitFlag() throws {
        let (_, output) = try execute(arguments: ["--no-upper", "--no-digit"])
        doFlagAssertions(password: output, wantUpper: false, wantLower: true, wantDigit: false)
    }

    /// Assert that --no-digit --no-lower excludes digits and lowercase and includes uppercase.
    func testNoDigitFlagNoLowerFlag() throws {
        let (_, output) = try execute(arguments: ["--no-digit", "--no-lower"])
        doFlagAssertions(password: output, wantUpper: true, wantLower: false, wantDigit: false)
    }

    /// Assert that none of --no-upper, --no-lower, --no-digit includes all three classes.
    func testDefaultFlags() throws {
        let (_, output) = try execute(arguments: [])
        doFlagAssertions(password: output, wantUpper: true, wantLower: true, wantDigit: true)
    }

    /// Assert that all of --no-upper, --no-lower, --no-digit fails.
    func testNoUpperFlagNoLowerFlagNoDigitFlag() throws {
        let (status, _) = try execute(arguments: ["--no-upper", "--no-lower", "--no-digit"])
        XCTAssertEqual(64, status)
    }

    /// Assert that a valid bare length is accepted.
    func testBareLength() throws {
        let (_, output) = try execute(arguments: ["8"])
        XCTAssertEqual(8, output.count)
    }

    /// Assert that a valid bare length overrides the --length flag.
    func testBareLengthOverridesLengthOption() throws {
        let (_, output) = try execute(arguments: ["8", "--length", "12"])
        XCTAssertEqual(8, output.count)
    }

    /// Assert that an invalid bare length fails.
    func testInvalidBareLength() throws {
        let (status, _) = try execute(arguments: ["eight"])
        XCTAssertEqual(64, status)
    }

    /// Assert that a bare length which is too short fails.
    func testBareLengthLengthOptionTooShort() throws {
        let (status, _) = try execute(arguments: ["0"])
        XCTAssertEqual(64, status)
    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
        #if os(macOS)
            for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
                return bundle.bundleURL.deletingLastPathComponent()
            }
            fatalError("couldn't find the products directory")
        #else
            return Bundle.main.bundleURL
        #endif
    }

    static var allTests = [
        ("testBareLength", testBareLength),
        ("testBareLengthLengthOptionTooShort", testBareLengthLengthOptionTooShort),
        ("testBareLengthOverridesLengthOption", testBareLengthOverridesLengthOption),
        ("testDefaultFlags", testDefaultFlags),
        ("testDefaultLength", testDefaultLength),
        ("testInvalidBareLength", testInvalidBareLength),
        ("testInvalidLengthOption", testInvalidLengthOption),
        ("testLengthOptionTooShort", testLengthOptionTooShort),
        ("testNoDigitFlag", testNoDigitFlag),
        ("testNoDigitFlagNoLowerFlag", testNoDigitFlagNoLowerFlag),
        ("testNoLowerFlag", testNoLowerFlag),
        ("testNoUpperFlag", testNoUpperFlag),
        ("testNoUpperFlagNoDigitFlag", testNoUpperFlagNoDigitFlag),
        ("testNoUpperFlagNoLowerFlag", testNoUpperFlagNoLowerFlag),
        ("testNoUpperFlagNoLowerFlagNoDigitFlag", testNoUpperFlagNoLowerFlagNoDigitFlag),
        ("testValidLengthOption", testValidLengthOption),
    ]
}
