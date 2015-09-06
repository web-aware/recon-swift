import XCTest
@testable import Recon

class ReconSerializationTests: XCTestCase {
  func testSerializeAbsentValues() {
    XCTAssertEqual(Value.Absent.recon, "")
  }

  func testSerializeEmptyRecords() {
    XCTAssertEqual(Value([]).recon, "{}")
  }

  func testSerializeUnaryRecords() {
    XCTAssertEqual(Value([1]).recon, "{1}")
  }

  func testSerializeNonEmptyRecords() {
    XCTAssertEqual(Value(1, 2, "3", true).recon, "{1,2,\"3\",true}")
  }

  func testSerializeEmptyText() {
    XCTAssertEqual(Value("").recon, "\"\"")
  }

  func testSerializeNonEmptyText() {
    XCTAssertEqual(Value("Hello, world!").recon, "\"Hello, world!\"")
  }

  func testSerializeIdentifiers() {
    XCTAssertEqual(Value("test").recon, "test")
  }

  func testSerializeEmptyData() {
    XCTAssertEqual(Value(Data()).recon, "%")
  }

  func testSerializeNonEmptyData() {
    XCTAssertEqual(Value(base64: "AA==").recon, "%AA==")
    XCTAssertEqual(Value(base64: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789/+").recon, "%ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789/+")
  }

  func testSerializeNumbers() {
    XCTAssertEqual(Value(0).recon, "0")
    XCTAssertEqual(Value(1).recon, "1")
    XCTAssertEqual(Value(-1).recon, "-1")
    XCTAssertEqual(Value(15).recon, "15")
    XCTAssertEqual(Value(-20).recon, "-20")
    XCTAssertEqual(Value(3.14).recon, "3.14")
    XCTAssertEqual(Value(-0.5).recon, "-0.5")
    XCTAssertEqual(Value(6.02e+23).recon, "6.02e+23")
  }

  func testSerializeBools() {
    XCTAssertEqual(Value.True.recon, "true")
    XCTAssertEqual(Value.False.recon, "false")
  }

  func testSerializeExtantAttributesWithNoParameters() {
    XCTAssertEqual(Value([Attr("answer")]).recon, "@answer")
  }

  func testSerializeExtantAttributesWithSingleParameters() {
    XCTAssertEqual(Value(Attr("answer", [])).recon, "@answer({})")
    XCTAssertEqual(Value(Attr("answer", "42")).recon, "@answer(\"42\")")
    XCTAssertEqual(Value(Attr("answer", 42)).recon, "@answer(42)")
    XCTAssertEqual(Value(Attr("answer", true)).recon, "@answer(true)")
  }

  func testSerializeExtantAttributesWithMultipleParameters() {
    XCTAssertEqual(Value(Attr("answer", [42, true])).recon, "@answer(42,true)")
  }

  func testSerializeExtantAttributesWithNamedParameters() {
    XCTAssertEqual(Value(Attr("answer", [Slot("number", 42)])).recon, "@answer(number:42)")
  }

  func testSerializeRecordsWithIdentKeyedSlots() {
    XCTAssertEqual(Value(Slot("a", 1), false, Slot("c", 3)).recon, "{a:1,false,c:3}")
  }

  func testSerializeRecordsWithValueKeyedSlots() {
    XCTAssertEqual(Value(Slot(1, "one"), Slot([Attr("id"), "foo"], "bar")).recon, "{1:one,@id foo:bar}")
  }

  func testSerializeRecordsWithExtantSlots() {
    XCTAssertEqual(Value(Slot("blank")).recon, "{blank:}")
  }

  func testSerializePrefixAttributedEmptyRecords() {
    XCTAssertEqual(Value(Attr("hello"), []).recon, "@hello{{}}")
  }

  func testSerializePrefixAttributedEmptyText() {
    XCTAssertEqual(Value(Attr("hello"), "").recon, "@hello\"\"")
  }

  func testSerializePrefixAttributedNonEmptyText() {
    XCTAssertEqual(Value(Attr("hello"), "world!").recon, "@hello\"world!\"")
  }

  func testSerializePrefixAttributedNumbers() {
    XCTAssertEqual(Value(Attr("answer"), 42).recon, "@answer 42")
  }

  func testSerializePrefixAttributedBools() {
    XCTAssertEqual(Value(Attr("answer"), true).recon, "@answer true")
  }

  func testSerializePrefixAttributedSlots() {
    XCTAssertEqual(Value(Attr("hello"), Slot("subject", "world!")).recon, "@hello{subject:\"world!\"}")
  }

  func testSerializePostfixAttributedEmptyRecords() {
    XCTAssertEqual(Value([], Attr("signed")).recon, "{{}}@signed")
  }

  func testSerializePostfixAttributedEmptyText() {
    XCTAssertEqual(Value("", Attr("signed")).recon, "\"\"@signed")
  }

  func testSerializePostfixAttributedNonEmptyText() {
    XCTAssertEqual(Value("world!", Attr("signed")).recon, "\"world!\"@signed")
  }

  func testSerializePostfixAttributedNumbers() {
    XCTAssertEqual(Value(42, Attr("signed")).recon, "42@signed")
  }

  func testSerializePostfixAttributedBools() {
    XCTAssertEqual(Value(true, Attr("signed")).recon, "true@signed")
  }

  func testSerializePostfixAttributedSlots() {
    XCTAssertEqual(Value(Slot("subject", "world!"), Attr("signed")).recon, "{subject:\"world!\"}@signed")
  }

  func testSerializeSingleValuesWithMultiplePostfixAttributes() {
    XCTAssertEqual(Value(6, Attr("months"), Attr("remaining")).recon, "6@months@remaining")
  }

  func testSerializeSingleValuesWithCircumfixAttributes() {
    XCTAssertEqual(Value(Attr("a"), Attr("b"), false, Attr("x"), Attr("y")).recon, "@a@b false@x@y")
  }

  func testSerializeSingleValuesWithInterspersedAttributes() {
    XCTAssertEqual(Value(Attr("a"), 1, Attr("b"), 2).recon, "@a 1@b 2")
  }

  func testSerializeSingleValuesWithInterspersedAttributeGroups() {
    XCTAssertEqual(Value(Attr("a"), Attr("b"), 1, Attr("c"), Attr("d"), 2).recon, "@a@b 1@c@d 2")
  }

  func testSerializeMultipleItemsWithMultiplePostfixAttributes() {
    XCTAssertEqual(Value(1, 2, Attr("x"), Attr("y")).recon, "{1,2}@x@y")
  }

  func testSerializeMultipleItemsWithCircumfixAttributes() {
    XCTAssertEqual(Value(Attr("a"), Attr("b"), 1, 2, Attr("x"), Attr("y")).recon, "@a@b{1,2}@x@y")
  }

  func testSerializeMultipleItemsWithInterspersedAttributes() {
    XCTAssertEqual(Value(Attr("a"), 1, 2, Attr("b"), 3, 4).recon, "@a{1,2}@b{3,4}")
  }

  func testSerializeMultipleItemsWithInterspersedAttributeGroups() {
    XCTAssertEqual(Value(Attr("a"), Attr("b"), 1, 2, Attr("c"), Attr("d"), 3, 4).recon, "@a@b{1,2}@c@d{3,4}")
  }

  func testSerializeMarkup() {
    XCTAssertEqual(Value("Hello, ", [Attr("em"), "world"], "!").recon, "[Hello, @em[world]!]")
    XCTAssertEqual(Value("Hello, ", [Attr("em", [Slot("class", "subject")]), "world"], "!").recon, "[Hello, @em(class:subject)[world]!]")
  }

  func testSerializeNestedMarkup() {
    XCTAssertEqual(Value("X ", [Attr("p"), "Y ", [Attr("q"), "Z"], "."], ".").recon, "[X @p[Y @q[Z].].]")
  }

  func testSerializeMarkupWithNonPrefixAttributes() {
    XCTAssertEqual(Value("X ", [Attr("p"), "Y.", Attr("q")], ".").recon, "[X {@p\"Y.\"@q}.]")
  }

  func testSerializeMarkupInAttributeParameters() {
    XCTAssertEqual(Value(Attr("msg", ["Hello, ", [Attr("em"), "world"], "!"])).recon, "@msg([Hello, @em[world]!])")
  }

  func testSerializeMarkupEmbeddedValues() {
    XCTAssertEqual(Value("Hello, ", 6, "!").recon, "[Hello, {6}!]")
    XCTAssertEqual(Value("Hello, ", 6, 7, "!").recon, "[Hello, {6,7}!]")
  }

  func testSerializeMarkupEmbeddedValuesWithSubsequentAttributes() {
    XCTAssertEqual(Value("Wait ", 1, Attr("second"), " longer", [Attr("please")]).recon, "[Wait {1}]@second[ longer@please]")
    XCTAssertEqual(Value("Wait ", 1, 2, Attr("second"), " longer", [Attr("please")]).recon, "[Wait {1,2}]@second[ longer@please]")
  }

  func testSerializeMarkupEmbeddedRecords() {
    XCTAssertEqual(Value("Hello, ", [], "!").recon, "[Hello, {{}}!]")
    XCTAssertEqual(Value("Hello, ", [1], "!").recon, "[Hello, {{1}}!]")
    XCTAssertEqual(Value("Hello, ", [1, 2], "!").recon, "[Hello, {{1,2}}!]")
  }

  func testSerializeMarkupEmbeddedAttributedValues() {
    XCTAssertEqual(Value("Hello, ", [Attr("number"), 6], "!").recon, "[Hello, @number{6}!]")
  }

  func testSerializeMarkupEmbeddedAttributedRecords() {
    XCTAssertEqual(Value("Hello, ", [Attr("choice"), "Earth", "Mars"], "!").recon, "[Hello, @choice{Earth,Mars}!]")
  }

  func testSerializeMarkupEmbeddedRecordsWithNonPrefixAttributes() {
    XCTAssertEqual(Value("Hello, ", [1, Attr("second")], "!").recon, "[Hello, {1@second}!]")
  }
}
