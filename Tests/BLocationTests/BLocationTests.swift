@testable import BLocation
import XCTest

final class BLocationTests: XCTestCase {
    func test_reportCurrentLocation_failsCauseSetupWasNeverCalled() async throws {
        // given
        let blocation = BLocation()

        // when
        do {
            try await blocation.reportCurrentLocation()
            XCTFail()
        } catch {
            // then
            XCTAssertEqual(error as! BLocationError, .setupSkippedOrFailed)
        }
    }

    func test_startUpdatingLocation_failsCauseSetupWasNeverCalled() async throws {
        // given
        let blocation = BLocation()

        // when
        do {
            try await blocation.startUpdatingLocation(BLocationSessionDelegateMock())
            XCTFail()
        } catch {
            // then
            XCTAssertEqual(error as! BLocationError, .setupSkippedOrFailed)
        }
    }
}
