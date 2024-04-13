import Combine
import CoreLocation

public enum BLocationError: Error {
    case setupSkippedOrFailed
}

public protocol BLocationSubscriptionDelegate: AnyObject {
    func subscriptionCancelled()
}

public class BLocation {
    private let locationManager: LocationManager
    private var locationApi: LocationApi?

    private weak var delegate: BLocationSubscriptionDelegate?
    private var subscription: Cancellable?

    public init() {
        locationManager = .shared
        print("BLocation succesfully instantiated!")
    }

    public func setup(_ apiKey: String) async throws {
        let apiClient = ApiClient(apiKey: apiKey)
        try await apiClient.auth()

        locationApi = LocationApi(apiClient: apiClient)
    }

    public func startUpdatingLocation(_ delegate: BLocationSubscriptionDelegate) async throws {
        guard locationApi != nil else {
            throw BLocationError.setupSkippedOrFailed
        }
        try await locationManager.startUpdatingLocation()

        self.delegate = delegate
        subscription = locationManager
            .$cordinates
            .dropFirst()
            .compactMap { $0 }
            .sink { [weak self] coordinate in
                self?.report(coordinate)
            }
    }

    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        subscription?.cancel()
        subscription = nil

        delegate?.subscriptionCancelled()
    }

    public func reportCurrentLocation() async throws {
        guard let locationApi else {
            throw BLocationError.setupSkippedOrFailed
        }
        let coordinate = try await locationManager.requestCurrentLocation()
        try await locationApi.report(coordinate)
    }

    // MARK: - Private

    private func report(_ coordinate: CLLocationCoordinate2D) {
        Task {
            do {
                try await locationApi?.report(coordinate)
            } catch {
                stopUpdatingLocation()
            }
        }
    }
}
