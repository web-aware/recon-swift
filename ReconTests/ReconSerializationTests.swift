import XCTest
@testable import Recon

class ReconSerializationTests: XCTestCase {
  func testSerializeAbsentValue() {
    XCTAssertEqual(Item.Absent.recon, "")
  }

  func testSerializeEmptyRecord() {
    XCTAssertEqual(Item.Record().recon, "{}")
  }

  func testSerializeUnaryRecord() {
    XCTAssertEqual(Item.Record(Item.Number(1)).recon, "{1}")
  }

  func testSerializeNonEmptyRecord() {
    XCTAssertEqual(Item.Record(Item.Number(1), Item.Number(2), Item.Text("3"), Item.True).recon, "{1,2,\"3\",true}")
  }

  func testSerializeEmptyText() {
    XCTAssertEqual(Item.Text("").recon, "\"\"")
  }

  func testSerializeNonEmptyText() {
    XCTAssertEqual(Item.Text("Hello, world!").recon, "\"Hello, world!\"")
  }

  func testSerializeIdentifier() {
    XCTAssertEqual(Item.Text("test").recon, "test")
  }

  func testSerializeEmptyData() {
    XCTAssertEqual(Item.Data(Data()).recon, "%")
  }

  func testSerializeNonEmptyData() {
    XCTAssertEqual(Item.Data(base64: "AA==").recon, "%AA==")
  }

  func testSerializeNumbers() {
    XCTAssertEqual(Item.Number(0).recon, "0")
    XCTAssertEqual(Item.Number(1).recon, "1")
    XCTAssertEqual(Item.Number(-1).recon, "-1")
    XCTAssertEqual(Item.Number(15).recon, "15")
    XCTAssertEqual(Item.Number(-20).recon, "-20")
    XCTAssertEqual(Item.Number(3.14).recon, "3.14")
    XCTAssertEqual(Item.Number(-0.5).recon, "-0.5")
    XCTAssertEqual(Item.Number(6.02e+23).recon, "6.02e+23")
  }

  func testSerializeBools() {
    XCTAssertEqual(Item.True.recon, "true")
    XCTAssertEqual(Item.False.recon, "false")
  }
}
