import XCTest
@testable import Recon

class ReconInputTests: XCTestCase {
  func testEmpty() {
    let input = ReconInputEmpty()
    XCTAssertTrue(input.isEmpty)
    XCTAssertFalse(input.isDone)
    XCTAssertNil(input.head)
  }

  func testDone() {
    let input = ReconInputDone()
    XCTAssertTrue(input.isEmpty)
    XCTAssertTrue(input.isDone)
    XCTAssertNil(input.head)
  }
}
