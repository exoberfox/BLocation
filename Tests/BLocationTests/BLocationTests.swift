@testable import BLocation
import XCTest

final class BLocationTests: XCTestCase {
    func testDateFormatter() throws {
        // given
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withFractionalSeconds
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sss'Z'"

        let dateRef = "2024-04-13T21:34:44.643Z"

        // when
        let date = formatter.date(from: dateRef)

        // then
        XCTAssertNotNil(date)
    }
}
