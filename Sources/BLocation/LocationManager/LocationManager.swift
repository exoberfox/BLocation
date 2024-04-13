import Combine
import CoreLocation
import Foundation

class LocationManager: NSObject, ObservableObject {
    @Published
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published
    var cordinates: CLLocationCoordinate2D?

    @UserDefault("locationRequestedStatus", defaultValue: false)
    var locationRequested: Bool

    private let locationManager = CLLocationManager()

    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    static var shared = LocationManager()

    func requestLocationPermission() {
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
        authorizationStatus = manager.authorizationStatus
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
