import XCTest
@testable import Recon

class ReconSerializationTests: XCTestCase {
  func testSerializeAbsentValues() {
    XCTAssertEqual(Value.Absent.recon, "")
  }

  func testSerializeEmptyRecords() {
    XCTAssertEqual(Value().recon, "{}")
  }

  func testSerializeUnaryRecords() {
    XCTAssertEqual(Value(Item(1)).recon, "{1}")
  }

  func testSerializeNonEmptyRecords() {
    XCTAssertEqual(Value(Item(1), Item(2), Item("3"), Item.True).recon, "{1,2,\"3\",true}")
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
    XCTAssertEqual(Value(Attr("answer")).recon, "@answer")
  }

  func testSerializeExtantAttributesWithSingleParameters() {
    XCTAssertEqual(Value(Attr("answer", Value())).recon, "@answer({})")
    XCTAssertEqual(Value(Attr("answer", Value("42"))).recon, "@answer(\"42\")")
    XCTAssertEqual(Value(Attr("answer", Value(42))).recon, "@answer(42)")
    XCTAssertEqual(Value(Attr("answer", Value.True)).recon, "@answer(true)")
  }

  func testSerializeExtantAttributesWithMultipleParameters() {
    XCTAssertEqual(Value(Attr("answer", Value(Item(42), Item.True))).recon, "@answer(42,true)")
  }

  func testSerializeExtantAttributesWithNamedParameters() {
    XCTAssertEqual(Value(Attr("answer", Value(Slot("number", Value(42))))).recon, "@answer(number:42)")
  }

  func testSerializeRecordsWithIdentKeyedSlots() {
    XCTAssertEqual(Value(Slot("a", Value(1)), Item.False, Slot("c", Value(3))).recon, "{a:1,false,c:3}")
  }

  func testSerializeRecordsWithValueKeyedSlots() {
    XCTAssertEqual(Value(Slot(Value(1), Value("one")), Slot(Value(Attr("id"), Item("foo")), Value("bar"))).recon, "{1:one,@id foo:bar}")
  }

  func testSerializeRecordsWithExtantSlots() {
    XCTAssertEqual(Value(Slot("blank")).recon, "{blank:}")
  }

  func testSerializePrefixAttributedEmptyRecords() {
    XCTAssertEqual(Value(Attr("hello"), Item()).recon, "@hello{{}}")
  }

  func testSerializePrefixAttributedEmptyText() {
    XCTAssertEqual(Value(Attr("hello"), Item("")).recon, "@hello\"\"")
  }

  func testSerializePrefixAttributedNonEmptyText() {
    XCTAssertEqual(Value(Attr("hello"), Item("world!")).recon, "@hello\"world!\"")
  }

  func testSerializePrefixAttributedNumbers() {
    XCTAssertEqual(Value(Attr("answer"), Item(42)).recon, "@answer 42")
  }

  func testSerializePrefixAttributedBools() {
    XCTAssertEqual(Value(Attr("answer"), Item.True).recon, "@answer true")
  }

  func testSerializePrefixAttributedSlots() {
    XCTAssertEqual(Value(Attr("hello"), Slot("subject", Value("world!"))).recon, "@hello{subject:\"world!\"}")
  }

  func testSerializePostfixAttributedEmptyRecords() {
    XCTAssertEqual(Value(Item(), Attr("signed")).recon, "{{}}@signed")
  }

  func testSerializePostfixAttributedEmptyText() {
    XCTAssertEqual(Value(Item(""), Attr("signed")).recon, "\"\"@signed")
  }

  func testSerializePostfixAttributedNonEmptyText() {
    XCTAssertEqual(Value(Item("world!"), Attr("signed")).recon, "\"world!\"@signed")
  }

  func testSerializePostfixAttributedNumbers() {
    XCTAssertEqual(Value(Item(42), Attr("signed")).recon, "42@signed")
  }

  func testSerializePostfixAttributedBools() {
    XCTAssertEqual(Value(Item.True, Attr("signed")).recon, "true@signed")
  }

  func testSerializePostfixAttributedSlots() {
    XCTAssertEqual(Value(Slot("subject", Value("world!")), Attr("signed")).recon, "{subject:\"world!\"}@signed")
  }

  func testSerializeSingleValuesWithMultiplePostfixAttributes() {
    XCTAssertEqual(Value(Item(6), Attr("months"), Attr("remaining")).recon, "6@months@remaining")
  }

  func testSerializeSingleValuesWithCircumfixAttributes() {
    XCTAssertEqual(Value(Attr("a"), Attr("b"), Item.False, Attr("x"), Attr("y")).recon, "@a@b false@x@y")
  }

  func testSerializeSingleValuesWithInterspersedAttributes() {
    XCTAssertEqual(Value(Attr("a"), Item(1), Attr("b"), Item(2)).recon, "@a 1@b 2")
  }

  func testSerializeSingleValuesWithInterspersedAttributeGroups() {
    XCTAssertEqual(Value(Attr("a"), Attr("b"), Item(1), Attr("c"), Attr("d"), Item(2)).recon, "@a@b 1@c@d 2")
  }

  func testSerializeMultipleItemsWithMultiplePostfixAttributes() {
    XCTAssertEqual(Value(Item(1), Item(2), Attr("x"), Attr("y")).recon, "{1,2}@x@y")
  }

  func testSerializeMultipleItemsWithCircumfixAttributes() {
    XCTAssertEqual(Value(Attr("a"), Attr("b"), Item(1), Item(2), Attr("x"), Attr("y")).recon, "@a@b{1,2}@x@y")
  }

  func testSerializeMultipleItemsWithInterspersedAttributes() {
    XCTAssertEqual(Value(Attr("a"), Item(1), Item(2), Attr("b"), Item(3), Item(4)).recon, "@a{1,2}@b{3,4}")
  }

  func testSerializeMultipleItemsWithInterspersedAttributeGroups() {
    XCTAssertEqual(Value(Attr("a"), Attr("b"), Item(1), Item(2), Attr("c"), Attr("d"), Item(3), Item(4)).recon, "@a@b{1,2}@c@d{3,4}")
  }

  func testSerializeMarkup() {
    XCTAssertEqual(Value(Item("Hello, "), Item(Attr("em"), Item("world")), Item("!")).recon, "[Hello, @em[world]!]")
    XCTAssertEqual(Value(Item("Hello, "), Item(Attr("em", Value(Slot("class", Value("subject")))), Item("world")), Item("!")).recon, "[Hello, @em(class:subject)[world]!]")
  }

  func testSerializeNestedMarkup() {
    XCTAssertEqual(Value(Item("X "), Item(Attr("p"), Item("Y "), Item(Attr("q"), Item("Z")), Item(".")), Item(".")).recon, "[X @p[Y @q[Z].].]")
  }

  func testSerializeMarkupWithNonPrefixAttributes() {
    XCTAssertEqual(Value(Item("X "), Item(Attr("p"), Item("Y."), Attr("q")), Item(".")).recon, "[X {@p\"Y.\"@q}.]")
  }

  func testSerializeMarkupInAttributeParameters() {
    XCTAssertEqual(Value(Attr("msg", Value(Item("Hello, "), Item(Attr("em"), Item("world")), Item("!")))).recon, "@msg([Hello, @em[world]!])")
  }

  func testSerializeMarkupEmbeddedValues() {
    XCTAssertEqual(Value(Item("Hello, "), Item(6), Item("!")).recon, "[Hello, {6}!]")
    XCTAssertEqual(Value(Item("Hello, "), Item(6), Item(7), Item("!")).recon, "[Hello, {6,7}!]")
  }

  func testSerializeMarkupEmbeddedValuesWithSubsequentAttributes() {
    XCTAssertEqual(Value(Item("Wait "), Item(1), Attr("second"), Item(" longer"), Item(Attr("please"))).recon, "[Wait {1}]@second[ longer@please]")
    XCTAssertEqual(Value(Item("Wait "), Item(1), Item(2), Attr("second"), Item(" longer"), Item(Attr("please"))).recon, "[Wait {1,2}]@second[ longer@please]")
  }

  func testSerializeMarkupEmbeddedRecords() {
    XCTAssertEqual(Value(Item("Hello, "), Item(), Item("!")).recon, "[Hello, {{}}!]")
    XCTAssertEqual(Value(Item("Hello, "), Item(Item(1)), Item("!")).recon, "[Hello, {{1}}!]")
    XCTAssertEqual(Value(Item("Hello, "), Item(Item(1), Item(2)), Item("!")).recon, "[Hello, {{1,2}}!]")
  }

  func testSerializeMarkupEmbeddedAttributedValues() {
    XCTAssertEqual(Value(Item("Hello, "), Item(Attr("number"), Item(6)), Item("!")).recon, "[Hello, @number{6}!]")
  }

  func testSerializeMarkupEmbeddedAttributedRecords() {
    XCTAssertEqual(Value(Item("Hello, "), Item(Attr("choice"), Item("Earth"), Item("Mars")), Item("!")).recon, "[Hello, @choice{Earth,Mars}!]")
  }

  func testSerializeMarkupEmbeddedRecordsWithNonPrefixAttributes() {
    XCTAssertEqual(Value(Item("Hello, "), Item(Item(1), Attr("second")), Item("!")).recon, "[Hello, {1@second}!]")
  }
}
