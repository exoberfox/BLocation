public class BLocation {
    private let locationManager: LocationManager

    public init() {
        locationManager = .shared
        print("BLocation succesfully started!")
    }

    public func requestLocationPermission() {
        locationManager.requestLocationPermission()
    }
}
