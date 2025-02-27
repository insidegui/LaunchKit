import Foundation
@_exported import CLaunchKit

public struct LaunchControl {
}

// MARK: - Errors

public extension LaunchControl {
    struct Error: LocalizedError {
        public let code: Int
        public let message: String

        init(code: Int, message: String) {
            self.code = code
            self.message = message
        }

        public var failureReason: String? { "launchctl code \(code) - \(message)" }
    }
}

public extension LaunchControl.Error {
    static func wrap<T>(_ closure: () throws -> T) throws(Self) -> T {
        do {
            return try closure()
        } catch let error as Self {
            throw error
        } catch {
            throw Self(code: 1, message: "\(error)")
        }
    }

    static let notImplemented = Self(code: -1, message: "Not Implemented")
}

// MARK: - Commands

public extension LaunchControl {
    // TBD
}
