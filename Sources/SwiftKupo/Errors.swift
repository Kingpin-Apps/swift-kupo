import Foundation

enum KupoError: Error, CustomStringConvertible, Equatable {
    case invalidBasePath(String?)
    case valueError(String?)
    
    var description: String {
        switch self {
            case .invalidBasePath(let message):
                return message ?? "Invalid base path."
            case .valueError(let message):
                return message ?? "The value is invalid."
        }
    }
}
