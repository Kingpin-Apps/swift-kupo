import Foundation
import HTTPTypes
import OpenAPIRuntime
import Testing

@testable import SwiftKupo

@Suite("Ledger numbers decode exactly")
struct ExactNumbersTests {
    static let txId = String(repeating: "ab", count: 32)
    static let policy = String(repeating: "1f", count: 28)

    static func matchJSON(coins: String, quantity: String, slot: String) -> String {
        """
        {"transaction_index": 0, "transaction_id": "\(txId)", "output_index": 0,
         "address": "addr_test1vz09v9yfxguvlp0zsnrpa3tdtm7el8xufp3m5lsm7qxzclgmzkket",
         "value": {"coins": \(coins), "assets": {"\(policy).4b75706f": \(quantity)}},
         "datum_hash": null, "script_hash": null,
         "created_at": {"slot_no": \(slot), "header_hash": "\(String(repeating: "01", count: 32))"},
         "spent_at": null}
        """
    }

    /// Output quantities across the whole UInt64 range, including values an
    /// Int32 (watchOS arm64_32 `Int`) or a Double would mangle.
    static let quantities: [UInt64] = [
        0,
        1,
        2_147_483_648,
        9_007_199_254_740_993,
        9_223_372_036_854_775_808,
        18_446_744_073_709_551_615,
    ]

    @Test("Value.coins and asset quantities are exact UInt64", arguments: quantities)
    func valueQuantities(_ quantity: UInt64) throws {
        let json = Self.matchJSON(coins: "\(quantity)", quantity: "\(quantity)", slot: "\(quantity)")
        let match = try JSONDecoder().decode(Components.Schemas.Match.self, from: Data(json.utf8))
        #expect(match.value.coins == quantity)
        #expect(match.value.assets?.additionalProperties["\(Self.policy).4b75706f"] == quantity)
        #expect(match.createdAt.slotNo == quantity)
    }

    @Test("A quantity above 2^64-1 is rejected, not wrapped or rounded")
    func overflowRejected() {
        let json = Self.matchJSON(coins: "18446744073709551616", quantity: "1", slot: "1")
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode(Components.Schemas.Match.self, from: Data(json.utf8))
        }
    }

    @Test("A negative output quantity is rejected")
    func negativeQuantityRejected() {
        let json = Self.matchJSON(coins: "42", quantity: "-1", slot: "1")
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode(Components.Schemas.Match.self, from: Data(json.utf8))
        }
    }

    @Test("Value round-trips 2^64-1 through the encoder")
    func valueRoundTrip() throws {
        let value = Components.Schemas.Value(
            coins: .max,
            assets: .init(additionalProperties: ["\(Self.policy)": .max])
        )
        let data = try JSONEncoder().encode(value)
        #expect(String(decoding: data, as: UTF8.self).contains("18446744073709551615"))
        #expect(try JSONDecoder().decode(Components.Schemas.Value.self, from: data) == value)
    }

    /// Metadata integers span the full CBOR range, signed: -2^64 ... 2^64-1.
    static let metadataIntegers: [String] = [
        "42",
        "-42",
        "9007199254740993",
        "-9223372036854775809",
        "18446744073709551615",
        "-18446744073709551616",
    ]

    @Test("Metadata integers decode as exact Decimals, negatives included", arguments: metadataIntegers)
    func metadatumIntegers(_ text: String) throws {
        let json = #"{"int": \#(text)}"#
        let metadatum = try JSONDecoder().decode(Components.Schemas.Metadatum.self, from: Data(json.utf8))
        guard case .MetadatumInt(let int) = metadatum else {
            Issue.record("expected an int metadatum, got \(metadatum)")
            return
        }
        #expect(int.int == Decimal(string: text))
        #expect(int.int.description == text)
    }

    @Test("A metadata schema with a huge negative int decodes exactly")
    func metadataSchema() throws {
        let json = """
            {"hash": "\(Self.txId)", "raw": "a1",
             "schema": {"674": {"map": [{"k": {"string": "n"}, "v": {"int": -18446744073709551616}}]},
                        "1": {"int": 18446744073709551615}}}
            """
        let metadata = try JSONDecoder().decode(Components.Schemas.Metadata.self, from: Data(json.utf8))
        guard case .MetadatumInt(let top) = metadata.schema.additionalProperties["1"] else {
            Issue.record("label 1 is not an int")
            return
        }
        #expect(top.int == Decimal(string: "18446744073709551615"))
        guard case .MetadatumMap(let map) = metadata.schema.additionalProperties["674"],
            case .MetadatumInt(let nested) = map.map.first?.v
        else {
            Issue.record("label 674 is not a map of int")
            return
        }
        #expect(nested.int == Decimal(string: "-18446744073709551616"))
        #expect(nested.int < 0)
    }

    /// Returns one canned match, so decoding goes through OpenAPIRuntime's own decoder.
    struct MatchTransport: ClientTransport {
        let body: String
        func send(
            _ request: HTTPRequest, body: HTTPBody?, baseURL: URL, operationID: String
        ) async throws -> (HTTPResponse, HTTPBody?) {
            (HTTPResponse(status: .ok, headerFields: [.contentType: "application/json;charset=utf-8"]), .init(self.body))
        }
    }

    @Test("The generated client decodes 2^64-1 lovelace and tokens exactly")
    func throughClient() async throws {
        let max = "18446744073709551615"
        let client = Client(
            serverURL: URL(string: "http://kupo.test")!,
            transport: MatchTransport(body: "[\(Self.matchJSON(coins: max, quantity: max, slot: "160000000"))]")
        )
        let matches = try await client.getAllMatches(query: .init()).ok.body.applicationJsonCharsetUtf8
        #expect(matches.first?.value.coins == UInt64.max)
        #expect(matches.first?.value.assets?.additionalProperties["\(Self.policy).4b75706f"] == UInt64.max)
        #expect(matches.first?.createdAt.slotNo == 160_000_000)
    }
}
