//===----------------------------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Argument Parser open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
import ArgumentParserTestHelpers
import ArgumentParser

// MARK: Arguments at multiple layers, all unrecognized arguments
fileprivate struct OuterArgCommand_1: ParsableCommand {
  static let configuration = CommandConfiguration(subcommands: [InnerArgCommand.self])

  @Argument() var argument: String

  struct InnerArgCommand: ParsableCommand {
    @OptionGroup() var outer: OuterArgCommand_1

    @Argument(parsing: .allUnrecognized)
    var query: [String] = []
  }
}

extension NestedCommandEndToEndTests {
  func testParsing_multipleLayersAllUnrecognizedInner() throws {
    AssertParseCommand(OuterArgCommand_1.self, OuterArgCommand_1.InnerArgCommand.self, ["outer", "inner-arg-command"]) { inner in
      XCTAssertEqual(inner.outer.argument, "outer")
      XCTAssertEqual(inner.query, [])
    }
  }

  func testParsing_multipleLayersAllUnrecognizedInner_2() throws {
    AssertParseCommand(OuterArgCommand_1.self, OuterArgCommand_1.InnerArgCommand.self, ["outer", "inner-arg-command", "a", "b", "c"]) { inner in
      XCTAssertEqual(inner.outer.argument, "outer")
      XCTAssertEqual(inner.query, ["a", "b", "c"])
    }
  }

  func testParsing_multipleLayersAllUnrecognizedInner_3() throws {
    AssertParseCommand(OuterArgCommand_1.self, OuterArgCommand_1.InnerArgCommand.self, ["outer", "inner-arg-command", "--include", "a", "--exclude", "b"]) { inner in
      XCTAssertEqual(inner.outer.argument, "outer")
      XCTAssertEqual(inner.query, ["--include", "a", "--exclude", "b"])
    }
  }
}

// MARK: Arguments at multiple layers, all unrecognized arguments mixed with an argument and options
fileprivate struct OuterArgCommand_2: ParsableCommand {
  static let configuration = CommandConfiguration(subcommands: [InnerArgCommand.self])

  @Argument() var argument: String

  struct InnerArgCommand: ParsableCommand {
    @OptionGroup() var outer: OuterArgCommand_2

    @Argument
    var first: Int

    @Option
    var feature: [Int] = []

    @Argument(parsing: .allUnrecognized)
    var query: [String] = []
  }
}

extension NestedCommandEndToEndTests {
  func testParsing_multipleLayersAllUnrecognizedInnerWithExtraArgs() throws {
    AssertParseCommand(OuterArgCommand_2.self, OuterArgCommand_2.InnerArgCommand.self, ["outer", "inner-arg-command", "24"]) { inner in
      XCTAssertEqual(inner.outer.argument, "outer")
      XCTAssertEqual(inner.first, 24)
      XCTAssertEqual(inner.query, [])
    }
  }

  func testParsing_multipleLayersAllUnrecognizedInnerWithExtraArgs_2() throws {
    AssertParseCommand(OuterArgCommand_2.self, OuterArgCommand_2.InnerArgCommand.self, ["outer", "inner-arg-command", "24", "--feature", "1", "--feature", "2"]) { inner in
      XCTAssertEqual(inner.outer.argument, "outer")
      XCTAssertEqual(inner.first, 24)
      XCTAssertEqual(inner.feature, [1, 2])
      XCTAssertEqual(inner.query, [])
    }
  }

  func testParsing_multipleLayersAllUnrecognizedInnerWithExtraArgs_3() throws {
    AssertParseCommand(OuterArgCommand_2.self, OuterArgCommand_2.InnerArgCommand.self, ["outer", "inner-arg-command", "24", "--enable", "example", "--feature", "1", "--disable", "another", "--feature", "2", "--final"]) { inner in
      XCTAssertEqual(inner.outer.argument, "outer")
      XCTAssertEqual(inner.first, 24)
      XCTAssertEqual(inner.feature, [1, 2])
      XCTAssertEqual(inner.query, ["--enable", "example", "--disable", "another", "--final"])
    }
  }
}
