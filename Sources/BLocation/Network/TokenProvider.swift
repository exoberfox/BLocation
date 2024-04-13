import Foundation

actor TokenProvider {
    private init() {}

    static var shared = TokenProvider()

    var authToken: String?
    var expiresAt: Date?
    var refreshToken: String?

    var isAuthentificating: Bool = false
    var isRefreshing: Bool = false

    func setup(_ dto: AuthResponseDTO) {
        authToken = dto.accessToken
        expiresAt = dto.expiresAt
        refreshToken = dto.refreshToken
    }

    func refresh(_ dto: RefreshResponseDTO) {
        authToken = dto.accessToken
        expiresAt = dto.expiresAt
    }

    // MARK: - Auth

    func startAuth() {
        isAuthentificating = true
    }

    func authFinished() {
        isAuthentificating = false
    }

    // MARK: - Refresh

    func startRefresh() {
        isRefreshing = true
    }

    func refreshFinished() {
        isRefreshing = false
    }
}
