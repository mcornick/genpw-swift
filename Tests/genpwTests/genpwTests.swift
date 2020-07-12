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

import XCTest
import class Foundation.Bundle

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
        return(process.terminationStatus, password)
    }
    
    func testNoArguments() throws {
        let (_, output) = try execute(arguments: [])
        XCTAssertEqual(16, output.count)
    }

    func testLengthOption() throws {
        let (_, output) = try execute(arguments: ["--length", "8"])
        XCTAssertEqual(8, output.count)
    }

    func testBadLength() throws {
        let (status, _) = try execute(arguments: ["--length", "eight"])
        XCTAssertEqual(64, status)
    }
    
    func testUpperFlag() throws {
        let (_, output) = try execute(arguments: ["--no-upper"])
        let uppers = output.rangeOfCharacter(from: .capitalizedLetters)
        XCTAssert(uppers == nil)
    }

    func testLowerFlag() throws {
        let (_, output) = try execute(arguments: ["--no-lower"])
        let lowers = output.rangeOfCharacter(from: .lowercaseLetters)
        XCTAssert(lowers == nil)
    }

    func testDigitFlag() throws {
        let (_, output) = try execute(arguments: ["--no-digit"])
        let digits = output.rangeOfCharacter(from: .decimalDigits)
        XCTAssert(digits == nil)
    }

    func testBadFlags() throws {
        let (status, _) = try execute(arguments: ["--no-upper", "--no-lower", "--no-digit"])
        XCTAssertEqual(1, status)
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
        ("testNoArguments", testNoArguments),
        ("testLengthOption", testLengthOption),
        ("testBadLength", testBadLength),
        ("testUpperFlag", testUpperFlag),
        ("testLowerFlag", testLowerFlag),
        ("testDigitFlag", testDigitFlag),
    ]
}
