import Testing
@testable import SwiftKupo

@Test func getHealth() async throws {
    let kupo = try Kupo()
    
    let health = try await kupo.client.getHealth(
        headers: .init(accept: [
            .init(contentType: .applicationJsonCharsetUtf8)
        ])
    )
    print("Health: \(try health.ok.body.applicationJsonCharsetUtf8)")
}


@Test func getAllMatches() async throws {
    let kupo = try Kupo()
    
    let matches = try await kupo.client.getAllMatches(
        query: .init(resolveHashes: .some(true)),
        headers: .init(accept: [
            .init(contentType: .applicationJsonCharsetUtf8)
        ])
    )
    print("Matches: \(try matches.ok.body.applicationJsonCharsetUtf8)")
}

