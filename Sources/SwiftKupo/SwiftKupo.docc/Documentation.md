# ``SwiftKupo``

A Swift Package Manager library providing a type-safe client for the Kupo API.

## Overview

SwiftKupo generates Swift client code from the OpenAPI 3.0 specification using Apple's Swift OpenAPI Generator, providing strongly-typed interfaces for iOS, macOS, watchOS, and tvOS applications.

**Kupo** is a fast, lightweight chain indexer for the Cardano blockchain that synchronizes UTxOs, datums, scripts, and other on-chain data according to configurable patterns. SwiftKupo makes it easy to integrate with Kupo from your Swift applications.

### Key Features

- **Type Safety**: Strongly-typed interfaces for all API endpoints and models
- **Auto-generated**: Swift code automatically generated from OpenAPI specification
- **Semantic Extensions**: Enhanced Pattern types with meaningful property names
- **Multi-platform**: Support for iOS, macOS, watchOS, and tvOS
- **Modern Swift**: Built with async/await and structured concurrency
- **OpenAPI-driven**: Stays in sync with Kupo API changes automatically

### Quick Example

```swift
import SwiftKupo

// Create a Kupo client
let kupo = try Kupo(basePath: "http://localhost:1442")

// Query UTxOs for an address
let response = try await kupo.client.matchPattern(
    path: .init(pattern: .init(addressPattern: addressPattern)),
    query: .init(unspent: true, resolveHashes: true)
)

// Process results with type safety
switch response {
case .ok(let okResponse):
    let matches = try okResponse.body.applicationJsonCharsetUtf8
    for match in matches {
        print("UTxO: \(match.transactionId)#\(match.outputIndex)")
        print("Value: \(match.value.coins) lovelace")
    }
default:
    print("Request failed")
}
```

## Topics

### Getting Started

- <doc:GettingStarted>
- <doc:API-Usage>

### Core Types

- ``Kupo``
- ``KupoError``

### Pattern Extensions

- <doc:PatternExtensions>

### Advanced Usage

- <doc:AdvancedTopics>
- <doc:Migration>

### Resources

- <doc:Resources>
