# Getting Started

Learn how to install SwiftKupo and make your first API call to a Kupo server.

## Overview

This guide will walk you through installing SwiftKupo, setting up a basic client, and making your first API call to query blockchain data from a Kupo server.

## Prerequisites

Before getting started, make sure you have:

- **Xcode 15.0+** or **Swift 6.2+** for command-line development
- **iOS 14.0+**, **macOS 13.0+**, **watchOS 7.0+**, or **tvOS 14.0+** as your deployment target
- A running **Kupo server** (see [Kupo Installation](#kupo-installation) below)

## Installation

### Swift Package Manager

Add SwiftKupo to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/swift-kupo", from: "1.0.0")
]
```

Then add it to your target:

```swift
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["SwiftKupo"]
    )
]
```

### Xcode Integration

1. In Xcode, select **File** → **Add Package Dependencies...**
2. Enter the repository URL: `https://github.com/your-username/swift-kupo`
3. Choose your version requirements and click **Add Package**
4. Select your target and click **Add Package**

## Kupo Installation

You'll need a running Kupo server to use SwiftKupo. Here are the quickest ways to get one:

### Via Homebrew (macOS)

```bash
brew tap CardanoSolutions/formulas
brew install kupo
```

### Via Docker

```bash
docker pull cardanosolutions/kupo
```

For detailed installation instructions, see the [Kupo documentation](https://github.com/CardanoSolutions/kupo#installation).

## Your First API Call

Let's create a simple Swift application that connects to Kupo and queries some blockchain data.

### Step 1: Import SwiftKupo

```swift
import SwiftKupo
import OpenAPIURLSession
import Foundation
```

### Step 2: Create a Kupo Client

```swift
// Create a Kupo client pointing to your server
let kupo = try Kupo(basePath: "http://localhost:1442")
```

> **Note**: The default Kupo server runs on port 1442. Adjust the URL if your server uses a different port or hostname.

### Step 3: Check Server Health

Before making data queries, let's verify the server is running:

```swift
func checkKupoHealth() async throws {
    let healthResponse = try await kupo.client.getHealth(
        headers: .init(accept: [
            .init(contentType: .applicationJsonCharsetUtf8)
        ])
    )
    
    switch healthResponse {
    case .ok(let okResponse):
        let health = try okResponse.body.applicationJsonCharsetUtf8
        print("✅ Kupo server is healthy!")
        print("Connection Status: \(health.connectionStatus)")
        print("Version: \(health.version)")
        print("Indexes: \(health.configuration.indexes)")
    default:
        print("❌ Health check failed")
    }
}
```

### Step 4: Query UTxOs

Now let's query some UTxOs using an address pattern:

```swift
func queryUTxOs() async throws {
    // Create an address pattern for a Cardano address
    let addressPattern = Components.Schemas.AddressPattern(
        credentialsPattern: nil,
        shelleyAddressPattern: .bech32("addr_test1qp4kux2v7xcg9urqssdffff5p0axz9e3hcc43zz7pcuyle0e20hkwsu2ndpd9dh9anm4jn76ljdz0evj22stzrw9egxqmza5y3"),
        stakeAddressPattern: nil,
        bootstrapAddressPattern: nil
    )
    
    // Query matches for this address
    let response = try await kupo.client.matchPattern(
        path: .init(
            pattern: .init(addressPattern: addressPattern)
        ),
        query: .init(
            resolveHashes: true,    // Include full datum/script data
            unspent: true,          // Only unspent outputs
            order: .mostRecentFirst // Newest first
        ),
        headers: .init(accept: [
            .init(contentType: .applicationJsonCharsetUtf8)
        ])
    )
    
    // Process the results
    switch response {
    case .ok(let okResponse):
        let matches = try okResponse.body.applicationJsonCharsetUtf8
        print("Found \\(matches.count) UTxO(s)")
        
        for match in matches {
            print("\\n🔹 UTxO: \\(match.transactionId)#\\(match.outputIndex)")
            print("   Value: \\(match.value.coins) lovelace")
            
            // Check for native assets
            if !match.value.assets.additionalProperties.isEmpty {
                print("   Assets:")
                for (assetId, amount) in match.value.assets.additionalProperties {
                    print("     - \\(assetId): \\(amount)")
                }
            }
            
            // Check for datum
            if let datum = match.datum {
                print("   Datum: \\(datum)")
            }
            
            // Show creation info
            print("   Created at slot: \\(match.createdAt.slotNo)")
        }
    default:
        print("❌ Query failed")
    }
}
```

### Step 5: Put It All Together

Here's a complete example that demonstrates the basic usage:

```swift
import SwiftKupo
import OpenAPIURLSession
import Foundation

@main
struct KupoExample {
    static func main() async {
        do {
            // Create Kupo client
            let kupo = try Kupo(basePath: "http://localhost:1442")
            
            // Check server health
            await checkHealth(kupo: kupo)
            
            // Query some UTxOs
            await queryUTxOs(kupo: kupo)
            
        } catch {
            print("❌ Error: \\(error)")
        }
    }
    
    static func checkHealth(kupo: Kupo) async {
        do {
            let healthResponse = try await kupo.client.getHealth(
                headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
            )
            
            if case .ok(let okResponse) = healthResponse {
                let health = try okResponse.body.applicationJsonCharsetUtf8
                print("✅ Kupo server is healthy (v\\(health.version))")
            }
        } catch {
            print("❌ Health check failed: \\(error)")
        }
    }
    
    static func queryUTxOs(kupo: Kupo) async {
        // Implementation from Step 4 above
    }
}
```

## Error Handling

SwiftKupo provides structured error handling. Here are common scenarios:

```swift
do {
    let response = try await kupo.client.getHealth(/* ... */)
    // Handle success
} catch let error as KupoError {
    switch error {
    case .invalidBasePath(let message):
        print("Invalid base path: \\(message ?? "Unknown error")")
    case .valueError(let message):
        print("Value error: \\(message ?? "Unknown error")")
    }
} catch {
    print("Network or other error: \\(error)")
}
```

## Next Steps

Now that you have SwiftKupo working, explore these advanced topics:

- **<doc:API-Usage>**: Learn about all available API endpoints
- **<doc:PatternExtensions>**: Discover semantic extensions for better developer experience  
- **<doc:AdvancedTopics>**: Error handling, configuration, and best practices

## Troubleshooting

### Common Issues

**"Connection refused"**
- Verify your Kupo server is running on the specified port
- Check firewall settings
- Confirm the server URL is correct

**"Invalid base path"**
- Ensure the URL includes the protocol (http:// or https://)
- Verify the hostname and port are correct

**Build errors**
- Make sure you're using Swift 6.2+ and supported platform versions
- Clean your build folder: `swift package clean`

For more help, see the [Kupo documentation](https://github.com/CardanoSolutions/kupo) or check the project issues on GitHub.