import Testing
import Foundation
@testable import SwiftKupo
import OpenAPIRuntime
import HTTPTypes

@Suite("Kupo Tests")
struct KupoTests {
    let kupo = try! Kupo(
        client: Client(
            serverURL: URL(string: "http://localhost:1447")!,
            transport: MockTransport()
        )
    )
    
    @Test("Test getHealth")
    func getHealth() async throws {
        let health = try await kupo.client.getHealth(
            headers: .init(accept: [
                .init(contentType: .applicationJsonCharsetUtf8)
            ])
        )
        
        let healthResponse = try health.ok.body.applicationJsonCharsetUtf8
        
        #expect(healthResponse.connectionStatus == .connected)
        #expect(healthResponse.configuration.indexes == .installed)
        #expect(healthResponse.version == "1.0.0")
        #expect(healthResponse.mostRecentCheckpoint == nil)
        #expect(healthResponse.mostRecentNodeTip == nil)
    }
    
    @Test("Test getAllMatches")
    func getAllMatches() async throws {        
        let matches = try await kupo.client.getAllMatches(
            query: .init(resolveHashes: .some(true)),
            headers: .init(accept: [
                .init(contentType: .applicationJsonCharsetUtf8)
            ])
        )
        
        let matchesResponse = try matches.ok.body.applicationJsonCharsetUtf8
        
        #expect(matchesResponse.count == 2)
        
        // Test first match (unspent)
        let firstMatch = matchesResponse[0]
        #expect(firstMatch.transactionId == "d61cd910f55919612e031f557bbb16421682afa1f85e3f2c0069b25776900c2e")
        #expect(firstMatch.transactionIndex == 0)
        #expect(firstMatch.outputIndex == 1)
        #expect(firstMatch.value.coins == 8499831507)
        #expect(firstMatch.spentAt == nil) // Unspent
        #expect(firstMatch.createdAt.slotNo == 60896280)
        #expect(firstMatch.datumHash == nil)
        
        // Test second match (spent)
        let secondMatch = matchesResponse[1]
        #expect(secondMatch.transactionId == "955a900c2942c891cf1d5385ae9741dff913cfdc6961bd6b6787d3c4f0ee6c7e")
        #expect(secondMatch.transactionIndex == 3)
        #expect(secondMatch.outputIndex == 0)
        #expect(secondMatch.value.coins == 10000000000)
        #expect(secondMatch.spentAt != nil) // Spent
        #expect(secondMatch.spentAt?.slotNo == 60896280)
        #expect(secondMatch.createdAt.slotNo == 60698715)
    }
    
    @Test("Test matchPattern")
    func matchPattern() async throws {
        let patterns = try await kupo.client.matchPattern(
            path: .init(
                pattern: .init(
                    addressPattern: .init(
                        shelleyAddressPattern: .bech32("addr_test1qp4kux2v7xcg9urqssdffff5p0axz9e3hcc43zz7pcuyle0e20hkwsu2ndpd9dh9anm4jn76ljdz0evj22stzrw9egxqmza5y3")
                    )
                )
            ),
            headers: .init(accept: [
                .init(contentType: .applicationJsonCharsetUtf8)
            ])
        )
        
        let patternsResponse = try patterns.ok.body.applicationJsonCharsetUtf8
        
        #expect(patternsResponse.count == 1)
        
        let pattern = patternsResponse[0]
        
        // The OpenAPI-generated Pattern decoding tries to decode the same string into
        // all pattern types (Wildcard, AddressPattern, AssetIdPattern, OutputReferencePattern).
        // Since AssetIdPattern and OutputReferencePattern are just String typealias,
        // the address string gets decoded into all three, even though semantically
        // it should only match AddressPattern.
        
        #expect(pattern.value1 == nil) // No wildcard
        #expect(pattern.value2 != nil) // Has address pattern
        #expect(pattern.value3 != nil) // Also decoded as AssetIdPattern (String typealias)
        #expect(pattern.value4 != nil) // Also decoded as OutputReferencePattern (String typealias)
        
        // Test the address pattern using our semantic extensions
        #expect(pattern.addressPattern != nil)
        #expect(pattern.addressPattern?.shelleyAddressPattern != nil)
        #expect(pattern.addressPattern?.shelleyAddressPattern?.addressString == "addr_test1qp4kux2v7xcg9urqssdffff5p0axz9e3hcc43zz7pcuyle0e20hkwsu2ndpd9dh9anm4jn76ljdz0evj22stzrw9egxqmza5y3")
    }
}


