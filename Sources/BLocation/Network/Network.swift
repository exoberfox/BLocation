import Foundation

struct Empty: Encodable {}
struct Request<T: Encodable>: AnyRequest {
    enum Method: String {
        case post = "POST"
        case get = "GET"
    }

    var method: Method = .post
    var path: String
    var body: T

    init(
        method: Method = .post,
        path: String,
        body: T = Empty()
    ) {
        self.method = method
        self.path = path
        self.body = body
    }
}

protocol AnyRequest {}
enum Header: String {
    case authorization = "Authorization"
}

enum HostProvider { // May be modified, to allow substitution
    static var host = "https://dummy-api-mobile.api.sandbox.bird.one/"
}

enum ApiClientError: Error {
    case unauthorized
    case noRefreshToken // Malfromed setup
    case authTokenMalformed // Token dissapeared after refresh
    case malformedRequest

    case refreshTokenExpectationTookTooLong

    case requestFailed
}

class ApiClient: NSObject {
    private let apiKey: String
    private var urlSession: URLSession!
    private let tokenProvider: TokenProvider

    private var queue = [AnyRequest]()

    init(
        apiKey: String,
        configuration: URLSessionConfiguration = .default,
        tokenProvider: TokenProvider = .shared
    ) {
        self.apiKey = apiKey
        self.tokenProvider = tokenProvider
        super.init()

        urlSession = URLSession(
            configuration: configuration,
            delegate: self,
            delegateQueue: nil
        )
    }

    func perform<B: Encodable>(_ request: Request<B>) async throws {
        // Unauthorized
        guard let date = await tokenProvider.expiresAt else {
            throw ApiClientError.unauthorized
        }

        // Auth token is expired or almost expired
        if date.timeIntervalSince(Date()) > Constants.timeToCountTokenAsExpired {
            guard let refreshToken = await tokenProvider.refreshToken else {
                throw ApiClientError.noRefreshToken
            }
            try await refresh(refreshToken)
        }

        // Retrieve new token from provider, cause we may renewed it
        guard let authToken = await tokenProvider.authToken else {
            throw ApiClientError.authTokenMalformed
        }

        guard let url = URL(string: HostProvider.host + request.path) else {
            throw ApiClientError.malformedRequest
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Bearer \(authToken)", forHTTPHeaderField: Header.authorization.rawValue)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = try JSONEncoder().encode(request.body)

        do {
            let (_, response) = try await urlSession.data(for: urlRequest)
            guard response.isSucceed else {
                throw ApiClientError.requestFailed
            }
        } catch {
            // TODO: Retry on 401 error
            print("Request failed", error)
            throw error
        }
    }

    func auth() async throws {
        guard await !tokenProvider.isAuthentificating else { return }
        await tokenProvider.startAuth()

        guard let url = URL(string: HostProvider.host + "auth") else {
            throw ApiClientError.malformedRequest
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: Header.authorization.rawValue)
        request.httpMethod = "POST"

        do {
            let dto: AuthResponseDTO = try await perform(request)
            await tokenProvider.setup(dto)
            await tokenProvider.authFinished()
        } catch {
            print("Error \(error)")
            await tokenProvider.authFinished()
            throw error
        }
    }

    // MARK: - Private

    private var dateFormatter: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withFractionalSeconds
        return formatter
    }

    private func refresh(_ refreshToken: String) async throws {
        // Do not start refresh if we already refreshing
        var wasRefreshing = false
        var refreshAttemptsCount = 0
        while await !tokenProvider.isRefreshing {
            wasRefreshing = true
            guard refreshAttemptsCount < Constants.maxRefreshAttempts else {
                throw ApiClientError.refreshTokenExpectationTookTooLong
            }

            refreshAttemptsCount += 1
            try await Task.sleep(nanoseconds: Constants.oneSecond)
        }

        // If we were already refreshing token, do not calling this method again
        guard !wasRefreshing else { return }
        await tokenProvider.startRefresh()

        guard let url = URL(string: HostProvider.host + "auth/refresh") else {
            throw ApiClientError.malformedRequest
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(refreshToken)", forHTTPHeaderField: Header.authorization.rawValue)
        request.httpMethod = "POST"

        do {
            let dto: RefreshResponseDTO = try await perform(request)
            await tokenProvider.refresh(dto)
            await tokenProvider.refreshFinished()
        } catch {
            print("Error \(error)")
            await tokenProvider.refreshFinished()
            throw error
        }
    }

    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await urlSession.data(for: request)
        guard response.isSucceed else {
            throw ApiClientError.requestFailed
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { [weak self] decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            if let date = self?.dateFormatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
        }
        return try decoder.decode(T.self, from: data)
    }
}

extension ApiClient: URLSessionDelegate {
    func urlSession(_: URLSession, didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        (URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}

private enum Constants {
    static var timeToCountTokenAsExpired: TimeInterval = 5
    static var maxRefreshAttempts: Int = 5

    static var oneSecond: UInt64 = 1_000_000_000
}
