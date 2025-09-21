import Foundation
import OpenAPIRuntime
import OpenAPIURLSession
import HTTPTypes


public struct Kupo {
    public let client: Client
    
    public init(
        basePath: String? = nil,
        client: Client? = nil,
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
