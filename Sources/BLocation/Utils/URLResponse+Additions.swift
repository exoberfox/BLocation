import Foundation

extension URLResponse {
    var isSucceed: Bool {
        (200 ..< 300).contains((self as? HTTPURLResponse)?.statusCode ?? 0)
    }

    var isAnauthorized: Bool {
        (self as? HTTPURLResponse)?.statusCode == 400
    }
}
