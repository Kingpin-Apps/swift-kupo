import Foundation
import HTTPTypes
import OpenAPIRuntime
import Testing

@testable import SwiftKupo

@Suite("Query flags and spent_at")
struct KupoFixesTests {
    @Test("Flags are sent bare, and false flags dropped")
    func rewritesFlags() {
        #expect(QueryFlagMiddleware.rewrite("/matches/x?resolve_hashes=true&unspent=true") == "/matches/x?resolve_hashes&unspent")
        #expect(QueryFlagMiddleware.rewrite("/matches/x?spent=false&order=oldest_first") == "/matches/x?order=oldest_first")
        #expect(QueryFlagMiddleware.rewrite("/matches/x?unspent=false") == "/matches/x")
        #expect(QueryFlagMiddleware.rewrite("/health") == "/health")
    }

    /// Records the path the transport saw.
    final class Recorder: ClientTransport, @unchecked Sendable {
        var paths: [String] = []
        func send(
            _ request: HTTPRequest, body: HTTPBody?, baseURL: URL, operationID: String
        ) async throws -> (HTTPResponse, HTTPBody?) {
            paths.append(request.path ?? "")
            return (HTTPResponse(status: .ok, headerFields: [.contentType: "application/json;charset=utf-8"]), .init("[]"))
        }
    }

    @Test("The middleware rewrites what getMatches sends")
    func middlewareOnTheWire() async throws {
        let recorder = Recorder()
        let client = Client(
            serverURL: URL(string: "http://kupo.test")!,
            transport: recorder,
            middlewares: [QueryFlagMiddleware()]
        )
        _ = try await client.getMatches(
            path: .init(pattern: .init(outputReferencePattern: "1@" + String(repeating: "ab", count: 32))),
            query: .init(resolveHashes: true, unspent: true)
        )
        #expect(recorder.paths.first?.hasSuffix("?resolve_hashes&unspent") == true)
    }

    @Test("A spent match from a current Kupo decodes, spending transaction and all")
    func decodesSpentAt() throws {
        let json = """
            {"transaction_index": 0, "transaction_id": "\(String(repeating: "ab", count: 32))", "output_index": 0,
             "address": "addr_test1vz09v9yfxguvlp0zsnrpa3tdtm7el8xufp3m5lsm7qxzclgmzkket",
             "value": {"coins": 42}, "datum_hash": null, "script_hash": null,
             "created_at": {"slot_no": 1, "header_hash": "\(String(repeating: "01", count: 32))"},
             "spent_at": {"slot_no": 2, "header_hash": "\(String(repeating: "02", count: 32))",
                          "transaction_id": "\(String(repeating: "cd", count: 32))", "input_index": 3, "redeemer": null}}
            """
        let match = try JSONDecoder().decode(Components.Schemas.Match.self, from: Data(json.utf8))
        #expect(match.spentAt?.transactionId == String(repeating: "cd", count: 32))
        #expect(match.spentAt?.inputIndex == 3)
        #expect(match.spentAt?.redeemer == nil)
    }
}
