import Foundation

/// Errors that can occur when working with SwiftKupo.
///
/// `KupoError` represents various error conditions that may arise during SwiftKupo operations,
/// such as invalid configuration or API parameter issues.
///
/// ## Error Handling
///
/// Handle SwiftKupo errors alongside network and other system errors:
///
/// ```swift
/// do {
///     let kupo = try Kupo(basePath: "invalid-url")
/// } catch let error as KupoError {
///     switch error {
///     case .invalidBasePath(let message):
///         print("Invalid base path: \(message ?? "Unknown error")")
///     case .valueError(let message):
///         print("Value error: \(message ?? "Unknown error")")
///     }
/// } catch {
///     print("Other error: \(error)")
/// }
/// ```
///
/// ## Topics
///
/// ### Error Cases
/// - ``invalidBasePath(_:)``
/// - ``valueError(_:)``
public enum KupoError: Error, CustomStringConvertible, Equatable {
    /// An error indicating that the provided base path is invalid or cannot be converted to a URL.
    ///
    /// This error is thrown when:
    /// - The base path string cannot be converted to a valid `URL`
    /// - The URL scheme is missing or invalid
    /// - The URL format is malformed
    ///
    /// - Parameter message: An optional error message providing additional context about the invalid base path.
    ///
    /// ## Example
    ///
    /// ```swift
    /// do {
    ///     let kupo = try Kupo(basePath: "not-a-valid-url")
    /// } catch KupoError.invalidBasePath(let message) {
    ///     print("Invalid URL: \(message ?? "Unknown error")")
    /// }
    /// ```
    case invalidBasePath(String?)
    
    /// A general value error indicating that a parameter or configuration value is invalid.
    ///
    /// This error can occur when:
    /// - API parameters are out of expected range
    /// - Configuration values are invalid
    /// - Internal validation fails
    ///
    /// - Parameter message: An optional error message providing details about the invalid value.
    ///
    /// ## Example
    ///
    /// ```swift
    /// do {
    ///     // Some operation that validates input
    ///     try validateInput(someValue)
    /// } catch KupoError.valueError(let message) {
    ///     print("Value error: \(message ?? "Unknown error")")
    /// }
    /// ```
    case valueError(String?)
    
    /// A human-readable description of the error.
    ///
    /// This property provides a user-friendly description of the error,
    /// including any additional context provided when the error was created.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let error = KupoError.invalidBasePath("URL scheme missing")
    /// print(error.description) // "URL scheme missing"
    /// ```
    public var description: String {
        switch self {
        case .invalidBasePath(let message):
            return message ?? "Invalid base path."
        case .valueError(let message):
            return message ?? "The value is invalid."
        }
    }
}
