import Foundation
import HTTPTypes
import OpenAPIRuntime

/// Sends Kupo's boolean query flags the way Kupo reads them.
///
/// Kupo's flags — `resolve_hashes`, `spent`, `unspent` and `strict` — are
/// bare query keys (`?unspent`). Kupo rejects them with a value, so the
/// `?unspent=true` the generated client writes is a `400 Bad Request`. This
/// middleware rewrites `flag=true` to `flag` and drops `flag=false`.
///
/// ``Kupo/init(basePath:client:)`` installs it on the client it builds. Add it
/// yourself when you build a ``Client`` by hand:
///
/// ```swift
/// let client = Client(
///     serverURL: URL(string: "http://localhost:1442")!,
///     transport: URLSessionTransport(),
///     middlewares: [QueryFlagMiddleware()]
/// )
/// ```
public struct QueryFlagMiddleware: ClientMiddleware {
    /// The query keys Kupo reads as bare flags.
    public static let flags: Set<String> = ["resolve_hashes", "spent", "unspent", "strict"]

    public init() {}

    public func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        if let path = request.path {
            request.path = Self.rewrite(path)
        }
        return try await next(request, body, baseURL)
    }

    /// `path` with each `flag=true` made bare and each `flag=false` removed.
    static func rewrite(_ path: String) -> String {
        guard let mark = path.firstIndex(of: "?") else { return path }
        let items = path[path.index(after: mark)...]
            .split(separator: "&", omittingEmptySubsequences: true)
            .compactMap { item -> Substring? in
                let parts = item.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
                guard parts.count == 2, flags.contains(String(parts[0])) else { return item }
                switch parts[1] {
                case "true": return parts[0]
                case "false": return nil
                default: return item
                }
            }
        let base = path[..<mark]
        return items.isEmpty ? String(base) : base + "?" + items.joined(separator: "&")
    }
}
