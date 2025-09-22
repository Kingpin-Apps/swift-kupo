import Foundation
import OpenAPIRuntime
import OpenAPIURLSession
import HTTPTypes

/// A type-safe Swift client for interacting with Kupo API servers.
///
/// `Kupo` provides a high-level interface to query blockchain data from a Kupo server,
/// which is a fast, lightweight chain indexer for the Cardano blockchain.
///
/// ## Usage
///
/// Create a Kupo client and query UTxOs:
///
/// ```swift
/// let kupo = try Kupo(basePath: "http://localhost:1442")
///
/// let response = try await kupo.client.getHealth(
///     headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
/// )
///
/// switch response {
/// case .ok(let okResponse):
///     let health = try okResponse.body.applicationJsonCharsetUtf8
///     print("Server Status: \(health.connectionStatus)")
/// default:
///     print("Health check failed")
/// }
/// ```
///
/// ## What is Kupo?
///
/// Kupo is a chain indexer that provides:
/// - **UTxO Indexing**: Track unspent transaction outputs by address patterns
/// - **Datum Resolution**: Access Plutus data associated with UTxOs
/// - **Script Access**: Retrieve native and Plutus scripts
/// - **Pattern Matching**: Flexible address, asset, and transaction filtering
/// - **Rollback Handling**: Proper chain reorganization support
///
/// ## Topics
///
/// ### Creating a Client
/// - ``init(basePath:client:)``
///
/// ### API Access
/// - ``client``
///
/// ### Error Handling
/// - ``KupoError``
public struct Kupo {
    /// The underlying OpenAPI-generated client for making HTTP requests to the Kupo server.
    ///
    /// Use this client to access all Kupo API endpoints with full type safety.
    /// The client handles request serialization, response deserialization, and HTTP transport.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let kupo = try Kupo()
    /// let healthResponse = try await kupo.client.getHealth(
    ///     headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
    /// )
    /// ```
    public let client: Client
    
    /// Creates a new Kupo client instance.
    ///
    /// - Parameters:
    ///   - basePath: The base URL of the Kupo server. Defaults to `http://localhost:1442` if not specified.
    ///   - client: A pre-configured OpenAPI client. If not provided, a new client will be created with default settings.
    ///
    /// - Throws: ``KupoError/invalidBasePath(_:)`` if the provided `basePath` cannot be converted to a valid URL.
    ///
    /// ## Examples
    ///
    /// ### Default Configuration
    /// ```swift
    /// let kupo = try Kupo()
    /// // Connects to http://localhost:1442
    /// ```
    ///
    /// ### Custom Server URL
    /// ```swift
    /// let kupo = try Kupo(basePath: "https://kupo.example.com")
    /// ```
    ///
    /// ### Custom Client Configuration
    /// ```swift
    /// let customClient = Client(
    ///     serverURL: URL(string: "http://localhost:1442")!,
    ///     transport: URLSessionTransport()
    /// )
    /// let kupo = try Kupo(client: customClient)
    /// ```
    ///
    /// - Note: The default Kupo server runs on port 1442. Make sure your Kupo server is running and accessible at the specified URL.
    public init(
        basePath: String? = nil,
        client: Client? = nil
    ) throws {
        let serverURL: URL
        if let basePath = basePath {
            guard let url = URL(string: basePath) else {
                throw KupoError.invalidBasePath("Invalid base path: \(basePath)")
            }
            serverURL = url
        } else {
            serverURL = URL(string: "http://localhost:1442")!
        }
        
        self.client = client ?? Client(
            serverURL: serverURL,
            transport: URLSessionTransport()
        )
    }
}
