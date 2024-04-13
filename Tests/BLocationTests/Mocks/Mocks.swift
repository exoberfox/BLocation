@testable import BLocation

class BLocationSessionDelegateMock: BLocationSubscriptionDelegate {
    var subscriptionCancelledCalledTimes = 0
    func subscriptionCancelled() {
        subscriptionCancelledCalledTimes += 1
    }
}
