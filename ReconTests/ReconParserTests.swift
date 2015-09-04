import XCTest
@testable import Recon

class ReconParserTests: XCTestCase {
  func testParseIdent() {
    XCTAssertEqual(ReconIdentParser().parse("test").value as? String, "test")
  }

  func testParseEmptyString() {
    XCTAssertEqual(ReconStringParser().parse("\"\"").value as? String, "")
  }

  func testParseNonEmptyString() {
    XCTAssertEqual(ReconStringParser().parse("\"test\"").value as? String, "test")
  }

  func testParseStringWithEscapes() {
    let result = ReconStringParser().parse("\"\\\"\\\\\\/\\@\\{\\}\\[\\]\\b\\f\\n\\r\\t\"")
    XCTAssertEqual(result.value as? String, "\"\\/@{}[]\u{8}\u{C}\n\r\t")
  }

  func testParseUnclosedEmptyString() {
    XCTAssertTrue(ReconStringParser().parse("\"").isFail)
  }

  func testParseUnclosedNonEmptyString() {
    XCTAssertTrue(ReconStringParser().parse("\"test").isFail)
  }

  func testParsePositiveIntegers() {
    XCTAssertEqual(ReconNumberParser().parse("0").value as? Int, 0)
    XCTAssertEqual(ReconNumberParser().parse("1").value as? Int, 1)
    XCTAssertEqual(ReconNumberParser().parse("5").value as? Int, 5)
    XCTAssertEqual(ReconNumberParser().parse("10").value as? Int, 10)
    XCTAssertEqual(ReconNumberParser().parse("11").value as? Int, 11)
    XCTAssertEqual(ReconNumberParser().parse("15").value as? Int, 15)
  }

  func testParseNegativeInetegrs() {
    XCTAssertEqual(ReconNumberParser().parse("-0").value as? Int, -0)
    XCTAssertEqual(ReconNumberParser().parse("-1").value as? Int, -1)
    XCTAssertEqual(ReconNumberParser().parse("-5").value as? Int, -5)
    XCTAssertEqual(ReconNumberParser().parse("-10").value as? Int, -10)
    XCTAssertEqual(ReconNumberParser().parse("-11").value as? Int, -11)
    XCTAssertEqual(ReconNumberParser().parse("-15").value as? Int, -15)
  }

  func testParsePositiveDecimals() {
    XCTAssertEqual(ReconNumberParser().parse("0.0").value as? Double, 0.0)
    XCTAssertEqual(ReconNumberParser().parse("0.5").value as? Double, 0.5)
    XCTAssertEqual(ReconNumberParser().parse("1.0").value as? Double, 1.0)
    XCTAssertEqual(ReconNumberParser().parse("1.5").value as? Double, 1.5)
    XCTAssertEqual(ReconNumberParser().parse("10.0").value as? Double, 10.0)
    XCTAssertEqual(ReconNumberParser().parse("10.5").value as? Double, 10.5)
  }

  func testParseNegativeDecimals() {
    XCTAssertEqual(ReconNumberParser().parse("-0.0").value as? Double, -0.0)
    XCTAssertEqual(ReconNumberParser().parse("-0.5").value as? Double, -0.5)
    XCTAssertEqual(ReconNumberParser().parse("-1.0").value as? Double, -1.0)
    XCTAssertEqual(ReconNumberParser().parse("-1.5").value as? Double, -1.5)
    XCTAssertEqual(ReconNumberParser().parse("-10.0").value as? Double, -10.0)
    XCTAssertEqual(ReconNumberParser().parse("-10.5").value as? Double, -10.5)
  }

  func testParsePositiveExponentials() {
    XCTAssertEqual(ReconNumberParser().parse("4e2").value as? Double, 400.0)
    XCTAssertEqual(ReconNumberParser().parse("4E2").value as? Double, 400.0)
    XCTAssertEqual(ReconNumberParser().parse("4e+2").value as? Double, 400.0)
    XCTAssertEqual(ReconNumberParser().parse("4E+2").value as? Double, 400.0)
    XCTAssertEqual(ReconNumberParser().parse("4e-2").value as? Double, 0.04)
    XCTAssertEqual(ReconNumberParser().parse("4E-2").value as? Double, 0.04)
    XCTAssertEqual(ReconNumberParser().parse("4.0e2").value as? Double, 400.0)
    XCTAssertEqual(ReconNumberParser().parse("4.0E2").value as? Double, 400.0)
    XCTAssertEqual(ReconNumberParser().parse("4.0e+2").value as? Double, 400.0)
    XCTAssertEqual(ReconNumberParser().parse("4.0E+2").value as? Double, 400.0)
    XCTAssertEqual(ReconNumberParser().parse("4.0e-2").value as? Double, 0.04)
    XCTAssertEqual(ReconNumberParser().parse("4.0E-2").value as? Double, 0.04)
  }

  func testParseNegativeExponentials() {
    XCTAssertEqual(ReconNumberParser().parse("-4e2").value as? Double, -400.0)
    XCTAssertEqual(ReconNumberParser().parse("-4E2").value as? Double, -400.0)
    XCTAssertEqual(ReconNumberParser().parse("-4e+2").value as? Double, -400.0)
    XCTAssertEqual(ReconNumberParser().parse("-4E+2").value as? Double, -400.0)
    XCTAssertEqual(ReconNumberParser().parse("-4e-2").value as? Double, -0.04)
    XCTAssertEqual(ReconNumberParser().parse("-4E-2").value as? Double, -0.04)
    XCTAssertEqual(ReconNumberParser().parse("-4.0e2").value as? Double, -400.0)
    XCTAssertEqual(ReconNumberParser().parse("-4.0E2").value as? Double, -400.0)
    XCTAssertEqual(ReconNumberParser().parse("-4.0e+2").value as? Double, -400.0)
    XCTAssertEqual(ReconNumberParser().parse("-4.0E+2").value as? Double, -400.0)
    XCTAssertEqual(ReconNumberParser().parse("-4.0e-2").value as? Double, -0.04)
    XCTAssertEqual(ReconNumberParser().parse("-4.0E-2").value as? Double, -0.04)
  }

  func testParseNakedNegative() {
    XCTAssertTrue(ReconNumberParser().parse("-").isFail)
  }

  func testParseTrailingDecimal() {
    XCTAssertTrue(ReconNumberParser().parse("1.").isFail)
  }

  func testParseTrailingExponent() {
    XCTAssertTrue(ReconNumberParser().parse("1e").isFail)
    XCTAssertTrue(ReconNumberParser().parse("1E").isFail)
    XCTAssertTrue(ReconNumberParser().parse("1.e").isFail)
    XCTAssertTrue(ReconNumberParser().parse("1.E").isFail)
    XCTAssertTrue(ReconNumberParser().parse("1.0e").isFail)
    XCTAssertTrue(ReconNumberParser().parse("1.0E").isFail)
    XCTAssertTrue(ReconNumberParser().parse("1.0e+").isFail)
    XCTAssertTrue(ReconNumberParser().parse("1.0E+").isFail)
    XCTAssertTrue(ReconNumberParser().parse("1.0e-").isFail)
    XCTAssertTrue(ReconNumberParser().parse("1.0E-").isFail)
  }

  func testParseEmptyData() {
    XCTAssertEqual(ReconDataParser().parse("%").value as? Data, Data.decodeBase64(""))
  }

  func testParseNonEmptyData() {
    XCTAssertEqual(ReconDataParser().parse("%AAAA").value as? Data, Data.decodeBase64("AAAA"))
    XCTAssertEqual(ReconDataParser().parse("%AAA=").value as? Data, Data.decodeBase64("AAA="))
    XCTAssertEqual(ReconDataParser().parse("%AA==").value as? Data, Data.decodeBase64("AA=="))
    XCTAssertEqual(ReconDataParser().parse("%ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789/+").value as? Data, Data.decodeBase64("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789/+"))
  }

  func testParseUnpaddedData() {
    XCTAssertTrue(ReconDataParser().parse("%AAA").isFail)
    XCTAssertTrue(ReconDataParser().parse("%AA").isFail)
    XCTAssertTrue(ReconDataParser().parse("%A").isFail)
  }

  func testParseMalformedData() {
    XCTAssertTrue(ReconDataParser().parse("%AA=A").isFail)
  }

  func testParseExtantAttr() {
    XCTAssertEqual(ReconAttrParser().parse("@a").value as? Field, Field.Attr(key: "a", value: Value.Extant))
    XCTAssertEqual(ReconAttrParser().parse("@test").value as? Field, Field.Attr(key: "test", value: Value.Extant))
  }

  func testParseNakedAttr() {
    XCTAssertTrue(ReconAttrParser().parse("@").isFail)
  }

  func testParseBlockItem() {
    XCTAssertEqual(ReconBlockItemParser().parse("@test ").value as? Value, Value.Record(value: [Item.Attr("test")]))
    XCTAssertEqual(ReconBlockItemParser().parse("\"test\"").value as? Value, Value.Text(value: "test"))
    XCTAssertEqual(ReconBlockItemParser().parse("2.5").value as? Value, Value.Number(value: 2.5))
  }

  func testParseBlock() {
    let x = ReconBlockParser().parse("1,2").value as? Value
    let y = Value.Record(value: [Item.Number(1.0), Item.Number(2.0)])
    XCTAssertEqual(x, y)
  }
}
