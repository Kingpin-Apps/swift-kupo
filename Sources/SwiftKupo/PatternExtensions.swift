import Foundation

/// Semantic extensions for OpenAPI-generated Pattern types.
///
/// The Swift OpenAPI Generator creates Pattern types with generic property names (`value1`, `value2`, etc.)
/// for union types. These extensions provide meaningful property names and convenience methods,
/// making the Pattern API much more intuitive and self-documenting.
///
/// ## Overview
///
/// Instead of using generic generated properties:
///
/// ```swift
/// // Generated code (harder to understand)
/// let pattern = Components.Parameters.Pattern()
/// pattern.value1 = ._ast_           // What does value1 mean?
/// pattern.value2 = someAddress      // What does value2 represent?
/// ```
///
/// Use semantic extensions:
///
/// ```swift
/// // With semantic extensions (much clearer!)
/// let pattern = Components.Parameters.Pattern()
/// pattern.wildcard = ._ast_                         // Matches everything
/// pattern.addressPattern = someAddress              // Address matching
/// pattern.assetIdPattern = "policy.asset"           // Asset matching
/// pattern.outputReferencePattern = "tx#output"      // Output reference matching
/// ```
///
/// ## Topics
///
/// ### Pattern Types
/// - ``Components/Schemas/Pattern``
/// - ``Components/Parameters/Pattern``
///
/// ### Address Pattern Types  
/// - ``Components/Schemas/AddressPattern``
///
/// ### Address Format Support
/// - ``Components/Schemas/AddressPattern/Value2Payload``
/// - ``Components/Schemas/AddressPattern/Value3Payload``
/// - ``Components/Schemas/AddressPattern/Value4Payload``

// MARK: - Pattern Extensions for better property names

/// Extensions providing semantic property names for `Components.Schemas.Pattern`.
///
/// This extension enhances the generated OpenAPI Pattern type with meaningful property names,
/// replacing generic `value1`, `value2`, etc. with descriptive names that indicate what each
/// pattern type matches.
///
/// ## Usage Examples
///
/// ```swift
/// // Match all UTxOs (use with caution!)
/// let wildcardPattern = Components.Schemas.Pattern(wildcard: ._ast_)
///
/// // Match UTxOs at a specific address
/// let addressPattern = Components.Schemas.Pattern(
///     addressPattern: Components.Schemas.AddressPattern(
///         shelleyAddressPattern: .bech32("addr_test1qp4kux2v7xcg9...")
///     )
/// )
///
/// // Match UTxOs containing specific assets
/// let assetPattern = Components.Schemas.Pattern(
///     assetIdPattern: "policy_id.asset_name"
/// )
///
/// // Match a specific transaction output
/// let outputPattern = Components.Schemas.Pattern(
///     outputReferencePattern: "d61cd910f55919612e031f557bbb16421682afa1f85e3f2c0069b25776900c2e#1"
/// )
/// ```
extension Components.Schemas.Pattern {
    /// A wildcard pattern that matches everything (`*`).
    ///
    /// Use this pattern to match all UTxOs indexed by Kupo. Be cautious with wildcard patterns
    /// as they can return large amounts of data.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let pattern = Components.Schemas.Pattern()
    /// pattern.wildcard = ._ast_  // Matches everything
    /// ```
    ///
    /// - Warning: Wildcard patterns can return very large result sets. Use appropriate query filters
    ///   like `unspent: true` and `resolveHashes: false` to limit data transfer.
    public var wildcard: Components.Schemas.Wildcard? {
        get { value1 }
        set { value1 = newValue }
    }
    
    /// An address pattern for matching UTxOs at specific addresses or address patterns.
    ///
    /// Address patterns can match:
    /// - Specific Cardano addresses (Shelley, Byron, or stake addresses)
    /// - Address credential patterns using wildcards
    /// - Combinations of payment and stake credentials
    ///
    /// ## Example
    ///
    /// ```swift
    /// let pattern = Components.Schemas.Pattern()
    /// pattern.addressPattern = Components.Schemas.AddressPattern(
    ///     shelleyAddressPattern: .bech32("addr_test1qp4kux2v7xcg9...")
    /// )
    /// ```
    public var addressPattern: Components.Schemas.AddressPattern? {
        get { value2 }
        set { value2 = newValue }
    }
    
    /// An asset ID pattern for matching UTxOs containing specific policy IDs and asset names.
    ///
    /// Asset patterns support:
    /// - Specific assets: `"policy_id.asset_name"`
    /// - All assets from a policy: `"policy_id.*"`
    /// - Pattern matching with wildcards
    ///
    /// ## Examples
    ///
    /// ```swift
    /// // Match specific asset
    /// pattern.assetIdPattern = "1220099e5e430475c219518179efc7e6c8289db028904834025d5b086.MyToken"
    ///
    /// // Match all assets from a policy
    /// pattern.assetIdPattern = "1220099e5e430475c219518179efc7e6c8289db028904834025d5b086.*"
    /// ```
    public var assetIdPattern: Components.Schemas.AssetIdPattern? {
        get { value3 }
        set { value3 = newValue }
    }
    
    /// An output reference pattern for matching specific transaction outputs.
    ///
    /// Output reference patterns target specific UTxOs by their transaction ID and output index.
    /// The format is `"transaction_id#output_index"`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// pattern.outputReferencePattern = "d61cd910f55919612e031f557bbb16421682afa1f85e3f2c0069b25776900c2e#1"
    /// ```
    ///
    /// This is useful for:
    /// - Checking if a specific UTxO exists
    /// - Monitoring when a UTxO gets spent
    /// - Retrieving datum/script data for known UTxOs
    public var outputReferencePattern: Components.Schemas.OutputReferencePattern? {
        get { value4 }
        set { value4 = newValue }
    }
    
    /// Creates a new Pattern using semantic property names.
    ///
    /// This convenience initializer allows you to create patterns using descriptive parameter names
    /// instead of the generic `value1`, `value2`, etc. Only one pattern type should be specified.
    ///
    /// - Parameters:
    ///   - wildcard: A wildcard pattern to match everything
    ///   - addressPattern: An address pattern to match specific addresses
    ///   - assetIdPattern: An asset pattern to match specific assets
    ///   - outputReferencePattern: An output reference pattern to match specific UTxOs
    ///
    /// ## Examples
    ///
    /// ```swift
    /// // Address pattern
    /// let addressPattern = Components.Schemas.Pattern(
    ///     addressPattern: Components.Schemas.AddressPattern(
    ///         shelleyAddressPattern: .bech32(address)
    ///     )
    /// )
    ///
    /// // Asset pattern
    /// let assetPattern = Components.Schemas.Pattern(
    ///     assetIdPattern: "policy.asset"
    /// )
    /// ```
    ///
    /// - Note: Patterns are mutually exclusive. Only specify one pattern type per instance.
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
