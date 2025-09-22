# Advanced Topics

Deep dive into SwiftKupo's advanced features, error handling, and architectural best practices.

## Overview

This guide covers advanced usage patterns, error handling strategies, performance optimization, and architectural considerations for building robust applications with SwiftKupo.

## Error Handling

### SwiftKupo Error Types

SwiftKupo defines specific error types for different scenarios:

```swift
enum KupoError: Error, CustomStringConvertible, Equatable {
    case invalidBasePath(String?)
    case valueError(String?)
    
    var description: String {
        switch self {
        case .invalidBasePath(let message):
            return message ?? "Invalid base path."
        case .valueError(let message):
            return message ?? "The value is invalid."
        }
    }
}
```

### Comprehensive Error Handling

```swift
func robustKupoCall() async {
    do {
        let kupo = try Kupo(basePath: "http://localhost:1442")
        let response = try await kupo.client.getHealth(
            headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
        )
        
        switch response {
        case .ok(let okResponse):
            let health = try okResponse.body.applicationJsonCharsetUtf8
            print("Health: \(health.connectionStatus)")
            
        case .badRequest:
            print("Bad request - check parameters")
            
        case .internalServerError:
            print("Server error - check Kupo logs")
            
        case .undocumented(statusCode: let code, _):
            print("Unexpected status: \(code)")
        }
        
    } catch let error as KupoError {
        switch error {
        case .invalidBasePath(let message):
            print("Invalid base path: \(message ?? "Unknown")")
        case .valueError(let message):
            print("Value error: \(message ?? "Unknown")")
        }
        
    } catch let error as URLError {
        switch error.code {
        case .cannotConnectToHost:
            print("Cannot connect to Kupo server")
        case .timedOut:
            print("Request timed out")
        case .networkConnectionLost:
            print("Network connection lost")
        default:
            print("Network error: \(error.localizedDescription)")
        }
        
    } catch {
        print("Unexpected error: \(error)")
    }
}
```

### Retry Strategies

Implement exponential backoff for transient failures:

```swift
import Foundation

extension Kupo {
    func callWithRetry<T>(
        maxRetries: Int = 3,
        baseDelay: TimeInterval = 1.0,
        operation: () async throws -> T
    ) async throws -> T {
        var lastError: Error?
        
        for attempt in 0..<maxRetries {
            do {
                return try await operation()
            } catch let error as URLError where error.code.isTransient {
                lastError = error
                
                if attempt < maxRetries - 1 {
                    let delay = baseDelay * pow(2.0, Double(attempt))
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            } catch {
                // Non-transient error, don't retry
                throw error
            }
        }
        
        throw lastError ?? KupoError.valueError("Max retries exceeded")
    }
}

extension URLError.Code {
    var isTransient: Bool {
        switch self {
        case .timedOut, .cannotConnectToHost, .networkConnectionLost, .notConnectedToInternet:
            return true
        default:
            return false
        }
    }
}
```

Usage:

```swift
let health = try await kupo.callWithRetry {
    try await kupo.client.getHealth(
        headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
    )
}
```

## Configuration and Customization

### Custom HTTP Client Configuration

```swift
import OpenAPIURLSession
import Foundation

extension Kupo {
    static func withCustomConfiguration(
        basePath: String,
        timeout: TimeInterval = 30.0,
        additionalHeaders: [String: String] = [:]
    ) throws -> Kupo {
        // Configure URLSession
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout * 2
        
        // Add custom headers if needed
        var headers = config.httpAdditionalHeaders ?? [:]
        for (key, value) in additionalHeaders {
            headers[key] = value
        }
        config.httpAdditionalHeaders = headers
        
        let session = URLSession(configuration: config)
        let transport = URLSessionTransport(session: session)
        
        guard let serverURL = URL(string: basePath) else {
            throw KupoError.invalidBasePath("Invalid base path: \(basePath)")
        }
        
        let client = Client(
            serverURL: serverURL,
            transport: transport
        )
        
        return try Kupo(client: client)
    }
}
```

### Environment-Based Configuration

```swift
enum Environment {
    case development
    case staging  
    case production
    
    var kupoBaseURL: String {
        switch self {
        case .development:
            return "http://localhost:1442"
        case .staging:
            return "https://kupo-staging.example.com"
        case .production:
            return "https://kupo.example.com"
        }
    }
    
    var timeout: TimeInterval {
        switch self {
        case .development:
            return 10.0
        case .staging, .production:
            return 30.0
        }
    }
}

extension Kupo {
    static func forEnvironment(_ env: Environment) throws -> Kupo {
        return try withCustomConfiguration(
            basePath: env.kupoBaseURL,
            timeout: env.timeout
        )
    }
}
```

## Performance Optimization

### Connection Pooling and Reuse

Reuse Kupo instances rather than creating new ones:

```swift
actor KupoManager {
    private var kupoInstance: Kupo?
    
    func getKupo() throws -> Kupo {
        if let existing = kupoInstance {
            return existing
        }
        
        let kupo = try Kupo.withCustomConfiguration(
            basePath: "http://localhost:1442",
            timeout: 30.0
        )
        kupoInstance = kupo
        return kupo
    }
    
    func reset() {
        kupoInstance = nil
    }
}

// Global manager
let kupoManager = KupoManager()
```

### Batching and Concurrent Requests

Execute multiple independent requests concurrently:

```swift
func fetchMultipleAddressData(addresses: [String]) async throws -> [String: [Components.Schemas.Match]] {
    let kupo = try await kupoManager.getKupo()
    
    // Create concurrent tasks
    let tasks = addresses.map { address in
        Task {
            let pattern = Components.Parameters.Pattern(
                addressPattern: Components.Schemas.AddressPattern(
                    shelleyAddressPattern: .bech32(address)
                )
            )
            
            let response = try await kupo.client.matchPattern(
                path: .init(pattern: pattern),
                query: .init(unspent: true, resolveHashes: false),
                headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
            )
            
            if case .ok(let okResponse) = response {
                return (address, try okResponse.body.applicationJsonCharsetUtf8)
            } else {
                return (address, [Components.Schemas.Match]())
            }
        }
    }
    
    // Await all results
    var results: [String: [Components.Schemas.Match]] = [:]
    for task in tasks {
        let (address, matches) = try await task.value
        results[address] = matches
    }
    
    return results
}
```

### Response Caching

Implement intelligent caching for frequently accessed data:

```swift
import Foundation

actor ResponseCache {
    private var cache: [String: CacheEntry] = [:]
    private let maxAge: TimeInterval = 300 // 5 minutes
    
    struct CacheEntry {
        let data: Data
        let timestamp: Date
        let etag: String?
    }
    
    func get(key: String) -> CacheEntry? {
        guard let entry = cache[key],
              Date().timeIntervalSince(entry.timestamp) < maxAge else {
            cache.removeValue(forKey: key)
            return nil
        }
        return entry
    }
    
    func set(key: String, data: Data, etag: String? = nil) {
        cache[key] = CacheEntry(
            data: data,
            timestamp: Date(),
            etag: etag
        )
    }
    
    func clear() {
        cache.removeAll()
    }
}

let responseCache = ResponseCache()

extension Kupo {
    func getCachedHealth() async throws -> Components.Schemas.Health {
        let cacheKey = "health"
        
        // Try cache first
        if let cached = await responseCache.get(key: cacheKey) {
            return try JSONDecoder().decode(Components.Schemas.Health.self, from: cached.data)
        }
        
        // Fetch from server
        let response = try await client.getHealth(
            headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
        )
        
        if case .ok(let okResponse) = response {
            let health = try okResponse.body.applicationJsonCharsetUtf8
            
            // Cache the result
            let data = try JSONEncoder().encode(health)
            await responseCache.set(key: cacheKey, data: data)
            
            return health
        } else {
            throw KupoError.valueError("Failed to get health")
        }
    }
}
```

## Architectural Patterns

### Repository Pattern

Encapsulate Kupo operations behind a clean interface:

```swift
protocol KupoRepository {
    func getHealth() async throws -> Components.Schemas.Health
    func findUTxOs(for address: String) async throws -> [Components.Schemas.Match]
    func findUTxOs(containing assetId: String) async throws -> [Components.Schemas.Match]
    func getDatum(hash: String) async throws -> Components.Schemas.Metadatum?
    func getScript(hash: String) async throws -> Components.Schemas.Script?
}

class DefaultKupoRepository: KupoRepository {
    private let kupo: Kupo
    
    init(kupo: Kupo) {
        self.kupo = kupo
    }
    
    func getHealth() async throws -> Components.Schemas.Health {
        return try await kupo.getCachedHealth()
    }
    
    func findUTxOs(for address: String) async throws -> [Components.Schemas.Match] {
        let pattern = Components.Parameters.Pattern(
            addressPattern: Components.Schemas.AddressPattern(
                shelleyAddressPattern: .bech32(address)
            )
        )
        
        let response = try await kupo.client.matchPattern(
            path: .init(pattern: pattern),
            query: .init(unspent: true),
            headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
        )
        
        guard case .ok(let okResponse) = response else {
            return []
        }
        
        return try okResponse.body.applicationJsonCharsetUtf8
    }
    
    func findUTxOs(containing assetId: String) async throws -> [Components.Schemas.Match] {
        let pattern = Components.Parameters.Pattern(assetIdPattern: assetId)
        
        let response = try await kupo.client.matchPattern(
            path: .init(pattern: pattern),
            query: .init(unspent: true),
            headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
        )
        
        guard case .ok(let okResponse) = response else {
            return []
        }
        
        return try okResponse.body.applicationJsonCharsetUtf8
    }
    
    func getDatum(hash: String) async throws -> Components.Schemas.Metadatum? {
        let response = try await kupo.client.getDatum(
            path: .init(datumHash: hash),
            headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
        )
        
        switch response {
        case .ok(let okResponse):
            return try okResponse.body.applicationJsonCharsetUtf8
        case .notFound:
            return nil
        default:
            throw KupoError.valueError("Failed to get datum")
        }
    }
    
    func getScript(hash: String) async throws -> Components.Schemas.Script? {
        let response = try await kupo.client.getScript(
            path: .init(scriptHash: hash),
            headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
        )
        
        switch response {
        case .ok(let okResponse):
            return try okResponse.body.applicationJsonCharsetUtf8
        case .notFound:
            return nil
        default:
            throw KupoError.valueError("Failed to get script")
        }
    }
}
```

### Service Layer

Create higher-level services that encapsulate business logic:

```swift
class WalletService {
    private let kupoRepository: KupoRepository
    
    init(kupoRepository: KupoRepository) {
        self.kupoRepository = kupoRepository
    }
    
    func getWalletBalance(address: String) async throws -> WalletBalance {
        let utxos = try await kupoRepository.findUTxOs(for: address)
        
        var totalAda: UInt64 = 0
        var assets: [String: UInt64] = [:]
        
        for utxo in utxos {
            totalAda += utxo.value.coins
            
            for (assetId, quantity) in utxo.value.assets.additionalProperties {
                assets[assetId, default: 0] += quantity
            }
        }
        
        return WalletBalance(
            address: address,
            adaBalance: totalAda,
            assets: assets,
            utxoCount: utxos.count
        )
    }
    
    func findUTxOsWithAsset(address: String, assetId: String) async throws -> [Components.Schemas.Match] {
        let utxos = try await kupoRepository.findUTxOs(for: address)
        
        return utxos.filter { utxo in
            utxo.value.assets.additionalProperties.contains { key, _ in
                key.hasPrefix(assetId)
            }
        }
    }
}

struct WalletBalance {
    let address: String
    let adaBalance: UInt64
    let assets: [String: UInt64]
    let utxoCount: Int
}
```

## Testing Strategies

### Mock Transport for Testing

Create a mock transport for unit tests:

```swift
import OpenAPIRuntime
import HTTPTypes
import Foundation

struct MockKupoTransport: ClientTransport {
    let responses: [String: (HTTPResponse, HTTPBody?)]
    
    func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        
        if let (response, responseBody) = responses[operationID] {
            return (response, responseBody)
        }
        
        // Default to 404 for unhandled operations
        return (HTTPResponse(status: .notFound), nil)
    }
}

// Usage in tests
func testHealthEndpoint() async throws {
    let mockHealth = Components.Schemas.Health(
        connectionStatus: .connected,
        configuration: .init(indexes: .installed),
        version: "test"
    )
    
    let mockData = try JSONEncoder().encode(mockHealth)
    let mockTransport = MockKupoTransport(responses: [
        "getHealth": (
            HTTPResponse(
                status: .ok,
                headerFields: [.contentType: "application/json"]
            ),
            HTTPBody(mockData)
        )
    ])
    
    let kupo = try Kupo(
        client: Client(
            serverURL: URL(string: "http://localhost:1442")!,
            transport: mockTransport
        )
    )
    
    let health = try await kupo.getCachedHealth()
    assert(health.connectionStatus == .connected)
}
```

### Integration Testing

Test against a real Kupo instance:

```swift
import XCTest

class KupoIntegrationTests: XCTestCase {
    var kupo: Kupo!
    
    override func setUp() async throws {
        // Skip if no test Kupo server available
        guard ProcessInfo.processInfo.environment["KUPO_TEST_URL"] != nil else {
            throw XCTSkip("KUPO_TEST_URL not set")
        }
        
        let testURL = ProcessInfo.processInfo.environment["KUPO_TEST_URL"]!
        kupo = try Kupo(basePath: testURL)
        
        // Verify server is available
        let health = try await kupo.getCachedHealth()
        XCTAssertEqual(health.connectionStatus, .connected)
    }
    
    func testFetchUTxOs() async throws {
        let testAddress = "addr_test1..." // Use a known test address
        
        let repository = DefaultKupoRepository(kupo: kupo)
        let utxos = try await repository.findUTxOs(for: testAddress)
        
        // Verify results are reasonable
        XCTAssertTrue(utxos.count >= 0) // Could be 0 for empty addresses
    }
}
```

## Monitoring and Observability

### Health Checks

Implement periodic health monitoring:

```swift
import Foundation

actor HealthMonitor {
    private let kupoRepository: KupoRepository
    private let checkInterval: TimeInterval
    private var isMonitoring = false
    
    init(kupoRepository: KupoRepository, checkInterval: TimeInterval = 60.0) {
        self.kupoRepository = kupoRepository
        self.checkInterval = checkInterval
    }
    
    func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true
        
        Task {
            while isMonitoring {
                do {
                    let health = try await kupoRepository.getHealth()
                    await handleHealthUpdate(health)
                } catch {
                    await handleHealthError(error)
                }
                
                try await Task.sleep(nanoseconds: UInt64(checkInterval * 1_000_000_000))
            }
        }
    }
    
    func stopMonitoring() {
        isMonitoring = false
    }
    
    private func handleHealthUpdate(_ health: Components.Schemas.Health) {
        // Log health status, emit metrics, etc.
        print("Kupo Health: \(health.connectionStatus), Version: \(health.version)")
    }
    
    private func handleHealthError(_ error: Error) {
        // Log error, emit alerts, etc.
        print("Kupo Health Check Failed: \(error)")
    }
}
```

### Logging

Implement structured logging for debugging:

```swift
import OSLog

extension Kupo {
    private static let logger = Logger(subsystem: "com.example.app", category: "kupo")
    
    func loggedRequest<T>(
        operation: String,
        request: () async throws -> T
    ) async throws -> T {
        Self.logger.info("Starting \(operation)")
        let startTime = Date()
        
        do {
            let result = try await request()
            let duration = Date().timeIntervalSince(startTime)
            Self.logger.info("Completed \(operation) in \(duration)s")
            return result
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            Self.logger.error("Failed \(operation) after \(duration)s: \(error)")
            throw error
        }
    }
}
```

## Best Practices

### 1. Resource Management

Always properly manage Kupo instances:

```swift
// Good - reuse instances
let kupo = try Kupo.forEnvironment(.production)
// Use kupo for multiple requests

// Avoid - creating new instances for each request
// let kupo1 = try Kupo()
// let kupo2 = try Kupo()
// let kupo3 = try Kupo()
```

### 2. Error Boundaries

Implement proper error boundaries:

```swift
func safeKupoOperation<T>(
    operation: () async throws -> T,
    fallback: T
) async -> T {
    do {
        return try await operation()
    } catch {
        // Log error and return fallback
        print("Kupo operation failed: \(error)")
        return fallback
    }
}
```

### 3. Graceful Degradation

Design your app to work even when Kupo is unavailable:

```swift
func getWalletData(address: String) async -> WalletData {
    do {
        let balance = try await walletService.getWalletBalance(address: address)
        return WalletData.fromBalance(balance)
    } catch {
        // Return cached data or empty state
        return WalletData.unavailable(address: address)
    }
}
```

## Next Steps

- **<doc:Migration>**: Learn about handling version updates and breaking changes
- **<doc:Resources>**: Explore external resources and community tools