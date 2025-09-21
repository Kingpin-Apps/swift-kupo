import Testing
import OpenAPIRuntime
import Foundation
import HTTPTypes
@testable import SwiftKupo

struct MockTransport: ClientTransport {
    func send(_ request: HTTPTypes.HTTPRequest, body: OpenAPIRuntime.HTTPBody?, baseURL: URL, operationID: String) async throws -> (
        HTTPTypes.HTTPResponse,
        OpenAPIRuntime.HTTPBody?
    ) {
        switch operationID {
            case "getHealth":
                let payload = Components.Schemas.Health(
                    connectionStatus: .connected,
                    configuration: .init(
                        indexes: .installed
                    ),
                    version: "1.0.0"
                )
                let data = try JSONEncoder().encode(payload)
                return (
                    HTTPResponse(
                        status: .ok,
                        headerFields: [.contentType: "application/json;charset=utf-8"]
                    ),
                    .init(data)
                )
                
            case "getAllMatches":
                let matches = createMockMatches()
                let data = try JSONEncoder().encode(matches)
                return (
                    HTTPResponse(
                        status: .ok,
                        headerFields: [
                            .contentType: "application/json;charset=utf-8",
                            HTTPField.Name("X-Most-Recent-Checkpoint")!: "91835688",
                            HTTPField.Name("ETag")!: "474838f24b25dfb1b786ebb968235548252ee15a17f6e92a16d69866da2aa0a8"
                        ]
                    ),
                    .init(data)
                )
                
            case "matchPattern":
                // Return patterns that match the query
                let patterns = createMockPatterns()
                let data = try JSONEncoder().encode(patterns)
                return (
                    HTTPResponse(
                        status: .ok,
                        headerFields: [
                            .contentType: "application/json;charset=utf-8",
                            HTTPField.Name("X-Most-Recent-Checkpoint")!: "91835688",
                            HTTPField.Name("ETag")!: "474838f24b25dfb1b786ebb968235548252ee15a17f6e92a16d69866da2aa0a8"
                        ]
                    ),
                    .init(data)
                )
                
            default:
                return (
                    HTTPResponse(status: .notFound),
                    nil
                )
        }
    }
    
    // MARK: - Mock Data Helper Methods
    
    private func createMockPatterns() -> [Components.Schemas.Pattern] {
        return [
            Components.Schemas.Pattern(
                value1: nil,
                value2: Components.Schemas.AddressPattern(
                    value1: nil,
                    value2: Components.Schemas.AddressPattern.Value2Payload.case1("addr_test1qp4kux2v7xcg9urqssdffff5p0axz9e3hcc43zz7pcuyle0e20hkwsu2ndpd9dh9anm4jn76ljdz0evj22stzrw9egxqmza5y3"),
                    value3: nil,
                    value4: nil
                ),
                value3: nil,
                value4: nil
            )
        ]
    }
    
    private func createMockMatches() -> [Components.Schemas.Match] {
        return [
            createMockShelleyMatch(),
            createMockSpentMatch()
        ]
    }
    
    private func createMockShelleyMatch() -> Components.Schemas.Match {
        return Components.Schemas.Match(
            transactionIndex: 0,
            transactionId: "d61cd910f55919612e031f557bbb16421682afa1f85e3f2c0069b25776900c2e",
            outputIndex: 1,
            address: Components.Schemas.Address(
                value1: Components.Schemas.Address.Value1Payload.case1("addr_test1qp4kux2v7xcg9urqssdffff5p0axz9e3hcc43zz7pcuyle0e20hkwsu2ndpd9dh9anm4jn76ljdz0evj22stzrw9egxqmza5y3"),
                value2: Components.Schemas.Address.Value2Payload.case1("addr_test1qp4kux2v7xcg9urqssdffff5p0axz9e3hcc43zz7pcuyle0e20hkwsu2ndpd9dh9anm4jn76ljdz0evj22stzrw9egxqmza5y3")
            ),
            value: Components.Schemas.Value(
                coins: 8499831507,
                assets: Components.Schemas.Value.AssetsPayload(additionalProperties: [:])
            ),
            datumHash: nil,
            datum: nil,
            datumType: nil,
            scriptHash: nil,
            script: nil,
            createdAt: Components.Schemas.Match.CreatedAtPayload(
                slotNo: 60896280,
                headerHash: "bd931aa1c8d85da9defcdef765dcf184515ab3cbb9155fb9b48464f3523c5552"
            ),
            spentAt: nil
        )
    }
    
    private func createMockSpentMatch() -> Components.Schemas.Match {
        return Components.Schemas.Match(
            transactionIndex: 3,
            transactionId: "955a900c2942c891cf1d5385ae9741dff913cfdc6961bd6b6787d3c4f0ee6c7e",
            outputIndex: 0,
            address: Components.Schemas.Address(
                value1: Components.Schemas.Address.Value1Payload.case1("addr_test1qp4kux2v7xcg9urqssdffff5p0axz9e3hcc43zz7pcuyle0e20hkwsu2ndpd9dh9anm4jn76ljdz0evj22stzrw9egxqmza5y3"),
                value2: Components.Schemas.Address.Value2Payload.case1("addr_test1qp4kux2v7xcg9urqssdffff5p0axz9e3hcc43zz7pcuyle0e20hkwsu2ndpd9dh9anm4jn76ljdz0evj22stzrw9egxqmza5y3")
            ),
            value: Components.Schemas.Value(
                coins: 10000000000,
                assets: Components.Schemas.Value.AssetsPayload(additionalProperties: [:])
            ),
            datumHash: nil,
            datum: nil,
            datumType: nil,
            scriptHash: nil,
            script: nil,
            createdAt: Components.Schemas.Match.CreatedAtPayload(
                slotNo: 60698715,
                headerHash: "4db5110d8d8eb3b13a79ba0744eb3e13a613ea254a61debd2d410204c88f1629"
            ),
            spentAt: Components.Schemas.SpentAt(
                slotNo: 60896280,
                headerHash: "bd931aa1c8d85da9defcdef765dcf184515ab3cbb9155fb9b48464f3523c5552"
            )
        )
    }
}
