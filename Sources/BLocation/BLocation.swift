public class BLocation {
    private let locationManager: LocationManager

    public init(_: String) {
        locationManager = .shared
        print("BLocation succesfully started!")
    }

    public func startUpdatingLocation() async throws {
        try await locationManager.startUpdatingLocation()
    }

    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}
