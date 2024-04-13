import Foundation

struct Empty: Encodable {}
struct Request<T: Encodable> {
    enum Method {
        case post
        case get
    }

    var method: Method = .get
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

enum Header: String {
    case authorization = "Authorization"
}
enum HostProvider { // May be modified, to allow substitution
    static var host = "https://dummy-api-mobile.api.sandbox.bird.one/"
}

class ApiClient {
    private let apiKey: String
    private let urlSession: URLSession
    private let tokenProvider: TokenProvider

    init(
        apiKey: String,
        urlSession: URLSession = .shared,
        tokenProvider: TokenProvider = .shared
    ) {
        self.apiKey = apiKey
        self.urlSession = urlSession
        self.tokenProvider = tokenProvider
    }
    
    func perform<B: Decodable, T>(_ request: Request<B>) -> T {
        
    }
    
    private func auth() async throws {
        guard let url = URL(string: HostProvider.host + "auth") else { return }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: Header.authorization.rawValue)
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            let dto = try JSONDecoder().decode(AuthResponseDTO.self, from: data)
            await tokenProvider.setup(dto)
        } catch {
            print("Error \(error)")
        }
    }
    
    private func refresh(_ refreshToken: String) async throws {
        guard let url = URL(string: HostProvider.host + "auth/refresh") else { return }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(refreshToken)", forHTTPHeaderField: Header.authorization.rawValue)
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            let dto = try JSONDecoder().decode(AuthResponseDTO.self, from: data)
            await tokenProvider.setup(dto)
        } catch {
            print("Error \(error)")
        }
    }
}
