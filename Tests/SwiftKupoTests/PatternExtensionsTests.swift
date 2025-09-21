import Testing
@testable import SwiftKupo

@Test func testPatternExtensions() async throws {
    // Test Components.Parameters.Pattern extensions
    var parameterPattern = Components.Parameters.Pattern(
        value1: nil, value2: nil, value3: nil, value4: nil
    )
    
    // Test setting wildcard using semantic property
    parameterPattern.wildcard = ._ast_
    assert(parameterPattern.value1 == ._ast_, "Wildcard should be accessible via semantic property")
    assert(parameterPattern.wildcard == ._ast_, "Wildcard should be retrievable via semantic property")
    
    // Test setting address pattern using semantic property  
    let addressPattern = Components.Schemas.AddressPattern(value1: nil, value2: nil, value3: nil, value4: nil)
    parameterPattern.addressPattern = addressPattern
    assert(parameterPattern.value2 != nil, "AddressPattern should be accessible via semantic property")
    assert(parameterPattern.addressPattern != nil, "AddressPattern should be retrievable via semantic property")
    
    // Test setting asset ID pattern using semantic property
    parameterPattern.assetIdPattern = "1220099e5e430475c219518179efc7e6c8289db028904834025d5b086.*"
    assert(parameterPattern.value3 != nil, "AssetIdPattern should be accessible via semantic property")
    assert(parameterPattern.assetIdPattern != nil, "AssetIdPattern should be retrievable via semantic property")
    
    // Test setting output reference pattern using semantic property
    parameterPattern.outputReferencePattern = "42@35d8340cd6a5d31bf9d09706b92adedf9b1b632e682fdab9fc8865ee3de14e09"
    assert(parameterPattern.value4 != nil, "OutputReferencePattern should be accessible via semantic property")
    assert(parameterPattern.outputReferencePattern != nil, "OutputReferencePattern should be retrievable via semantic property")
    
    // Test convenience initializer with semantic names
    let semanticPattern = Components.Parameters.Pattern(
        wildcard: ._ast_,
        addressPattern: nil,
        assetIdPattern: "1220099e5e430475c219518179efc7e6c8289db028904834025d5b086.*",
        outputReferencePattern: nil
    )
    
    assert(semanticPattern.wildcard == ._ast_, "Convenience initializer should set wildcard correctly")
    assert(semanticPattern.assetIdPattern == "1220099e5e430475c219518179efc7e6c8289db028904834025d5b086.*", "Convenience initializer should set asset ID pattern correctly")
    assert(semanticPattern.addressPattern == nil, "Convenience initializer should leave nil values as nil")
}

@Test func testOperationPatternExtensions() async throws {
    // Test Operations.MatchPattern.Input.Path.Pattern extensions
    let matchPattern = Operations.MatchPattern.Input.Path.Pattern(
        wildcard: nil,
        addressPattern: Components.Schemas.AddressPattern(value1: nil, value2: nil, value3: nil, value4: nil),
        assetIdPattern: nil,
        outputReferencePattern: nil
    )
    
    assert(matchPattern.addressPattern != nil, "MatchPattern should support semantic addressPattern property")
    assert(matchPattern.wildcard == nil, "MatchPattern should support semantic wildcard property")
    assert(matchPattern.assetIdPattern == nil, "MatchPattern should support semantic assetIdPattern property")
    assert(matchPattern.outputReferencePattern == nil, "MatchPattern should support semantic outputReferencePattern property")
}

@Test func testAddressPatternExtensions() async throws {
    // Test Components.Schemas.AddressPattern extensions
    var addressPattern = Components.Schemas.AddressPattern(value1: nil, value2: nil, value3: nil, value4: nil)
    
    // Test credentials pattern (value1)
    addressPattern.credentialsPattern = "addr_vk1x7da0l25j04my8sej5ntrgdn38wmshxhplxdfjskn07ufavsgtkqn5hljl/*"
    assert(addressPattern.value1 == "addr_vk1x7da0l25j04my8sej5ntrgdn38wmshxhplxdfjskn07ufavsgtkqn5hljl/*", "Credentials pattern should be accessible")
    assert(addressPattern.credentialsPattern == "addr_vk1x7da0l25j04my8sej5ntrgdn38wmshxhplxdfjskn07ufavsgtkqn5hljl/*", "Credentials pattern should be retrievable")
    
    // Test Shelley address pattern (value2) - bech32
    let shelleyBech32 = Components.Schemas.AddressPattern.Value2Payload.bech32("addr_test1qp4kux2v7xcg9urqssdffff5p0axz9e3hcc43zz7pcuyle0e20hkwsu2ndpd9dh9anm4jn76ljdz0evj22stzrw9egxqmza5y3")
    addressPattern.shelleyAddressPattern = shelleyBech32
    assert(addressPattern.value2 != nil, "Shelley address pattern should be accessible")
    assert(addressPattern.shelleyAddressPattern != nil, "Shelley address pattern should be retrievable")
    assert(addressPattern.shelleyAddressPattern?.addressString == "addr_test1qp4kux2v7xcg9urqssdffff5p0axz9e3hcc43zz7pcuyle0e20hkwsu2ndpd9dh9anm4jn76ljdz0evj22stzrw9egxqmza5y3", "Address string should be extractable")
    
    // Test Shelley address pattern (value2) - base16
    let shelleyBase16 = Components.Schemas.AddressPattern.Value2Payload.base16("7a5e61936081db3b2117cbf59bd2123748f58ac96786567067f3314661")
    addressPattern.shelleyAddressPattern = shelleyBase16
    assert(addressPattern.shelleyAddressPattern?.addressString == "7a5e61936081db3b2117cbf59bd2123748f58ac96786567067f3314661", "Base16 address string should be extractable")
    
    // Test stake address pattern (value3) - bech32
    let stakeBech32 = Components.Schemas.AddressPattern.Value3Payload.bech32("stake1vyc29pvl2uyzqt8nwxrcxnf558ffm27u3d9calxn8tdudjgydsx9n")
    addressPattern.stakeAddressPattern = stakeBech32
    assert(addressPattern.value3 != nil, "Stake address pattern should be accessible")
    assert(addressPattern.stakeAddressPattern != nil, "Stake address pattern should be retrievable")
    assert(addressPattern.stakeAddressPattern?.addressString == "stake1vyc29pvl2uyzqt8nwxrcxnf558ffm27u3d9calxn8tdudjgydsx9n", "Stake address string should be extractable")
    
    // Test Bootstrap address pattern (value4) - base58
    let bootstrapBase58 = Components.Schemas.AddressPattern.Value4Payload.base58("DdzFFzCqrhsnWCKDVxHipmLW7acroB11zWxe1BGP1gCh7EqmgjVPe2qes6HrsQs")
    addressPattern.bootstrapAddressPattern = bootstrapBase58
    assert(addressPattern.value4 != nil, "Bootstrap address pattern should be accessible")
    assert(addressPattern.bootstrapAddressPattern != nil, "Bootstrap address pattern should be retrievable")
    assert(addressPattern.bootstrapAddressPattern?.addressString == "DdzFFzCqrhsnWCKDVxHipmLW7acroB11zWxe1BGP1gCh7EqmgjVPe2qes6HrsQs", "Bootstrap address string should be extractable")
    
    // Test convenience initializer with semantic names
    let semanticAddressPattern = Components.Schemas.AddressPattern(
        credentialsPattern: "*/*",
        shelleyAddressPattern: .bech32("addr1vy3qpx09uscywhpp0ekg9zwmq2yj5vp08husfq6qyh2mpps865j6t"),
        stakeAddressPattern: nil,
        bootstrapAddressPattern: nil
    )
    
    assert(semanticAddressPattern.credentialsPattern == "*/*", "Convenience initializer should set credentials pattern correctly")
    assert(semanticAddressPattern.shelleyAddressPattern?.addressString == "addr1vy3qpx09uscywhpp0ekg9zwmq2yj5vp08husfq6qyh2mpps865j6t", "Convenience initializer should set Shelley address pattern correctly")
    assert(semanticAddressPattern.stakeAddressPattern == nil, "Convenience initializer should leave nil values as nil")
}
