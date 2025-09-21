import Foundation

// MARK: - Pattern Extensions for better property names

extension Components.Schemas.Pattern {
    /// A wildcard pattern that matches everything (`*`)
    public var wildcard: Components.Schemas.Wildcard? {
        get { value1 }
        set { value1 = newValue }
    }
    
    /// An address pattern for matching specific addresses or address patterns
    public var addressPattern: Components.Schemas.AddressPattern? {
        get { value2 }
        set { value2 = newValue }
    }
    
    /// An asset ID pattern for matching specific policy IDs and asset names  
    public var assetIdPattern: Components.Schemas.AssetIdPattern? {
        get { value3 }
        set { value3 = newValue }
    }
    
    /// An output reference pattern for matching specific transaction outputs
    public var outputReferencePattern: Components.Schemas.OutputReferencePattern? {
        get { value4 }
        set { value4 = newValue }
    }
    
    /// Convenience initializer using semantic property names
    public init(
        wildcard: Components.Schemas.Wildcard? = nil,
        addressPattern: Components.Schemas.AddressPattern? = nil,
        assetIdPattern: Components.Schemas.AssetIdPattern? = nil,
        outputReferencePattern: Components.Schemas.OutputReferencePattern? = nil
    ) {
        self.init(
            value1: wildcard,
            value2: addressPattern,
            value3: assetIdPattern,
            value4: outputReferencePattern
        )
    }
}

extension Components.Parameters.Pattern {
    /// A wildcard pattern that matches everything (`*`)
    public var wildcard: Components.Schemas.Wildcard? {
        get { value1 }
        set { value1 = newValue }
    }
    
    /// An address pattern for matching specific addresses or address patterns
    public var addressPattern: Components.Schemas.AddressPattern? {
        get { value2 }
        set { value2 = newValue }
    }
    
    /// An asset ID pattern for matching specific policy IDs and asset names
    public var assetIdPattern: Components.Schemas.AssetIdPattern? {
        get { value3 }
        set { value3 = newValue }
    }
    
    /// An output reference pattern for matching specific transaction outputs
    public var outputReferencePattern: Components.Schemas.OutputReferencePattern? {
        get { value4 }
        set { value4 = newValue }
    }
    
    /// Convenience initializer using semantic property names
    public init(
        wildcard: Components.Schemas.Wildcard? = nil,
        addressPattern: Components.Schemas.AddressPattern? = nil,
        assetIdPattern: Components.Schemas.AssetIdPattern? = nil,
        outputReferencePattern: Components.Schemas.OutputReferencePattern? = nil
    ) {
        self.init(
            value1: wildcard,
            value2: addressPattern,
            value3: assetIdPattern,
            value4: outputReferencePattern
        )
    }
}

// MARK: - Operation Pattern Extensions

extension Operations.GetMatches.Input.Path.Pattern {
    /// A wildcard pattern that matches everything (`*`)
    public var wildcard: Components.Schemas.Wildcard? {
        get { value1 }
        set { value1 = newValue }
    }
    
    /// An address pattern for matching specific addresses or address patterns
    public var addressPattern: Components.Schemas.AddressPattern? {
        get { value2 }
        set { value2 = newValue }
    }
    
    /// An asset ID pattern for matching specific policy IDs and asset names
    public var assetIdPattern: Components.Schemas.AssetIdPattern? {
        get { value3 }
        set { value3 = newValue }
    }
    
    /// An output reference pattern for matching specific transaction outputs
    public var outputReferencePattern: Components.Schemas.OutputReferencePattern? {
        get { value4 }
        set { value4 = newValue }
    }
    
    /// Convenience initializer using semantic property names
    public init(
        wildcard: Components.Schemas.Wildcard? = nil,
        addressPattern: Components.Schemas.AddressPattern? = nil,
        assetIdPattern: Components.Schemas.AssetIdPattern? = nil,
        outputReferencePattern: Components.Schemas.OutputReferencePattern? = nil
    ) {
        self.init(
            value1: wildcard,
            value2: addressPattern,
            value3: assetIdPattern,
            value4: outputReferencePattern
        )
    }
}

extension Operations.DeleteMatches.Input.Path.Pattern {
    /// A wildcard pattern that matches everything (`*`)
    public var wildcard: Components.Schemas.Wildcard? {
        get { value1 }
        set { value1 = newValue }
    }
    
    /// An address pattern for matching specific addresses or address patterns
    public var addressPattern: Components.Schemas.AddressPattern? {
        get { value2 }
        set { value2 = newValue }
    }
    
    /// An asset ID pattern for matching specific policy IDs and asset names
    public var assetIdPattern: Components.Schemas.AssetIdPattern? {
        get { value3 }
        set { value3 = newValue }
    }
    
    /// An output reference pattern for matching specific transaction outputs
    public var outputReferencePattern: Components.Schemas.OutputReferencePattern? {
        get { value4 }
        set { value4 = newValue }
    }
    
    /// Convenience initializer using semantic property names
    public init(
        wildcard: Components.Schemas.Wildcard? = nil,
        addressPattern: Components.Schemas.AddressPattern? = nil,
        assetIdPattern: Components.Schemas.AssetIdPattern? = nil,
        outputReferencePattern: Components.Schemas.OutputReferencePattern? = nil
    ) {
        self.init(
            value1: wildcard,
            value2: addressPattern,
            value3: assetIdPattern,
            value4: outputReferencePattern
        )
    }
}

extension Operations.MatchPattern.Input.Path.Pattern {
    /// A wildcard pattern that matches everything (`*`)
    public var wildcard: Components.Schemas.Wildcard? {
        get { value1 }
        set { value1 = newValue }
    }
    
    /// An address pattern for matching specific addresses or address patterns
    public var addressPattern: Components.Schemas.AddressPattern? {
        get { value2 }
        set { value2 = newValue }
    }
    
    /// An asset ID pattern for matching specific policy IDs and asset names
    public var assetIdPattern: Components.Schemas.AssetIdPattern? {
        get { value3 }
        set { value3 = newValue }
    }
    
    /// An output reference pattern for matching specific transaction outputs
    public var outputReferencePattern: Components.Schemas.OutputReferencePattern? {
        get { value4 }
        set { value4 = newValue }
    }
    
    /// Convenience initializer using semantic property names
    public init(
        wildcard: Components.Schemas.Wildcard? = nil,
        addressPattern: Components.Schemas.AddressPattern? = nil,
        assetIdPattern: Components.Schemas.AssetIdPattern? = nil,
        outputReferencePattern: Components.Schemas.OutputReferencePattern? = nil
    ) {
        self.init(
            value1: wildcard,
            value2: addressPattern,
            value3: assetIdPattern,
            value4: outputReferencePattern
        )
    }
}

extension Operations.PutPattern.Input.Path.Pattern {
    /// A wildcard pattern that matches everything (`*`)
    public var wildcard: Components.Schemas.Wildcard? {
        get { value1 }
        set { value1 = newValue }
    }
    
    /// An address pattern for matching specific addresses or address patterns
    public var addressPattern: Components.Schemas.AddressPattern? {
        get { value2 }
        set { value2 = newValue }
    }
    
    /// An asset ID pattern for matching specific policy IDs and asset names
    public var assetIdPattern: Components.Schemas.AssetIdPattern? {
        get { value3 }
        set { value3 = newValue }
    }
    
    /// An output reference pattern for matching specific transaction outputs
    public var outputReferencePattern: Components.Schemas.OutputReferencePattern? {
        get { value4 }
        set { value4 = newValue }
    }
    
    /// Convenience initializer using semantic property names
    public init(
        wildcard: Components.Schemas.Wildcard? = nil,
        addressPattern: Components.Schemas.AddressPattern? = nil,
        assetIdPattern: Components.Schemas.AssetIdPattern? = nil,
        outputReferencePattern: Components.Schemas.OutputReferencePattern? = nil
    ) {
        self.init(
            value1: wildcard,
            value2: addressPattern,
            value3: assetIdPattern,
            value4: outputReferencePattern
        )
    }
}

extension Operations.DeletePattern.Input.Path.Pattern {
    /// A wildcard pattern that matches everything (`*`)
    public var wildcard: Components.Schemas.Wildcard? {
        get { value1 }
        set { value1 = newValue }
    }
    
    /// An address pattern for matching specific addresses or address patterns
    public var addressPattern: Components.Schemas.AddressPattern? {
        get { value2 }
        set { value2 = newValue }
    }
    
    /// An asset ID pattern for matching specific policy IDs and asset names
    public var assetIdPattern: Components.Schemas.AssetIdPattern? {
        get { value3 }
        set { value3 = newValue }
    }
    
    /// An output reference pattern for matching specific transaction outputs
    public var outputReferencePattern: Components.Schemas.OutputReferencePattern? {
        get { value4 }
        set { value4 = newValue }
    }
    
    /// Convenience initializer using semantic property names
    public init(
        wildcard: Components.Schemas.Wildcard? = nil,
        addressPattern: Components.Schemas.AddressPattern? = nil,
        assetIdPattern: Components.Schemas.AssetIdPattern? = nil,
        outputReferencePattern: Components.Schemas.OutputReferencePattern? = nil
    ) {
        self.init(
            value1: wildcard,
            value2: addressPattern,
            value3: assetIdPattern,
            value4: outputReferencePattern
        )
    }
}

// MARK: - AddressPattern Extensions for better property names

extension Components.Schemas.AddressPattern {
    /// Address credentials pattern (payment/delegation credentials separated by '/')
    /// Examples: `addr_vk1.../`, `*/script1...`, `*/*`
    public var credentialsPattern: Swift.String? {
        get { value1 }
        set { value1 = newValue }
    }
    
    /// Shelley-era address pattern (bech32 or base16 format)
    /// Examples: `addr1vy3qpx09...` (bech32) or `7a5e61936081...` (base16)
    public var shelleyAddressPattern: Components.Schemas.AddressPattern.Value2Payload? {
        get { value2 }
        set { value2 = newValue }
    }
    
    /// Stake address pattern (bech32 or base16 format)
    /// Examples: `stake1vyc29pvl...` (bech32) or `7a5e61936081...` (base16)
    public var stakeAddressPattern: Components.Schemas.AddressPattern.Value3Payload? {
        get { value3 }
        set { value3 = newValue }
    }
    
    /// Bootstrap (Byron) address pattern (base58 or base16 format)
    /// Examples: `DdzFFzCqrhs...` (base58) or `73b81dc65c31...` (base16)
    public var bootstrapAddressPattern: Components.Schemas.AddressPattern.Value4Payload? {
        get { value4 }
        set { value4 = newValue }
    }
    
    /// Convenience initializer using semantic property names
    public init(
        credentialsPattern: Swift.String? = nil,
        shelleyAddressPattern: Components.Schemas.AddressPattern.Value2Payload? = nil,
        stakeAddressPattern: Components.Schemas.AddressPattern.Value3Payload? = nil,
        bootstrapAddressPattern: Components.Schemas.AddressPattern.Value4Payload? = nil
    ) {
        self.init(
            value1: credentialsPattern,
            value2: shelleyAddressPattern,
            value3: stakeAddressPattern,
            value4: bootstrapAddressPattern
        )
    }
}

// MARK: - AddressPattern Value Payload Extensions

extension Components.Schemas.AddressPattern.Value2Payload {
    /// Create a Shelley address pattern with bech32 format
    /// - Parameter address: A bech32-encoded address starting with `addr` or `addr_test`
    /// - Returns: A Value2Payload case for bech32 format
    public static func bech32(_ address: String) -> Self {
        .case1(address)
    }
    
    /// Create a Shelley address pattern with base16 format
    /// - Parameter address: A base16-encoded address
    /// - Returns: A Value2Payload case for base16 format
    public static func base16(_ address: String) -> Self {
        .case2(address)
    }
    
    /// Get the address string regardless of format
    public var addressString: String {
        switch self {
        case .case1(let address), .case2(let address):
            return address
        }
    }
}

extension Components.Schemas.AddressPattern.Value3Payload {
    /// Create a stake address pattern with bech32 format
    /// - Parameter address: A bech32-encoded stake address starting with `stake` or `stake_test`
    /// - Returns: A Value3Payload case for bech32 format
    public static func bech32(_ address: String) -> Self {
        .case1(address)
    }
    
    /// Create a stake address pattern with base16 format
    /// - Parameter address: A base16-encoded stake address
    /// - Returns: A Value3Payload case for base16 format
    public static func base16(_ address: String) -> Self {
        .case2(address)
    }
    
    /// Get the address string regardless of format
    public var addressString: String {
        switch self {
        case .case1(let address), .case2(let address):
            return address
        }
    }
}

extension Components.Schemas.AddressPattern.Value4Payload {
    /// Create a Bootstrap (Byron) address pattern with base58 format
    /// - Parameter address: A base58-encoded Byron address
    /// - Returns: A Value4Payload case for base58 format
    public static func base58(_ address: String) -> Self {
        .case1(address)
    }
    
    /// Create a Bootstrap (Byron) address pattern with base16 format
    /// - Parameter address: A base16-encoded Byron address
    /// - Returns: A Value4Payload case for base16 format
    public static func base16(_ address: String) -> Self {
        .case2(address)
    }
    
    /// Get the address string regardless of format
    public var addressString: String {
        switch self {
        case .case1(let address), .case2(let address):
            return address
        }
    }
}
