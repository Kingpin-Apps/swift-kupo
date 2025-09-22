# SwiftKupo

A Swift Package Manager library providing a type-safe client for the [Kupo API](https://github.com/CardanoSolutions/kupo). SwiftKupo generates Swift client code from the OpenAPI 3.0 specification using Apple's Swift OpenAPI Generator, providing strongly-typed interfaces for iOS, macOS, watchOS, and tvOS applications.

## What is Kupo?

Kupo is a fast, lightweight chain indexer for the Cardano blockchain that synchronizes UTxOs, datums, scripts, and other on-chain data according to configurable patterns. It provides:

- **UTxO Indexing**: Track unspent transaction outputs by address patterns
- **Datum Resolution**: Access Plutus data associated with UTxOs  
- **Script Access**: Retrieve native and Plutus scripts
- **Pattern Matching**: Flexible address, asset, and transaction filtering
- **Rollback Handling**: Proper chain reorganization support

## Features

- ✅ **Auto-generated Client**: Swift code generated from OpenAPI 3.0 specification
- ✅ **Type Safety**: Strongly-typed interfaces for all API endpoints and models
- ✅ **Semantic Extensions**: Enhanced Pattern types with meaningful property names
- ✅ **Multi-platform**: Support for iOS, macOS, watchOS, and tvOS
- ✅ **Async/Await**: Modern Swift concurrency support
- ✅ **OpenAPI-driven**: Automatically stays in sync with Kupo API changes

## Installation

### Swift Package Manager

Add SwiftKupo to your `Package.swift` dependencies:

```swift path=null start=null
dependencies: [
    .package(url: "https://github.com/your-username/swift-kupo", from: "1.0.0")
]
```

### Xcode

1. In Xcode, go to **File** ▸ **Add Packages...**
2. Enter the repository URL: `https://github.com/your-username/swift-kupo`
3. Click **Add Package**

### Requirements

- iOS 14.0+ / macOS 13.0+ / watchOS 7.0+ / tvOS 14.0+
- Swift 6.2+
- Xcode 15.0+

## Quick Start

```swift path=null start=null
import SwiftKupo
import OpenAPIURLSession

// Create client
let kupo = try Kupo(basePath: "http://localhost:1442")

// Query unspent UTxOs for an address
let response = try await kupo.client.matchPattern(
    path: .init(
        pattern: .init(
            addressPattern: .init(
                shelleyAddressPattern: .bech32("addr1vy3qpx09uscywhpp0ekg9zwmq2yj5vp08husfq6qyh2mpps865j6t")
            )
        )
    ),
    query: .init(
        resolveHashes: true,
        unspent: true,
        order: .mostRecentFirst
    ),
    headers: .init(accept: [
        .init(contentType: .applicationJsonCharsetUtf8)
    ])
)

// Process results
switch response {
case .ok(let okResponse):
    let matches = try okResponse.body.applicationJsonCharsetUtf8
    for match in matches {
        print("UTxO: \(match.transactionId)#\(match.outputIndex)")
        print("Value: \(match.value.coins) lovelace")
        
        if let datum = match.datum {
            print("Datum: \(datum)")
        }
    }
default:
    print("Request failed")
}
```

## API Overview

SwiftKupo provides type-safe access to all Kupo API endpoints:

- **`GET /matches/{pattern}`**: Query UTxOs by address, asset, or output reference patterns
- **`GET /matches`**: Get all indexed matches with optional filtering
- **`GET /datums/{datum-hash}`**: Retrieve datum by hash
- **`GET /scripts/{script-hash}`**: Retrieve script by hash  
- **`GET /health`**: Check indexer status and sync progress
- **`GET /checkpoints`**: View synchronization checkpoints

### Common Query Parameters

- `resolveHashes`: Include full datums and scripts in responses
- `unspent`: Filter to only unspent UTxOs
- `spent`: Filter to only spent UTxOs
- `order`: Control result ordering (`mostRecentFirst` or `oldestFirst`)

## Pattern Extensions

SwiftKupo includes semantic extensions for better developer experience with Pattern types. The generated Pattern types use generic names (`value1`, `value2`, etc.), but our extensions provide meaningful property names:

### Pattern Type Extensions

```swift path=null start=null
// Pattern with semantic properties
var pattern = Components.Parameters.Pattern()
pattern.wildcard = ._ast_                    // Matches everything (*)
pattern.addressPattern = someAddressPattern  // Address-specific patterns
pattern.assetIdPattern = "policy.asset"      // Asset-specific patterns
pattern.outputReferencePattern = "tx#index"  // Output reference patterns

// Pattern with convenience initializer
let pattern = Components.Parameters.Pattern(
    wildcard: ._ast_,
    addressPattern: nil,
    assetIdPattern: "1220099e5e430475c219518179efc7e6c8289db028904834025d5b086.*",
    outputReferencePattern: nil
)
```

### AddressPattern Extensions

```swift path=null start=null
// AddressPattern with semantic properties
let addressPattern = Components.Schemas.AddressPattern(
    credentialsPattern: "*/*",
    shelleyAddressPattern: .bech32("addr1vy3qpx09uscywhpp0ekg9zwmq2yj5vp08husfq6qyh2mpps865j6t"),
    stakeAddressPattern: nil,
    bootstrapAddressPattern: nil
)

// Using convenience constructors
let shelleyAddr = Components.Schemas.AddressPattern.Value2Payload.bech32("addr_test1...")
let byronAddr = Components.Schemas.AddressPattern.Value4Payload.base58("DdzFFz...")

// Extract address string regardless of format
if let shelleyPattern = addressPattern.shelleyAddressPattern {
    let addressString = shelleyPattern.addressString
    print("Address: \(addressString)")
}
```

## Development

### Building the Library

```bash
# Clean build with code generation
swift build

# Build for release
swift build -c release
```

### Running Tests

```bash
# Run all tests
swift test

# Run specific test
swift test --filter SwiftKupoTests

# Run tests with verbose output
swift test --verbose
```

### Code Generation

The OpenAPI Generator runs automatically during build via Swift Package Manager plugins. Generated code includes:

- **`Types.swift`**: All data models, enums, and schemas from the API
- **`Client.swift`**: HTTP client with type-safe methods for all endpoints

Generated files are placed in `.build/plugins/outputs/swift-kupo/SwiftKupo/destination/OpenAPIGenerator/GeneratedSources/`

### Adding New Endpoints

1. Edit `Sources/SwiftKupo/openapi.yaml` to add the new endpoint specification
2. Run `swift build` to trigger code regeneration
3. Add tests in `Tests/SwiftKupoTests/` to cover new functionality
4. Run tests with `swift test`

### Development Workflow

1. **Making Changes**: Edit OpenAPI spec or configuration files
2. **Code Generation**: Run `swift build` to regenerate client
3. **Testing**: Use `swift test` to verify functionality
4. **Integration**: Generated types work seamlessly with SwiftUI and Combine

## Platform Support

| Platform | Minimum Version |
|----------|----------------|
| iOS      | 14.0+          |
| macOS    | 13.0+          |
| watchOS  | 7.0+           |
| tvOS     | 14.0+          |
| Swift    | 6.2+           |

## Health Check Example

```swift path=null start=null
// Check Kupo server health
let healthResponse = try await kupo.client.getHealth(
    headers: .init(accept: [
        .init(contentType: .applicationJsonCharsetUtf8)
    ])
)

switch healthResponse {
case .ok(let okResponse):
    let health = try okResponse.body.applicationJsonCharsetUtf8
    print("Connection Status: \(health.connectionStatus)")
    print("Version: \(health.version)")
    print("Indexes: \(health.configuration.indexes)")
default:
    print("Health check failed")
}
```

## Troubleshooting

### Build Failures

- Ensure OpenAPI specification is valid YAML
- Check that all parameter definitions include either `schema` or `content`
- Clean build: `swift package clean && swift build`

### API Integration Issues

- Verify Kupo server is running and accessible at the specified URL
- Check network connectivity and firewall settings
- Review Kupo logs for API errors

## Links & Resources

### Kupo Documentation & Installation

- **[Kupo GitHub Repository](https://github.com/CardanoSolutions/kupo)**: Main repository with documentation
- **[Kupo API Documentation](https://cardanosolutions.github.io/kupo/)**: Interactive API documentation
- **[Kupo Installation Guide](https://github.com/CardanoSolutions/kupo#installation)**: Installation via Homebrew, Docker, or from source

### Swift OpenAPI Generator

- **[Swift OpenAPI Generator](https://github.com/apple/swift-openapi-generator)**: Apple's code generation tool
- **[Swift OpenAPI Runtime](https://github.com/apple/swift-openapi-runtime)**: Runtime support library

### Related Cardano Swift Packages

- **[swift-cardano-core](https://github.com/your-org/swift-cardano-core)**: Core Cardano types and utilities
- **[swift-cardano-chain](https://github.com/your-org/swift-cardano-chain)**: Blockchain data structures
- **[swift-blockfrost-api](https://github.com/your-org/swift-blockfrost-api)**: Blockfrost API client
- **[swift-ogmios](https://github.com/your-org/swift-ogmios)**: Ogmios WebSocket client

### Cardano Documentation

- **[Cardano Developer Portal](https://developers.cardano.org/)**: Official Cardano development resources
- **[Cardano Documentation](https://docs.cardano.org/)**: Comprehensive Cardano documentation

## License

This project is licensed under the MPL-2.0 License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Run tests (`swift test`)
4. Commit your changes (`git commit -m 'Add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request