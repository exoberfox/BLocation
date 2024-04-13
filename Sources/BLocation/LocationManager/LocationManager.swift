import Combine
import CoreLocation
import Foundation

enum LocationManagerError: Error {
    case permissionProblems // May be more specified
    case noLocationRetrieved
}

class LocationManager: NSObject, ObservableObject {
    @Published
    var cordinates: CLLocationCoordinate2D?

    @UserDefault("locationRequestedStatus", defaultValue: false)
    var locationRequested: Bool

    static var shared = LocationManager()

    private let locationManager = CLLocationManager()

    private var continuation: CheckedContinuation<Void, Error>?

    fileprivate let allowedStatuses: [CLAuthorizationStatus] = [.authorizedWhenInUse, .authorizedAlways]

    // MARK: - Lifecycle

    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func startUpdatingLocation() async throws {
        try await requestPermissionIfNeeded()
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    func requestCurrentLocation() async throws -> CLLocationCoordinate2D {
        try await requestPermissionIfNeeded()
        guard let coordinate = locationManager.location?.coordinate else {
            throw LocationManagerError.noLocationRetrieved
        }
        return coordinate
    }

    // MARK: - Private

    private func requestPermissionIfNeeded() async throws {
        if !allowedStatuses.contains(locationManager.authorizationStatus) {
            try await withCheckedThrowingContinuation { continuation in
                self.continuation = continuation
                requestLocationPermission()
            }
        }
    }

    private func requestLocationPermission() {
        guard let _ = Foundation.Bundle.main.object(forInfoDictionaryKey: .locationWhenInUseUsageDescription) else {
            print("WARNING: \(String.locationWhenInUseUsageDescription) not found in Info.plist")
            return
        }

        locationManager.requestWhenInUseAuthorization()
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard allowedStatuses.contains(manager.authorizationStatus) else {
            continuation?.resume(throwing: LocationManagerError.permissionProblems)
            return
        }
        continuation?.resume()
    }

    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        cordinates = location.coordinate
        print(location.coordinate)
    }
}

// MARK: - Info plist keys

extension String {
    static var locationWhenInUseUsageDescription = "NSLocationWhenInUseUsageDescription"
}
