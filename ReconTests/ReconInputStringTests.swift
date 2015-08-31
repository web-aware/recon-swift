import XCTest
@testable import Recon

class ReconInputStringTests: XCTestCase {
  func testEmpty() {
    let input = ReconInputString("")
    XCTAssertTrue(input.isEmpty)
    XCTAssertFalse(input.isDone)
    XCTAssertNil(input.head)
  }

  func testNonEmpty() {
    let input = ReconInputString("test")
    XCTAssertFalse(input.isEmpty)
  }

  func testHeadAndTail() {
    var input = ReconInputString("a") as ReconInput
    XCTAssertFalse(input.isEmpty)
    XCTAssertEqual(input.head, "a")
    input = input.tail
    XCTAssertTrue(input.isEmpty)
    XCTAssertNil(input.head)
  }
}
