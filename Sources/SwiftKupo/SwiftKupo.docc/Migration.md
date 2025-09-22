# Migration Guide

Learn how to handle version updates and breaking changes in SwiftKupo.

## Overview

This guide helps you navigate version updates, breaking changes, and deprecated APIs in SwiftKupo. As SwiftKupo is built on top of the Kupo API and Swift OpenAPI Generator, updates may come from multiple sources.

## Version History

### Version 1.0.0 (Current)

Initial release with:
- Full Kupo API support
- Semantic Pattern extensions
- Swift 6.2+ compatibility
- Multi-platform support (iOS 14+, macOS 13+, watchOS 7+, tvOS 14+)

## Understanding Breaking Changes

SwiftKupo can experience breaking changes from several sources:

### 1. Kupo API Changes

When Kupo updates its API specification, SwiftKupo automatically regenerates client code. This can introduce:

- New endpoints or parameters
- Modified response schemas
- Deprecated endpoints
- Changed error codes

### 2. Swift OpenAPI Generator Updates

Updates to the Swift OpenAPI Generator can change:

- Generated code structure
- Type definitions
- Runtime requirements

### 3. SwiftKupo Library Changes

Direct changes to SwiftKupo may include:

- Updated semantic extensions
- New convenience methods
- Modified error handling
- Platform requirement changes

## Migration Strategies

### Preparation for Updates

Before updating SwiftKupo:

1. **Review Change Logs**
   ```bash
   # Check SwiftKupo releases
   git log --oneline v1.0.0..HEAD
   
   # Check Kupo API changes
   curl -s https://api.github.com/repos/CardanoSolutions/kupo/releases/latest
   ```

2. **Run Current Tests**
   ```bash
   swift test
   ```

3. **Create Backup Branch**
   ```bash
   git checkout -b backup-pre-update
   ```

### Safe Update Process

1. **Update Dependencies Incrementally**
   
   Update `Package.swift`:
   ```swift
   dependencies: [
       .package(url: "https://github.com/your-username/swift-kupo", from: "1.1.0")
   ]
   ```

2. **Check Compilation**
   ```bash
   swift build
   ```

3. **Run Tests**
   ```bash
   swift test
   ```

4. **Review Generated Code Changes**
   ```bash
   # Compare generated files
   diff -r .build/plugins/outputs/swift-kupo/SwiftKupo/destination/OpenAPIGenerator/GeneratedSources/ backup/
   ```

## Common Migration Scenarios

### Migrating from Generated Code Changes

When the OpenAPI specification changes, you may need to update your code:

#### Scenario 1: New Required Parameters

**Before (v1.0.0):**
```swift
let response = try await kupo.client.matchPattern(
    path: .init(pattern: pattern),
    query: .init(unspent: true),
    headers: headers
)
```

**After (hypothetical v1.1.0):**
```swift
let response = try await kupo.client.matchPattern(
    path: .init(pattern: pattern),
    query: .init(
        unspent: true,
        includeMetadata: true  // New required parameter
    ),
    headers: headers
)
```

**Migration:**
```swift
// Wrapper function for backward compatibility
extension Kupo {
    func matchPatternLegacy(
        pattern: Components.Parameters.Pattern,
        unspent: Bool = true,
        resolveHashes: Bool = false
    ) async throws -> Operations.MatchPattern.Output {
        return try await client.matchPattern(
            path: .init(pattern: pattern),
            query: .init(
                unspent: unspent,
                resolveHashes: resolveHashes,
                includeMetadata: true  // Default for new parameter
            ),
            headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
        )
    }
}
```

#### Scenario 2: Modified Response Schema

**Before:**
```swift
struct Match {
    let transactionId: String
    let outputIndex: Int
    let value: Value
    // ... other fields
}
```

**After:**
```swift
struct Match {
    let transactionId: String
    let outputIndex: Int
    let value: Value
    let metadata: TransactionMetadata?  // New optional field
    // ... other fields
}
```

**Migration:**
```swift
// Handle new optional field gracefully
func processMatch(_ match: Components.Schemas.Match) {
    print("UTxO: \(match.transactionId)#\(match.outputIndex)")
    print("Value: \(match.value.coins) lovelace")
    
    // Handle new field if available
    if let metadata = match.metadata {
        print("Metadata: \(metadata)")
    }
}
```

#### Scenario 3: Deprecated Endpoints

**Before:**
```swift
let response = try await kupo.client.getMatches(/* parameters */)
```

**After (endpoint deprecated):**
```swift
// Use new endpoint
let response = try await kupo.client.matchPattern(/* new parameters */)
```

**Migration with backward compatibility:**
```swift
extension Kupo {
    @available(*, deprecated, message: "Use matchPattern instead")
    func getMatches(/* old parameters */) async throws -> [Components.Schemas.Match] {
        // Convert old parameters to new format
        let pattern = convertToPattern(/* old parameters */)
        let response = try await client.matchPattern(
            path: .init(pattern: pattern),
            query: .init(/* converted query */),
            headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
        )
        
        guard case .ok(let okResponse) = response else {
            throw KupoError.valueError("Failed to get matches")
        }
        
        return try okResponse.body.applicationJsonCharsetUtf8
    }
}
```

### Migrating Pattern Extensions

If SwiftKupo updates semantic extensions:

#### Scenario 1: New Extension Properties

**Before:**
```swift
let pattern = Components.Parameters.Pattern()
pattern.addressPattern = addressPattern
pattern.assetIdPattern = assetId
```

**After (new property added):**
```swift
let pattern = Components.Parameters.Pattern()
pattern.addressPattern = addressPattern
pattern.assetIdPattern = assetId
pattern.scriptHashPattern = scriptHash  // New extension property
```

**Migration:**
```swift
// Existing code continues to work
// New code can use additional property
let pattern = Components.Parameters.Pattern(
    wildcard: nil,
    addressPattern: addressPattern,
    assetIdPattern: assetId,
    outputReferencePattern: nil,
    scriptHashPattern: scriptHash  // New optional parameter
)
```

#### Scenario 2: Modified Extension Behavior

If extension behavior changes, create compatibility wrappers:

```swift
extension Components.Parameters.Pattern {
    // Provide legacy behavior if needed
    @available(*, deprecated, message: "Use new initializer")
    static func legacyPattern(address: String) -> Components.Parameters.Pattern {
        // Old behavior
        return Components.Parameters.Pattern(
            addressPattern: Components.Schemas.AddressPattern(
                shelleyAddressPattern: .bech32(address)
            )
        )
    }
}
```

## Testing Migration

### Create Migration Tests

```swift
class MigrationTests: XCTestCase {
    func testBackwardCompatibility() async throws {
        // Test that old API patterns still work
        let kupo = try Kupo(basePath: "http://localhost:1442")
        
        // Old-style usage should still work
        let pattern = Components.Parameters.Pattern(
            addressPattern: Components.Schemas.AddressPattern(
                shelleyAddressPattern: .bech32("addr_test1...")
            )
        )
        
        let response = try await kupo.client.matchPattern(
            path: .init(pattern: pattern),
            query: .init(unspent: true),
            headers: .init(accept: [.init(contentType: .applicationJsonCharsetUtf8)])
        )
        
        // Should work without errors
        XCTAssertNotNil(response)
    }
    
    func testNewFeatures() async throws {
        // Test new features work as expected
        let kupo = try Kupo(basePath: "http://localhost:1442")
        
        // New features should be available
        // (Test specific new functionality)
    }
}
```

### Gradual Migration Testing

```swift
// Test both old and new approaches side by side
func compareOldAndNewApproach() async throws {
    let kupo = try Kupo(basePath: "http://localhost:1442")
    
    // Old approach
    let oldResult = try await legacyQuery(kupo: kupo)
    
    // New approach  
    let newResult = try await modernQuery(kupo: kupo)
    
    // Verify results are equivalent
    XCTAssertEqual(oldResult.count, newResult.count)
}
```

## Handling Breaking Changes

### Version Pinning Strategy

Pin to specific versions for stability:

```swift
// Package.swift
dependencies: [
    // Pin to exact version for stability
    .package(url: "https://github.com/your-username/swift-kupo", exact: "1.0.0"),
    
    // Or use version ranges with upper bounds
    .package(url: "https://github.com/your-username/swift-kupo", "1.0.0"..<"2.0.0")
]
```

### Feature Flags for Migration

Use feature flags to control migration:

```swift
enum FeatureFlags {
    static let useNewKupoAPI = ProcessInfo.processInfo.environment["USE_NEW_KUPO_API"] == "true"
}

func queryUTxOs(address: String) async throws -> [Components.Schemas.Match] {
    if FeatureFlags.useNewKupoAPI {
        return try await newQueryMethod(address: address)
    } else {
        return try await legacyQueryMethod(address: address)
    }
}
```

### Abstraction Layers

Create abstraction layers to isolate breaking changes:

```swift
protocol UTxOQueryService {
    func findUTxOs(for address: String) async throws -> [UTxO]
}

// V1 Implementation
class KupoV1QueryService: UTxOQueryService {
    func findUTxOs(for address: String) async throws -> [UTxO] {
        // Use v1.0 API
    }
}

// V2 Implementation
class KupoV2QueryService: UTxOQueryService {
    func findUTxOs(for address: String) async throws -> [UTxO] {
        // Use v2.0 API with new features
    }
}

// Factory to choose implementation
class UTxOQueryServiceFactory {
    static func create() -> UTxOQueryService {
        if FeatureFlags.useNewKupoAPI {
            return KupoV2QueryService()
        } else {
            return KupoV1QueryService()
        }
    }
}
```

## Rollback Strategies

### Quick Rollback

If migration fails, quickly rollback:

```bash
# Rollback Package.swift
git checkout HEAD~1 -- Package.swift

# Clean build directory
swift package clean

# Rebuild with previous version
swift build
```

### Gradual Rollback

Use feature flags to disable new features:

```swift
// Disable new features without code changes
enum RollbackFlags {
    static let disableNewFeatures = ProcessInfo.processInfo.environment["DISABLE_NEW_FEATURES"] == "true"
}
```

## Best Practices

### 1. Monitor Dependencies

Set up monitoring for dependency updates:

```bash
# Check for SwiftKupo updates
gh release list --repo your-username/swift-kupo

# Check for Kupo updates
gh release list --repo CardanoSolutions/kupo
```

### 2. Automated Testing

Add CI checks for updates:

```yaml
# .github/workflows/dependency-check.yml
name: Dependency Check
on:
  schedule:
    - cron: '0 9 * * 1'  # Weekly on Monday

jobs:
  check-updates:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Check for updates
        run: |
          swift package show-dependencies
          # Add logic to check for newer versions
```

### 3. Documentation Updates

Keep migration documentation updated:

- Document all breaking changes
- Provide example migration code
- Include performance impact notes
- Add troubleshooting guides

### 4. Communication

Communicate changes to your team:

- Use semantic versioning
- Write detailed release notes
- Provide migration timeframes
- Offer support channels

## Getting Help

### Resources for Migration Issues

1. **SwiftKupo Issues**: Report migration problems on GitHub
2. **Kupo Community**: Join the Cardano developer community
3. **Swift Forums**: Ask Swift OpenAPI Generator questions

### Example Migration Request

When asking for help, provide:

```markdown
## Migration Issue

**From Version**: 1.0.0
**To Version**: 1.1.0
**Platform**: iOS 16.0
**Swift Version**: 6.2

**Error Message**:
```
Type 'Components.Schemas.Match' has no member 'metadata'
```

**Current Code**:
```swift
let match = matches.first
print(match.metadata) // Error here
```

**Expected Behavior**: 
Access new metadata field without breaking existing code.
```

## Next Steps

- **<doc:Resources>**: Explore external resources and community tools
- **<doc:AdvancedTopics>**: Learn about architectural patterns that make migration easier