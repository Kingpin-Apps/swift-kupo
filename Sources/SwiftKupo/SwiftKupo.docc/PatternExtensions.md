# Pattern Extensions

Learn about SwiftKupo's semantic extensions that make Pattern types more developer-friendly.

## Overview

The OpenAPI-generated Pattern types use generic property names (`value1`, `value2`, etc.) for their union properties. SwiftKupo provides semantic extensions that add meaningful property names and convenience methods, making the API much more intuitive to use.

## Why Extensions Are Needed

The generated Pattern types look like this:

```swift
// Generated code (harder to use)
let pattern = Components.Parameters.Pattern()
pattern.value1 = ._ast_           // What does value1 mean?
pattern.value2 = someAddress      // What does value2 represent?
pattern.value3 = "asset.name"     // What does value3 do?
pattern.value4 = "tx#output"      // What does value4 match?
```

With our semantic extensions, the same code becomes:

```swift
// With semantic extensions (much clearer!)
let pattern = Components.Parameters.Pattern()
pattern.wildcard = ._ast_                         // Matches everything
pattern.addressPattern = someAddress              // Address matching
pattern.assetIdPattern = "asset.name"             // Asset matching  
pattern.outputReferencePattern = "tx#output"      // Output reference matching
```

## Pattern Type Extensions

All Pattern types in SwiftKupo get these semantic property extensions:

- `wildcard` - Matches everything using the `*` pattern
- `addressPattern` - Matches specific addresses or address patterns
- `assetIdPattern` - Matches assets by policy ID and asset name
- `outputReferencePattern` - Matches specific transaction outputs

### Supported Pattern Types

These extensions work with all generated Pattern types:

- `Components.Schemas.Pattern`
- `Components.Parameters.Pattern`  
- `Operations.MatchPattern.Input.Path.Pattern`
- `Operations.GetMatches.Input.Path.Pattern`
- And all other operation-specific Pattern types

### Basic Usage

```swift
import SwiftKupo

// Create pattern with semantic properties
var pattern = Components.Parameters.Pattern()

// Match everything (use with caution!)
pattern.wildcard = ._ast_

// Match specific address
pattern.addressPattern = Components.Schemas.AddressPattern(
    credentialsPattern: nil,
    shelleyAddressPattern: .bech32("addr_test1qp4kux2v7xcg9urqssdffff5p0axz9e3hcc43zz7pcuyle0e20hkwsu2ndpd9dh9anm4jn76ljdz0evj22stzrw9egxqmza5y3"),
    stakeAddressPattern: nil,
    bootstrapAddressPattern: nil
)

// Match assets with specific policy ID and any asset name
pattern.assetIdPattern = "1220099e5e430475c219518179efc7e6c8289db028904834025d5b086.*"

// Match specific transaction output
pattern.outputReferencePattern = "d61cd910f55919612e031f557bbb16421682afa1f85e3f2c0069b25776900c2e#1"
```

### Convenience Initializer

For even cleaner code, use the convenience initializer:

```swift
let pattern = Components.Parameters.Pattern(
    wildcard: nil,
    addressPattern: someAddressPattern,
    assetIdPattern: "policy.asset",
    outputReferencePattern: nil
)
```

## AddressPattern Extensions

AddressPattern types receive additional semantic extensions:

- `credentialsPattern` - For address credentials patterns like `addr_vk1.../` or `*/*`
- `shelleyAddressPattern` - For Shelley-era addresses (bech32 or base16)
- `stakeAddressPattern` - For stake addresses (bech32 or base16)
- `bootstrapAddressPattern` - For Bootstrap/Byron addresses (base58 or base16)

### Address Pattern Usage

```swift
// Create address pattern with semantic properties
let addressPattern = Components.Schemas.AddressPattern(
    credentialsPattern: "*/*",  // Match any credentials
    shelleyAddressPattern: .bech32("addr_test1qp4kux2v7xcg9urqssdffff5p0axz9e3hcc43zz7pcuyle0e20hkwsu2ndpd9dh9anm4jn76ljdz0evj22stzrw9egxqmza5y3"),
    stakeAddressPattern: nil,
    bootstrapAddressPattern: nil
)
```

### Address Format Convenience Methods

Each address payload type includes convenience constructors and utility methods:

#### Shelley Address Constructors

```swift
// Create Shelley address patterns
let bech32Address = Components.Schemas.AddressPattern.Value2Payload.bech32("addr_test1...")
let base16Address = Components.Schemas.AddressPattern.Value2Payload.base16("01ab23cd...")

// Extract address string regardless of format
if let shelleyPattern = addressPattern.shelleyAddressPattern {
    let addressString = shelleyPattern.addressString  // Gets the address string
    print("Address: \(addressString)")
}
```

#### Byron Address Constructors

```swift
// Create Byron/Bootstrap address patterns
let base58Address = Components.Schemas.AddressPattern.Value4Payload.base58("DdzFFzCqrht...")
let base16Byron = Components.Schemas.AddressPattern.Value4Payload.base16("82d8185842...")

// Extract address string
if let byronPattern = addressPattern.bootstrapAddressPattern {
    let addressString = byronPattern.addressString
    print("Byron Address: \(addressString)")
}
```

#### Stake Address Constructors  

```swift
// Create stake address patterns
let stakeBech32 = Components.Schemas.AddressPattern.Value3Payload.bech32("stake_test1...")
let stakeBase16 = Components.Schemas.AddressPattern.Value3Payload.base16("e01ab23cd...")

// Extract stake address string
if let stakePattern = addressPattern.stakeAddressPattern {
    let stakeString = stakePattern.addressString
    print("Stake Address: \(stakeString)")
}
```

## Practical Examples

### Example 1: Query by Specific Address

```swift
func queryAddressUTxOs(address: String) async throws {
    let kupo = try Kupo()
    
    // Create pattern using semantic extensions
    let pattern = Components.Parameters.Pattern(
        wildcard: nil,
        addressPattern: Components.Schemas.AddressPattern(
            credentialsPattern: nil,
            shelleyAddressPattern: .bech32(address),
            stakeAddressPattern: nil,
            bootstrapAddressPattern: nil
        ),
        assetIdPattern: nil,
        outputReferencePattern: nil
    )
    
    let response = try await kupo.client.matchPattern(
        path: .init(pattern: pattern),
        query: .init(unspent: true),
        headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
    )
    
    // Process results...
}
```

### Example 2: Query by Asset

```swift
func queryAssetUTxOs(policyId: String, assetName: String? = nil) async throws {
    let kupo = try Kupo()
    
    // Build asset pattern
    let assetPattern: String
    if let assetName = assetName {
        assetPattern = "\(policyId).\(assetName)"  // Specific asset
    } else {
        assetPattern = "\(policyId).*"  // Any asset from this policy
    }
    
    let pattern = Components.Parameters.Pattern(
        wildcard: nil,
        addressPattern: nil,
        assetIdPattern: assetPattern,
        outputReferencePattern: nil
    )
    
    let response = try await kupo.client.matchPattern(
        path: .init(pattern: pattern),
        query: .init(unspent: true, resolveHashes: true),
        headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
    )
    
    // Process asset UTxOs...
}
```

### Example 3: Query by Stake Key

```swift
func queryStakeKeyUTxOs(stakeKeyHash: String) async throws {
    let kupo = try Kupo()
    
    // Match all addresses with this stake key
    let pattern = Components.Parameters.Pattern(
        wildcard: nil,
        addressPattern: Components.Schemas.AddressPattern(
            credentialsPattern: "*/\(stakeKeyHash)",  // Any payment key with this stake key
            shelleyAddressPattern: nil,
            stakeAddressPattern: nil,
            bootstrapAddressPattern: nil
        ),
        assetIdPattern: nil,
        outputReferencePattern: nil
    )
    
    let response = try await kupo.client.matchPattern(
        path: .init(pattern: pattern),
        query: .init(unspent: true),
        headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
    )
    
    // Process results...
}
```

### Example 4: Query Specific Transaction Output

```swift
func queryTransactionOutput(txId: String, outputIndex: Int) async throws {
    let kupo = try Kupo()
    
    let pattern = Components.Parameters.Pattern(
        wildcard: nil,
        addressPattern: nil,
        assetIdPattern: nil,
        outputReferencePattern: "\(txId)#\(outputIndex)"
    )
    
    let response = try await kupo.client.matchPattern(
        path: .init(pattern: pattern),
        query: .init(resolveHashes: true),  // Get full data
        headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
    )
    
    switch response {
    case .ok(let okResponse):
        let matches = try okResponse.body.applicationJsonCharsetUtf8
        if let match = matches.first {
            print("Found UTxO: \(match.transactionId)#\(match.outputIndex)")
            print("Value: \(match.value.coins) lovelace")
        } else {
            print("UTxO not found or spent")
        }
    default:
        print("Query failed")
    }
}
```

## Advanced Pattern Techniques

### Combining Multiple Patterns

You can't set multiple pattern types on a single Pattern object (they're mutually exclusive), but you can make multiple queries:

```swift
func queryMultiplePatterns(address: String, assetId: String) async throws {
    let kupo = try Kupo()
    
    // Query address pattern
    let addressPattern = Components.Parameters.Pattern(
        addressPattern: Components.Schemas.AddressPattern(
            shelleyAddressPattern: .bech32(address)
        )
    )
    
    // Query asset pattern
    let assetPattern = Components.Parameters.Pattern(
        assetIdPattern: assetId
    )
    
    // Execute both queries concurrently
    async let addressResults = kupo.client.matchPattern(
        path: .init(pattern: addressPattern),
        query: .init(unspent: true),
        headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
    )
    
    async let assetResults = kupo.client.matchPattern(
        path: .init(pattern: assetPattern), 
        query: .init(unspent: true),
        headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
    )
    
    // Process both results
    let (addrResponse, assetResponse) = try await (addressResults, assetResults)
    
    // Combine and deduplicate results as needed...
}
```

### Wildcard Patterns with Caution

The wildcard pattern matches everything, which can return a lot of data:

```swift
// Use wildcard sparingly and with filters
let wildcardPattern = Components.Parameters.Pattern(wildcard: ._ast_)

let response = try await kupo.client.matchPattern(
    path: .init(pattern: wildcardPattern),
    query: .init(
        resolveHashes: false,    // Don't fetch heavy data
        unspent: true,           // Only unspent
        order: .mostRecentFirst  // Most recent first
    ),
    headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
)
```

## Pattern Debugging

When developing, you can inspect what pattern values are set:

```swift
let pattern = Components.Parameters.Pattern(
    addressPattern: someAddressPattern
)

// Debug pattern contents
print("Wildcard: \(String(describing: pattern.wildcard))")
print("Address Pattern: \(String(describing: pattern.addressPattern))")
print("Asset Pattern: \(String(describing: pattern.assetIdPattern))")
print("Output Ref Pattern: \(String(describing: pattern.outputReferencePattern))")
```

## Best Practices

### 1. Use Specific Patterns

Be as specific as possible to avoid unnecessary data transfer:

```swift
// Good - specific address
let specific = Components.Parameters.Pattern(
    addressPattern: specificAddressPattern
)

// Less optimal - wildcard
let wildcard = Components.Parameters.Pattern(wildcard: ._ast_)
```

### 2. Leverage Address String Extraction

Use the `addressString` property to work with addresses regardless of format:

```swift
if let shelleyPattern = addressPattern.shelleyAddressPattern {
    let address = shelleyPattern.addressString  // Works for both bech32 and base16
    // Use address string...
}
```

### 3. Combine with Query Parameters

Use semantic patterns with appropriate query filtering:

```swift
let pattern = Components.Parameters.Pattern(
    addressPattern: addressPattern
)

let response = try await kupo.client.matchPattern(
    path: .init(pattern: pattern),
    query: .init(
        resolveHashes: false,     // Fast metadata queries
        unspent: true,           // Only unspent UTxOs
        order: .mostRecentFirst  // Recent first
    ),
    headers: headers
)
```

## Next Steps

- **<doc:API-Usage>**: Learn how to use these patterns with all API endpoints
- **<doc:AdvancedTopics>**: Explore caching, error handling, and architectural patterns