import CoreLocation

class LocationApi {
    private let apiClient: ApiClient

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }

    func report(_ coordinate: CLLocationCoordinate2D) async throws {
        let dto = LocationReportDTO(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let request = Request(path: "location", body: dto)
        try await apiClient.perform(request)
    }
}
