import BLocation
import Combine

enum BLocationState: String {
    case idle = "Initialized"
    case ready = "Ready"
    case reporting = "Reporting"
    case reportingStopped = "Reporting Stopped"
    case error = "Error occured"
}

class BLocationAdapter: ObservableObject {
    private var blocation = BLocation()

    @Published
    var state: BLocationState = .idle

    func setup() {
        Task {
            do {
                try await blocation.setup(Secrets.apiKey)
                Task { @MainActor in
                    self.state = .ready
                }
            } catch {
                Task { @MainActor in
                    self.state = .error
                }
            }
        }
    }

    func start() {
        Task {
            do {
                try await blocation.startUpdatingLocation(self)
                Task { @MainActor in
                    self.state = .reporting
                }
            } catch {
                Task { @MainActor in
                    self.state = .error
                }
            }
        }
    }

    func stop() {
        blocation.stopUpdatingLocation()
    }
}

extension BLocationAdapter: BLocationSubscriptionDelegate {
    func subscribtionCancelled() {
        Task { @MainActor in
            self.state = .reportingStopped
        }
        // Recreate / send analytics / show error
    }
}
