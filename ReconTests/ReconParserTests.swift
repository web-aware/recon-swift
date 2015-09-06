import XCTest
@testable import Recon

class ReconParserTests: XCTestCase {
  func testParseEmptyInput() {
    XCTAssertEqual(recon(""), Value.Absent)
  }

  func testParseEmptyRecords() {
    XCTAssertEqual(recon("{}"), [])
  }

  func testParseEmptyMarkup() {
    XCTAssertEqual(recon("[]"), [])
  }

  func testParseEmptyStrings() {
    XCTAssertEqual(recon("\"\""), "")
  }

  func testParseNonEmptyStrings() {
    XCTAssertEqual(recon("\"test\""), "test")
  }

  func testParseStringsWithEscapes() {
    XCTAssertEqual(recon("\"\\\"\\\\\\/\\@\\{\\}\\[\\]\\b\\f\\n\\r\\t\""), "\"\\/@{}[]\u{8}\u{C}\n\r\t")
  }

  func testParseIdentifiers() {
    XCTAssertEqual(recon("test"), "test")
  }

  func testParseEmptyData() {
    XCTAssertEqual(recon("%"), Value(base64: ""))
  }

  func testParseNonEmptyData() {
    XCTAssertEqual(recon("%AAAA"), Value(base64: "AAAA"))
    XCTAssertEqual(recon("%AAA="), Value(base64: "AAA="))
    XCTAssertEqual(recon("%AA=="), Value(base64: "AA=="))
    XCTAssertEqual(recon("%ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789/+"), Value(base64: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789/+"))
  }

  func testParsePositiveIntegers() {
    XCTAssertEqual(recon("0"), 0)
    XCTAssertEqual(recon("1"), 1)
    XCTAssertEqual(recon("5"), 5)
    XCTAssertEqual(recon("10"), 10)
    XCTAssertEqual(recon("11"), 11)
    XCTAssertEqual(recon("15"), 15)
  }

  func testParseNegativeInetegrs() {
    XCTAssertEqual(recon("-0"), -0)
    XCTAssertEqual(recon("-1"), -1)
    XCTAssertEqual(recon("-5"), -5)
    XCTAssertEqual(recon("-10"), -10)
    XCTAssertEqual(recon("-11"), -11)
    XCTAssertEqual(recon("-15"), -15)
  }

  func testParsePositiveDecimals() {
    XCTAssertEqual(recon("0.0"), 0.0)
    XCTAssertEqual(recon("0.5"), 0.5)
    XCTAssertEqual(recon("1.0"), 1.0)
    XCTAssertEqual(recon("1.5"), 1.5)
    XCTAssertEqual(recon("10.0"), 10.0)
    XCTAssertEqual(recon("10.5"), 10.5)
  }

  func testParseNegativeDecimals() {
    XCTAssertEqual(recon("-0.0"), -0.0)
    XCTAssertEqual(recon("-0.5"), -0.5)
    XCTAssertEqual(recon("-1.0"), -1.0)
    XCTAssertEqual(recon("-1.5"), -1.5)
    XCTAssertEqual(recon("-10.0"), -10.0)
    XCTAssertEqual(recon("-10.5"), -10.5)
  }

  func testParsePositiveExponentials() {
    XCTAssertEqual(recon("4e2"), 400.0)
    XCTAssertEqual(recon("4E2"), 400.0)
    XCTAssertEqual(recon("4e+2"), 400.0)
    XCTAssertEqual(recon("4E+2"), 400.0)
    XCTAssertEqual(recon("4e-2"), 0.04)
    XCTAssertEqual(recon("4E-2"), 0.04)
    XCTAssertEqual(recon("4.0e2"), 400.0)
    XCTAssertEqual(recon("4.0E2"), 400.0)
    XCTAssertEqual(recon("4.0e+2"), 400.0)
    XCTAssertEqual(recon("4.0E+2"), 400.0)
    XCTAssertEqual(recon("4.0e-2"), 0.04)
    XCTAssertEqual(recon("4.0E-2"), 0.04)
  }

  func testParseNegativeExponentials() {
    XCTAssertEqual(recon("-4e2"), -400.0)
    XCTAssertEqual(recon("-4E2"), -400.0)
    XCTAssertEqual(recon("-4e+2"), -400.0)
    XCTAssertEqual(recon("-4E+2"), -400.0)
    XCTAssertEqual(recon("-4e-2"), -0.04)
    XCTAssertEqual(recon("-4E-2"), -0.04)
    XCTAssertEqual(recon("-4.0e2"), -400.0)
    XCTAssertEqual(recon("-4.0E2"), -400.0)
    XCTAssertEqual(recon("-4.0e+2"), -400.0)
    XCTAssertEqual(recon("-4.0E+2"), -400.0)
    XCTAssertEqual(recon("-4.0e-2"), -0.04)
    XCTAssertEqual(recon("-4.0E-2"), -0.04)
  }

  func testParseBools() {
    XCTAssertEqual(recon("true"), Value.True)
    XCTAssertEqual(recon("false"), Value.False)
  }

  func testParseSingleValuesWithTrailingCommas() {
    XCTAssertEqual(recon("1,"), 1)
  }

  func testParseSingleValuesWithTrailingSemicolons() {
    XCTAssertEqual(recon("1;"), 1)
  }

  func testParseMultipleCommaSeparatedItems() {
    XCTAssertEqual(recon("  1, 2,3 ,4  "), [1, 2, 3, 4])
    XCTAssertEqual(recon("{ 1, 2,3 ,4 }"), [1, 2, 3, 4])
  }

  func testParseMultipleSemicolonSeparatedItems() {
    XCTAssertEqual(recon("  1; 2;3 ;4  "), [1, 2, 3, 4])
    XCTAssertEqual(recon("{ 1; 2;3 ;4 }"), [1, 2, 3, 4])
  }

  func testParseMultipleItemsWithTrailingCommas() {
    XCTAssertEqual(recon("  1, 2,3 ,4,  "), [1, 2, 3, 4])
    XCTAssertEqual(recon("{ 1, 2,3 ,4, }"), [1, 2, 3, 4])
  }

  func testParseMultipleItemsWithTrailingSemicolons() {
    XCTAssertEqual(recon("  1; 2;3 ;4;  "), [1, 2, 3, 4])
    XCTAssertEqual(recon("{ 1; 2;3 ;4; }"), [1, 2, 3, 4])
  }

  func testParseMultipleNewlineSeparatedItems() {
    XCTAssertEqual(recon("  1\n 2\n3 \n4  "), [1, 2, 3, 4])
    XCTAssertEqual(recon("{ 1\n 2\n3 \n4 }"), [1, 2, 3, 4])
  }

  func testParseMultipleItemsWithMixedSeparators() {
    XCTAssertEqual(recon("  1, 2\n3 \n4; 5  "), [1, 2, 3, 4, 5])
    XCTAssertEqual(recon("{ 1, 2\n3 \n4; 5 }"), [1, 2, 3, 4, 5])
  }

  func testParseMultipleCommaNewlineSeparatedItems() {
    XCTAssertEqual(recon(" \n 1,\n 2,\n3 \n "), [1, 2, 3])
    XCTAssertEqual(recon("{\n 1,\n 2,\n3 \n}"), [1, 2, 3])
  }

  func testParseMultipleSemicolonNewlineSeparatedItems() {
    XCTAssertEqual(recon(" \n 1;\n 2;\n3 \n "), [1, 2, 3])
    XCTAssertEqual(recon("{\n 1;\n 2;\n3 \n}"), [1, 2, 3])
  }

  func testParseHeterogeneousTopLevelItemsAsRecord() {
    XCTAssertEqual(recon("  extant:\n  record: {}\n  markup: []\n  \"\"\n  %AA==\n  integer: 0\n  decimal: 0.0\n  true\n  false\n"), [Slot("extant"), Slot("record", []), Slot("markup", []), "", Item(base64: "AA=="), Slot("integer", 0), Slot("decimal", 0.0), true, false])
  }

  func testParseHeterogeneousItemsInRecord() {
    XCTAssertEqual(recon("{\n  extant:\n  record: {}\n  markup: []\n  \"\"\n  %AA==\n  integer: 0\n  decimal: 0.0\n  true\n  false\n}"), [Slot("extant"), Slot("record", []), Slot("markup", []), "", Item(base64: "AA=="), Slot("integer", 0), Slot("decimal", 0.0), true, false])
  }

  func testParseSingleExtantAttributesWithNoParameters() {
    XCTAssertEqual(recon("@test"), [Attr("test")])
  }

  func testParseSingleExtantAttributesWithEmptyParameters() {
    XCTAssertEqual(recon("@test()"), [Attr("test")])
  }

  func testParseSingleExtantAttributesWithSingleParameters() {
    XCTAssertEqual(recon("@hello({})"), [Attr("hello", [])])
    XCTAssertEqual(recon("@hello([world])"), [Attr("hello", ["world"])])
    XCTAssertEqual(recon("@hello(\"world\")"), [Attr("hello", "world")])
    XCTAssertEqual(recon("@hello(42)"), [Attr("hello", 42)])
    XCTAssertEqual(recon("@hello(true)"), [Attr("hello", true)])
    XCTAssertEqual(recon("@hello(false)"), [Attr("hello", false)])
  }

  func testParseSingleExtantAttributesWithMultipleParameters() {
    XCTAssertEqual(recon("@hello(\"world\", %AA==, 42, true)"), [Attr("hello", ["world", Item(base64: "AA=="), 42, true])])
    XCTAssertEqual(recon("@hello(\"world\"; %AA==; 42; true)"), [Attr("hello", ["world", Item(base64: "AA=="), 42, true])])
    XCTAssertEqual(recon("@hello(\"world\"\n%AA==\n42\ntrue)"), [Attr("hello", ["world", Item(base64: "AA=="), 42, true])])
  }

  func testParseSingleExtantAttributesWithNamedParameters() {
    XCTAssertEqual(recon("@hello(name: \"world\")"), [Attr("hello", [Slot("name", "world")])])
    XCTAssertEqual(recon("@hello(name: \"world\", data: %AA==, number: 42, false)"), [Attr("hello", [Slot("name", "world"), Slot("data", Value(base64: "AA==")), Slot("number", 42), false])])
  }

  func testParseMultipleExtantAttributesWithNoParameters() {
    XCTAssertEqual(recon("@a@b"), [Attr("a"), Attr("b")])
    XCTAssertEqual(recon("@a @b"), [Attr("a"), Attr("b")])
  }

  func testParseMultipleExtantAttributesWithEmptyParameters() {
    XCTAssertEqual(recon("@a()@b()"), [Attr("a"), Attr("b")])
    XCTAssertEqual(recon("@a() @b()"), [Attr("a"), Attr("b")])
  }

  func testParseMultipleExtantAttributesWithSingleParameters() {
    XCTAssertEqual(recon("@a({})@b([])"), [Attr("a", []), Attr("b", [])])
    XCTAssertEqual(recon("@a(\"test\") @b(42)"), [Attr("a", "test"), Attr("b", 42)])
    XCTAssertEqual(recon("@a(true) @b(false)"), [Attr("a", true), Attr("b", false)])
  }

  func testParseMultipleExtantAttributesWithComplexParameters() {
    XCTAssertEqual(recon("@hello(\"world\", 42) @test(name: \"parse\", pending: false)"), [Attr("hello", ["world", 42]), Attr("test", [Slot("name", "parse"), Slot("pending", false)])])
  }

  func testParsePrefixAttributedEmptyRecords() {
    XCTAssertEqual(recon("@hello {}"), [Attr("hello")])
    XCTAssertEqual(recon("@hello() {}"), [Attr("hello")])
    XCTAssertEqual(recon("@hello(\"world\") {}"), [Attr("hello", "world")])
    XCTAssertEqual(recon("@hello(name: \"world\") {}"), [Attr("hello", [Slot("name", "world")])])
  }

  func testParsePrefixAttributedNonEmptyRecords() {
    XCTAssertEqual(recon("@hello { {}, [] }"), [Attr("hello"), [], []])
    XCTAssertEqual(recon("@hello() { \"world\", 42 }"), [Attr("hello"), "world", 42])
    XCTAssertEqual(recon("@hello(\"world\") { number: 42, true }"), [Attr("hello", "world"), Slot("number", 42), true])
    XCTAssertEqual(recon("@hello(name: \"world\") { {1,2} }"), [Attr("hello", [Slot("name", "world")]), [1, 2]])
  }

  func testParsePrefixAttributedEmptyMarkup() {
    XCTAssertEqual(recon("@hello []"), [Attr("hello")])
    XCTAssertEqual(recon("@hello() []"), [Attr("hello")])
    XCTAssertEqual(recon("@hello(\"world\") []"), [Attr("hello", "world")])
    XCTAssertEqual(recon("@hello(name: \"world\") []"), [Attr("hello", [Slot("name", "world")])])
  }

  func testParsePrefixAttributedNonEmptyMarkup() {
    XCTAssertEqual(recon("@hello [test]"), [Attr("hello"), "test"])
    XCTAssertEqual(recon("@hello() [test]"), [Attr("hello"), "test"])
    XCTAssertEqual(recon("@hello(\"world\") [test]"), [Attr("hello", "world"), "test"])
    XCTAssertEqual(recon("@hello(name: \"world\") [test]"), [Attr("hello", [Slot("name", "world")]), "test"])
  }

  func testParsePrefixAttributedEmptyStrings() {
    XCTAssertEqual(recon("@hello \"\""), [Attr("hello"), ""])
    XCTAssertEqual(recon("@hello() \"\""), [Attr("hello"), ""])
    XCTAssertEqual(recon("@hello(\"world\") \"\""), [Attr("hello", "world"), ""])
    XCTAssertEqual(recon("@hello(name: \"world\") \"\""), [Attr("hello", [Slot("name", "world")]), ""])
  }

  func testParsePrefixAttributedNonEmptyStrings() {
    XCTAssertEqual(recon("@hello \"test\""), [Attr("hello"), "test"])
    XCTAssertEqual(recon("@hello() \"test\""), [Attr("hello"), "test"])
    XCTAssertEqual(recon("@hello(\"world\") \"test\""), [Attr("hello", "world"), "test"])
    XCTAssertEqual(recon("@hello(name: \"world\") \"test\""), [Attr("hello", [Slot("name", "world")]), "test"])
  }

  func testParsePrefixAttributedEmptyData() {
    XCTAssertEqual(recon("@hello %"), [Attr("hello"), Item(base64: "")])
    XCTAssertEqual(recon("@hello() %"), [Attr("hello"),  Item(base64: "")])
    XCTAssertEqual(recon("@hello(\"world\") %"), [Attr("hello", "world"),  Item(base64: "")])
    XCTAssertEqual(recon("@hello(name: \"world\") %"), [Attr("hello", [Slot("name", "world")]),  Item(base64: "")])
  }

  func testParsePrefixAttributedNonEmptyData() {
    XCTAssertEqual(recon("@hello %AA=="), [Attr("hello"), Item(base64: "AA==")])
    XCTAssertEqual(recon("@hello() %AAA="), [Attr("hello"),  Item(base64: "AAA=")])
    XCTAssertEqual(recon("@hello(\"world\") %AAAA"), [Attr("hello", "world"),  Item(base64: "AAAA")])
    XCTAssertEqual(recon("@hello(name: \"world\") %ABCDabcd12+/"), [Attr("hello", [Slot("name", "world")]),  Item(base64: "ABCDabcd12+/")])
  }

  func testParsePrefixAttributedNumbers() {
    XCTAssertEqual(recon("@hello 42"), [Attr("hello"), 42])
    XCTAssertEqual(recon("@hello() -42"), [Attr("hello"), -42])
    XCTAssertEqual(recon("@hello(\"world\") 42.0"), [Attr("hello", "world"), 42.0])
    XCTAssertEqual(recon("@hello(name: \"world\") -42.0"), [Attr("hello", [Slot("name", "world")]), -42.0])
  }

  func testParsePrefixAttributedBools() {
    XCTAssertEqual(recon("@hello true"), [Attr("hello"), true])
    XCTAssertEqual(recon("@hello() false"), [Attr("hello"), false])
    XCTAssertEqual(recon("@hello(\"world\") true"), [Attr("hello", "world"), true])
    XCTAssertEqual(recon("@hello(name: \"world\") false"), [Attr("hello", [Slot("name", "world")]), false])
  }

  func testParsePostfixAttributedEmptyRecords() {
    XCTAssertEqual(recon("{} @signed"), [Attr("signed")])
    XCTAssertEqual(recon("{} @signed()"), [Attr("signed")])
    XCTAssertEqual(recon("{} @signed(\"me\")"), [Attr("signed", "me")])
    XCTAssertEqual(recon("{} @signed(by: \"me\")"), [Attr("signed", [Slot("by", "me")])])
  }

  func testParsePostfixAttributedNonEmptyRecords() {
    XCTAssertEqual(recon("{ {}, [] } @signed"), [[], [], Attr("signed")])
    XCTAssertEqual(recon("{ \"world\", 42 } @signed()"), ["world", 42, Attr("signed")])
    XCTAssertEqual(recon("{ number: 42, true } @signed(\"me\")"), [Slot("number", 42), true, Attr("signed", "me")])
    XCTAssertEqual(recon("{ {1,2} } @signed(by: \"me\")"), [[1, 2], Attr("signed", [Slot("by", "me")])])
  }

  func testParsePostfixAttributedEmptyMarkup() {
    XCTAssertEqual(recon("[] @signed"), [Attr("signed")])
    XCTAssertEqual(recon("[] @signed()"), [Attr("signed")])
    XCTAssertEqual(recon("[] @signed(\"me\")"), [Attr("signed", "me")])
    XCTAssertEqual(recon("[] @signed(by: \"me\")"), [Attr("signed", [Slot("by", "me")])])
  }

  func testParsePostfixAttributedNonEmptyMarkup() {
    XCTAssertEqual(recon("[test] @signed"), ["test", Attr("signed")])
    XCTAssertEqual(recon("[test] @signed()"), ["test", Attr("signed")])
    XCTAssertEqual(recon("[test] @signed(\"me\")"), ["test", Attr("signed", "me")])
    XCTAssertEqual(recon("[test] @signed(by: \"me\")"), ["test", Attr("signed", [Slot("by", "me")])])
  }

  func testParsePostfixAttributedEmptyStrings() {
    XCTAssertEqual(recon("\"\" @signed"), ["", Attr("signed")])
    XCTAssertEqual(recon("\"\" @signed()"), ["", Attr("signed")])
    XCTAssertEqual(recon("\"\" @signed(\"me\")"), ["", Attr("signed", "me")])
    XCTAssertEqual(recon("\"\" @signed(by: \"me\")"), ["", Attr("signed", [Slot("by", "me")])])
  }

  func testParsePostfixAttributedNonEmptyStrings() {
    XCTAssertEqual(recon("\"test\" @signed"), ["test", Attr("signed")])
    XCTAssertEqual(recon("\"test\" @signed()"), ["test", Attr("signed")])
    XCTAssertEqual(recon("\"test\" @signed(\"me\")"), ["test", Attr("signed", "me")])
    XCTAssertEqual(recon("\"test\" @signed(by: \"me\")"), ["test", Attr("signed", [Slot("by", "me")])])
  }

  func testParsePostfixAttributedEmptyData() {
    XCTAssertEqual(recon("% @signed"), [Item(base64: ""), Attr("signed")])
    XCTAssertEqual(recon("% @signed()"), [Item(base64: ""), Attr("signed")])
    XCTAssertEqual(recon("% @signed(\"me\")"), [Item(base64: ""), Attr("signed", "me")])
    XCTAssertEqual(recon("% @signed(by: \"me\")"), [Item(base64: ""), Attr("signed", [Slot("by", "me")])])
  }

  func testParsePostfixAttributedNonEmptyData() {
    XCTAssertEqual(recon("%AA== @signed"), [Item(base64: "AA=="), Attr("signed")])
    XCTAssertEqual(recon("%AAA= @signed()"), [Item(base64: "AAA="), Attr("signed")])
    XCTAssertEqual(recon("%AAAA @signed(\"me\")"), [Item(base64: "AAAA"), Attr("signed", "me")])
    XCTAssertEqual(recon("%ABCDabcd12+/ @signed(by: \"me\")"), [Item(base64: "ABCDabcd12+/"), Attr("signed", [Slot("by", "me")])])
  }

  func testParsePostfixAttributeNumbers() {
    XCTAssertEqual(recon("42 @signed"), [42, Attr("signed")])
    XCTAssertEqual(recon("-42 @signed()"), [-42, Attr("signed")])
    XCTAssertEqual(recon("42.0 @signed(\"me\")"), [42.0, Attr("signed", "me")])
    XCTAssertEqual(recon("-42.0 @signed(by: \"me\")"), [-42.0, Attr("signed", [Slot("by", "me")])])
  }

  func testParsePostfixAttributeBools() {
    XCTAssertEqual(recon("true @signed"), [true, Attr("signed")])
    XCTAssertEqual(recon("false @signed()"), [false, Attr("signed")])
    XCTAssertEqual(recon("true @signed(\"me\")"), [true, Attr("signed", "me")])
    XCTAssertEqual(recon("false @signed(by: \"me\")"), [false, Attr("signed", [Slot("by", "me")])])
  }

  func testParseInfixAttributedEmptyRecords() {
    XCTAssertEqual(recon("{}@hello{}"), [Attr("hello")])
    XCTAssertEqual(recon("{}@hello(){}"), [Attr("hello")])
    XCTAssertEqual(recon("{}@hello(\"world\"){}"), [Attr("hello", "world")])
    XCTAssertEqual(recon("{}@hello(name: \"world\"){}"), [Attr("hello", [Slot("name", "world")])])
  }

  func testParseInfixAttributedNonEmptyRecords() {
    XCTAssertEqual(recon("{{}}@hello{[]}"), [[], Attr("hello"), []])
    XCTAssertEqual(recon("{42}@hello(){\"world\"}"), [42, Attr("hello"), "world"])
    XCTAssertEqual(recon("{number: 42}@hello(\"world\"){true}"), [Slot("number", 42), Attr("hello", "world"), true])
    XCTAssertEqual(recon("{{1,2}}@hello(name: \"world\"){{3,4}}"), [[1, 2], Attr("hello", [Slot("name", "world")]), [3, 4]])
  }

  func testParseInfixAttributedEmptyMarkup() {
    XCTAssertEqual(recon("[]@hello[]"), [Attr("hello")])
    XCTAssertEqual(recon("[]@hello()[]"), [Attr("hello")])
    XCTAssertEqual(recon("[]@hello(\"world\")[]"), [Attr("hello", "world")])
    XCTAssertEqual(recon("[]@hello(name: \"world\")[]"), [Attr("hello", [Slot("name", "world")])])
  }

  func testParseInfixAttributedNonEmptyMarkup() {
    XCTAssertEqual(recon("[a]@hello[test]"), ["a", Attr("hello"), "test"])
    XCTAssertEqual(recon("[a]@hello()[test]"), ["a", Attr("hello"), "test"])
    XCTAssertEqual(recon("[a]@hello(\"world\")[test]"), ["a", Attr("hello", "world"), "test"])
    XCTAssertEqual(recon("[a]@hello(name: \"world\")[test]"), ["a", Attr("hello", [Slot("name", "world")]), "test"])
  }

  func testParseInfixAttributedEmptyStrings() {
    XCTAssertEqual(recon("\"\"@hello\"\""), ["", Attr("hello"), ""])
    XCTAssertEqual(recon("\"\"@hello()\"\""), ["", Attr("hello"), ""])
    XCTAssertEqual(recon("\"\"@hello(\"world\")\"\""), ["", Attr("hello", "world"), ""])
    XCTAssertEqual(recon("\"\"@hello(name: \"world\")\"\""), ["", Attr("hello", [Slot("name", "world")]), ""])
  }

  func testParseInfixAttributedNonEmptyStrings() {
    XCTAssertEqual(recon("\"a\"@hello\"test\""), ["a", Attr("hello"), "test"])
    XCTAssertEqual(recon("\"a\"@hello()\"test\""), ["a", Attr("hello"), "test"])
    XCTAssertEqual(recon("\"a\"@hello(\"world\")\"test\""), ["a", Attr("hello", "world"), "test"])
    XCTAssertEqual(recon("\"a\"@hello(name: \"world\")\"test\""), ["a", Attr("hello", [Slot("name", "world")]), "test"])
  }

  func testParseInfixAttributedEmptyData() {
    XCTAssertEqual(recon("%@hello%"), [Item(base64: ""), Attr("hello"), Item(base64: "")])
    XCTAssertEqual(recon("%@hello()%"), [Item(base64: ""), Attr("hello"), Item(base64: "")])
    XCTAssertEqual(recon("%@hello(\"world\")%"), [Item(base64: ""), Attr("hello", "world"), Item(base64: "")])
    XCTAssertEqual(recon("%@hello(name: \"world\")%"), [Item(base64: ""), Attr("hello", [Slot("name", "world")]), Item(base64: "")])
  }

  func testParseInfixAttributedNonEmptyData() {
    XCTAssertEqual(recon("%AA==@hello%BB=="), [Item(base64: "AA=="), Attr("hello"), Item(base64: "BB==")])
    XCTAssertEqual(recon("%AAA=@hello()%BBB="), [Item(base64: "AAA="), Attr("hello"), Item(base64: "BBB=")])
    XCTAssertEqual(recon("%AAAA@hello(\"world\")%BBBB"), [Item(base64: "AAAA"), Attr("hello", "world"), Item(base64: "BBBB")])
    XCTAssertEqual(recon("%ABCDabcd12+/@hello(name: \"world\")%/+21dcbaDCBA"), [Item(base64: "ABCDabcd12+/"), Attr("hello", [Slot("name", "world")]), Item(base64: "/+21dcbaDCBA")])
  }

  func testParseInfixAttributedNumbers() {
    XCTAssertEqual(recon("2@hello 42"), [2, Attr("hello"), 42])
    XCTAssertEqual(recon("-2@hello()-42"), [-2, Attr("hello"), -42])
    XCTAssertEqual(recon("2.0@hello(\"world\")42.0"), [2.0, Attr("hello", "world"), 42.0])
    XCTAssertEqual(recon("-2.0@hello(name: \"world\")-42.0"), [-2.0, Attr("hello", [Slot("name", "world")]), -42.0])
  }

  func testParseInfixAttributedBools() {
    XCTAssertEqual(recon("true@hello true"), [true, Attr("hello"), true])
    XCTAssertEqual(recon("false@hello()false"), [false, Attr("hello"), false])
    XCTAssertEqual(recon("true@hello(\"world\")true"), [true, Attr("hello", "world"), true])
    XCTAssertEqual(recon("false@hello(name: \"world\")false"), [false, Attr("hello", [Slot("name", "world")]), false])
  }

  func testParseNonEmptyMarkup() {
    XCTAssertEqual(recon("[test]"), ["test"])
  }

  func testParseMarkupWithEscapes() {
    XCTAssertEqual(recon("[\\\"\\\\\\/\\@\\{\\}\\[\\]\\b\\f\\n\\r\\t]"), ["\"\\/@{}[]\u{8}\u{C}\n\r\t"])
  }

  func testParseMarkupWithEmbeddedMarkup() {
    XCTAssertEqual(recon("[Hello, [good] world!]"), ["Hello, ", "good", " world!"])
  }

  func testParseMarkupWithEmbeddedStructure() {
    XCTAssertEqual(recon("[Hello{}world]"), ["Hello", "world"])
    XCTAssertEqual(recon("[A: {\"answer\"}.]"), ["A: ", "answer", "."])
    XCTAssertEqual(recon("[A: {%AA==}.]"), ["A: ", Item(base64: "AA=="), "."])
    XCTAssertEqual(recon("[A: {42}.]"), ["A: ", 42, "."])
    XCTAssertEqual(recon("[A: {true}.]"), ["A: ", true, "."])
    XCTAssertEqual(recon("[A: {false}.]"), ["A: ", false, "."])
    XCTAssertEqual(recon("[A: {answer:0.0}.]"), ["A: ", Slot("answer", 0.0), "."])
  }

  func testParseMarkupWithEmbeddedSingleExtantAttributes() {
    XCTAssertEqual(recon("[A: @answer.]"), ["A: ", [Attr("answer")], "."])
    XCTAssertEqual(recon("[A: @answer().]"), ["A: ", [Attr("answer")], "."])
    XCTAssertEqual(recon("[A: @answer(\"secret\").]"), ["A: ", [Attr("answer", "secret")], "."])
    XCTAssertEqual(recon("[A: @answer(number: 42, true).]"), ["A: ", [Attr("answer", [Slot("number", 42), true])], "."])
  }

  func testParseMarkupWithEmbeddedSequentialExtantAttributes() {
    XCTAssertEqual(recon("[A: @good @answer.]"), ["A: ", [Attr("good")], " ", [Attr("answer")], "."])
    XCTAssertEqual(recon("[A: @good@answer.]"), ["A: ", [Attr("good")], [Attr("answer")], "."])
    XCTAssertEqual(recon("[A: @good() @answer().]"), ["A: ", [Attr("good")], " ", [Attr("answer")], "."])
    XCTAssertEqual(recon("[A: @good()@answer().]"), ["A: ", [Attr("good")], [Attr("answer")], "."])
  }

  func testParseMarkupWithEmbeddedAttributedMarkup() {
    XCTAssertEqual(recon("[Hello, @em[world]!]"), ["Hello, ", [Attr("em"), "world"], "!"])
    XCTAssertEqual(recon("[Hello, @em()[world]!]"), ["Hello, ", [Attr("em"), "world"], "!"])
    XCTAssertEqual(recon("[Hello, @em(\"italic\")[world]!]"), ["Hello, ", [Attr("em", "italic"), "world"], "!"])
    XCTAssertEqual(recon("[Hello, @em(class:\"subject\",style:\"italic\")[world]!]"), ["Hello, ", [Attr("em", [Slot("class", "subject"), Slot("style", "italic")]), "world"], "!"])
  }

  func testParseMarkupWithEmbeddedAttributedValues() {
    XCTAssertEqual(recon("[A: @answer{42}.]"), ["A: ", [Attr("answer"), 42], "."])
    XCTAssertEqual(recon("[A: @answer(){42}.]"), ["A: ", [Attr("answer"), 42], "."])
    XCTAssertEqual(recon("[A: @answer(\"secret\"){42}.]"), ["A: ", [Attr("answer", "secret"), 42], "."])
    XCTAssertEqual(recon("[A: @answer(number: 42, secret){true}.]"), ["A: ", [Attr("answer", [Slot("number", 42), "secret"]), true], "."])
  }


  func testParseUnclosedEmptyRecordFails() {
    XCTAssertEqual(recon("{"), nil)
  }

  func testParseUnclosedNonEmptyRecordFails() {
    XCTAssertEqual(recon("{1"), nil)
    XCTAssertEqual(recon("{1,"), nil)
    XCTAssertEqual(recon("{1 "), nil)
  }

  func testParseUnclosedEmptyMarkupFails() {
    XCTAssertEqual(recon("["), nil)
  }

  func testParseUnclosedNonEmptyMarkupFails() {
    XCTAssertEqual(recon("[test"), nil)
    XCTAssertEqual(recon("[test{}"), nil)
  }

  func testParseUnclosedEmptyStringFails() {
    XCTAssertEqual(recon("\""), nil)
  }

  func testParseUnclosedNonEmptyStringFails() {
    XCTAssertEqual(recon("\"test"), nil)
    XCTAssertEqual(recon("\"test\\"), nil)
  }

  func testParseNakedNegativeFails() {
    XCTAssertEqual(recon("-"), nil)
  }

  func testParseTrailingDecimalFails() {
    XCTAssertEqual(recon("1."), nil)
  }

  func testParseTrailingExponentFails() {
    XCTAssertEqual(recon("1e"), nil)
    XCTAssertEqual(recon("1E"), nil)
    XCTAssertEqual(recon("1.e"), nil)
    XCTAssertEqual(recon("1.E"), nil)
    XCTAssertEqual(recon("1.0e"), nil)
    XCTAssertEqual(recon("1.0E"), nil)
    XCTAssertEqual(recon("1.0e+"), nil)
    XCTAssertEqual(recon("1.0E+"), nil)
    XCTAssertEqual(recon("1.0e-"), nil)
    XCTAssertEqual(recon("1.0E-"), nil)
  }

  func testParseUnpaddedDataFails() {
    XCTAssertEqual(recon("%AAA"), nil)
    XCTAssertEqual(recon("%AA"), nil)
    XCTAssertEqual(recon("%A"), nil)
  }

  func testParseMalformedDataFails() {
    XCTAssertEqual(recon("%AA=A"), nil)
  }

  func testParseKeylessAttrFails() {
    XCTAssertEqual(recon("@"), nil)
    XCTAssertEqual(recon("@()"), nil)
  }

  func testParseKeylessSlotFails() {
    XCTAssertEqual(recon(":"), nil)
    XCTAssertEqual(recon(":test"), nil)
  }

  func testParseTrailingValuesFails(){
    XCTAssertEqual(recon("{}{}"), nil)
    XCTAssertEqual(recon("1 2"), nil)
  }
}
