import Foundation

actor TokenProvider {
    private init() {}
    
    static var shared = TokenProvider()
    
    var authToken: String?
    var expiresAt: Date?
    var refreshToken: String?
    
    func setup(_ dto: AuthResponseDTO) {
        authToken = dto.accessToken
        expiresAt = dto.expiresAt
        refreshToken = dto.refreshToken
    }
    
    func refresh(_ dto: RefreshResponseDTO) {
        authToken = dto.accessToken
        expiresAt = dto.expiresAt
    }
}
