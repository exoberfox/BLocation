import Foundation

struct AuthResponseDTO: Decodable {
    var accessToken: String
    var expiresAt: Date
    var refreshToken: String
}


struct RefreshResponseDTO: Decodable {
    var accessToken: String
    var expiresAt: Date
}
