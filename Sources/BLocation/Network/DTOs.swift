import Foundation

// MARK: - Request

struct LocationReportDTO: Encodable {
    let latitude: Double
    let longitude: Double
}

// MARK: - Response

struct AuthResponseDTO: Decodable {
    let accessToken: String
    let expiresAt: Date
    let refreshToken: String
}

struct RefreshResponseDTO: Decodable {
    let accessToken: String
    let expiresAt: Date
}
