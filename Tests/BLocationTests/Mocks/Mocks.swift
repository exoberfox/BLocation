@testable import BLocation

class BLocationSessionDelegateMock: BLocationSubscriptionDelegate {
    var subscribtionCancelledCalledTimes = 0
    func subscribtionCancelled() {
        subscribtionCancelledCalledTimes += 1
    }
}
