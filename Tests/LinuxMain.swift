import XCTest

import genpwTests

var tests = [XCTestCaseEntry]()
tests += genpwTests.allTests()
XCTMain(tests)
