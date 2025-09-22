# API Usage

Comprehensive guide to using all SwiftKupo API endpoints with practical examples.

## Overview

SwiftKupo provides type-safe access to all Kupo API endpoints. This guide covers the most commonly used endpoints with detailed examples and best practices.

## Core Endpoints

### Health Check

Monitor your Kupo server's status and synchronization progress.

```swift
let healthResponse = try await kupo.client.getHealth(
    headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
)

switch healthResponse {
case .ok(let okResponse):
    let health = try okResponse.body.applicationJsonCharsetUtf8
    print("Server Status: \(health.connectionStatus)")
    print("Version: \(health.version)")
    print("Indexes: \(health.configuration.indexes)")
    
    // Check sync progress
    if let checkpoint = health.mostRecentCheckpoint {
        print("Last synced slot: \(checkpoint.slotNo)")
        print("Header hash: \(checkpoint.headerHash)")
    }
    
    if let nodeTip = health.mostRecentNodeTip {
        print("Node tip slot: \(nodeTip.slotNo)")
    }
    
default:
    print("Health check failed")
}
```

### Pattern Matching

Query UTxOs using flexible patterns to match addresses, assets, or output references.

#### Query by Address Pattern

```swift
// Create an address pattern
let addressPattern = Components.Schemas.AddressPattern(
    credentialsPattern: nil,
    shelleyAddressPattern: .bech32("addr_test1qp4kux2v7xcg9urqssdffff5p0axz9e3hcc43zz7pcuyle0e20hkwsu2ndpd9dh9anm4jn76ljdz0evj22stzrw9egxqmza5y3"),
    stakeAddressPattern: nil,
    bootstrapAddressPattern: nil
)

let response = try await kupo.client.matchPattern(
    path: .init(pattern: .init(addressPattern: addressPattern)),
    query: .init(
        resolveHashes: true,      // Include full datums and scripts
        unspent: true,            // Only unspent UTxOs
        spent: false,             // Exclude spent UTxOs
        order: .mostRecentFirst   // Sort by most recent first
    ),
    headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
)
```

#### Query by Asset Pattern

```swift
// Match all UTxOs containing a specific asset
let assetPattern = "1220099e5e430475c219518179efc7e6c8289db028904834025d5b086.*"

let response = try await kupo.client.matchPattern(
    path: .init(pattern: .init(assetIdPattern: assetPattern)),
    query: .init(resolveHashes: true, unspent: true),
    headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
)
```

#### Query by Output Reference

```swift
// Match a specific transaction output
let outputRef = "d61cd910f55919612e031f557bbb16421682afa1f85e3f2c0069b25776900c2e#1"

let response = try await kupo.client.matchPattern(
    path: .init(pattern: .init(outputReferencePattern: outputRef)),
    query: .init(resolveHashes: true),
    headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
)
```

#### Wildcard Pattern

```swift
// Match all UTxOs (use with caution!)
let response = try await kupo.client.matchPattern(
    path: .init(pattern: .init(wildcard: ._ast_)),
    query: .init(resolveHashes: false, unspent: true),
    headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
)
```

### Processing Match Results

```swift
switch response {
case .ok(let okResponse):
    let matches = try okResponse.body.applicationJsonCharsetUtf8
    
    for match in matches {
        print("UTxO: \(match.transactionId)#\(match.outputIndex)")
        print("Value: \(match.value.coins) lovelace")
        
        // Process native assets
        for (assetId, quantity) in match.value.assets.additionalProperties {
            print("Asset: \(assetId) = \(quantity)")
        }
        
        // Handle datum if present
        if let datum = match.datum {
            print("Datum: \(datum)")
        }
        
        // Check if spent
        if let spentAt = match.spentAt {
            print("Spent at slot: \(spentAt.slotNo)")
        } else {
            print("Unspent")
        }
        
        // Creation info
        print("Created at slot: \(match.createdAt.slotNo)")
        print("Block hash: \(match.createdAt.headerHash)")
    }
    
default:
    print("Query failed")
}
```

### Get All Matches

Retrieve all indexed matches with optional filtering:

```swift
let allMatches = try await kupo.client.getAllMatches(
    query: .init(
        resolveHashes: true,
        unspent: true,
        order: .mostRecentFirst
    ),
    headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
)

switch allMatches {
case .ok(let okResponse):
    let matches = try okResponse.body.applicationJsonCharsetUtf8
    print("Total matches: \(matches.count)")
    
    // Process matches...
    
default:
    print("Failed to get matches")
}
```

## Datum and Script Retrieval

### Get Datum by Hash

```swift
let datumHash = "some-datum-hash"

let datumResponse = try await kupo.client.getDatum(
    path: .init(datumHash: datumHash),
    headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
)

switch datumResponse {
case .ok(let okResponse):
    let datum = try okResponse.body.applicationJsonCharsetUtf8
    print("Datum: \(datum)")
    
case .notFound:
    print("Datum not found")
    
default:
    print("Failed to get datum")
}
```

### Get Script by Hash

```swift
let scriptHash = "some-script-hash"

let scriptResponse = try await kupo.client.getScript(
    path: .init(scriptHash: scriptHash),
    headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
)

switch scriptResponse {
case .ok(let okResponse):
    let script = try okResponse.body.applicationJsonCharsetUtf8
    print("Script: \(script)")
    
case .notFound:
    print("Script not found")
    
default:
    print("Failed to get script")
}
```

## Checkpoint Management

### Get All Checkpoints

```swift
let checkpointsResponse = try await kupo.client.getCheckpoints(
    headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
)

switch checkpointsResponse {
case .ok(let okResponse):
    let checkpoints = try okResponse.body.applicationJsonCharsetUtf8
    
    for checkpoint in checkpoints {
        print("Slot: \(checkpoint.slotNo)")
        print("Hash: \(checkpoint.headerHash)")
    }
    
default:
    print("Failed to get checkpoints")
}
```

### Get Specific Checkpoint

```swift
let slotNo = 12345678

let checkpointResponse = try await kupo.client.getCheckpoint(
    path: .init(slotNo: slotNo),
    headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
)

switch checkpointResponse {
case .ok(let okResponse):
    let checkpoint = try okResponse.body.applicationJsonCharsetUtf8
    print("Checkpoint at slot \(checkpoint.slotNo): \(checkpoint.headerHash)")
    
case .notFound:
    print("Checkpoint not found for slot \(slotNo)")
    
default:
    print("Failed to get checkpoint")
}
```

## Advanced Query Techniques

### Pagination and Ordering

```swift
// Get recent matches with pagination
let response = try await kupo.client.getAllMatches(
    query: .init(
        resolveHashes: false,  // Skip heavy data for pagination
        unspent: true,
        order: .mostRecentFirst
    ),
    headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
)

// Process first batch, then use ETag for subsequent requests
if case .ok(let okResponse) = response {
    let matches = try okResponse.body.applicationJsonCharsetUtf8
    
    // Get ETag from headers for caching/pagination
    if let headers = okResponse.headers {
        // Process ETag if available in response headers
    }
}
```

### Filtering by Creation Time

```swift
// Using semantic extensions for better readability
let pattern = Components.Parameters.Pattern(
    wildcard: nil,
    addressPattern: someAddressPattern,
    assetIdPattern: nil,
    outputReferencePattern: nil
)

let response = try await kupo.client.matchPattern(
    path: .init(pattern: pattern),
    query: .init(
        resolveHashes: true,
        unspent: true,
        spent: false,
        order: .oldestFirst  // Start from oldest
    ),
    headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
)
```

## Response Headers

Kupo provides useful metadata in response headers:

```swift
switch response {
case .ok(let okResponse):
    // Check for most recent checkpoint
    if let headers = okResponse.headers {
        // Look for X-Most-Recent-Checkpoint header
        // Look for ETag for caching
    }
    
    let matches = try okResponse.body.applicationJsonCharsetUtf8
    // Process matches...
    
default:
    print("Request failed")
}
```

## Error Handling Best Practices

### Handle Different Response Types

```swift
switch response {
case .ok(let okResponse):
    // Success - process data
    let data = try okResponse.body.applicationJsonCharsetUtf8
    
case .badRequest(let badRequestResponse):
    // Client error - check request parameters
    print("Bad request - check your parameters")
    
case .notFound:
    // Resource not found
    print("Resource not found")
    
case .internalServerError:
    // Server error - retry or check server logs
    print("Server error - check Kupo server status")
    
case .undocumented(statusCode: let code, _):
    // Unexpected response
    print("Unexpected response code: \(code)")
}
```

### Network Error Handling

```swift
do {
    let response = try await kupo.client.getHealth(/* ... */)
    // Process response
} catch let error as URLError {
    switch error.code {
    case .cannotConnectToHost:
        print("Cannot connect to Kupo server - is it running?")
    case .timedOut:
        print("Request timed out - server may be busy")
    case .networkConnectionLost:
        print("Network connection lost")
    default:
        print("Network error: \(error.localizedDescription)")
    }
} catch {
    print("Unexpected error: \(error)")
}
```

## Performance Tips

### 1. Use `resolveHashes` Wisely

Only set `resolveHashes: true` when you actually need the full datum/script content:

```swift
// For metadata/overview queries
let response = try await kupo.client.matchPattern(
    path: .init(pattern: pattern),
    query: .init(resolveHashes: false, unspent: true),  // Faster
    headers: headers
)

// For transaction building where you need full data
let detailedResponse = try await kupo.client.matchPattern(
    path: .init(pattern: pattern),
    query: .init(resolveHashes: true, unspent: true),   // Complete data
    headers: headers
)
```

### 2. Filter at the Server Level

Use query parameters to reduce network transfer:

```swift
// Good - server-side filtering
let response = try await kupo.client.matchPattern(
    path: .init(pattern: pattern),
    query: .init(unspent: true),  // Only unspent
    headers: headers
)

// Less efficient - client-side filtering
let allResponse = try await kupo.client.matchPattern(
    path: .init(pattern: pattern),
    query: .init(),  // Get all, then filter locally
    headers: headers
)
```

### 3. Use Appropriate Patterns

Be as specific as possible with patterns:

```swift
// Good - specific address
let specificPattern = Components.Parameters.Pattern(
    addressPattern: specificAddress
)

// Less efficient - wildcard (gets everything)
let wildcardPattern = Components.Parameters.Pattern(
    wildcard: ._ast_
)
```

## Next Steps

- **<doc:PatternExtensions>**: Learn about semantic extensions that make patterns easier to work with
- **<doc:AdvancedTopics>**: Explore configuration, caching, and architectural patterns