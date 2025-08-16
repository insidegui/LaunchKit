import Foundation
@_exported import CLaunchKit

public struct LaunchControl {
}

// MARK: - Errors

public extension LaunchControl {
    struct Error: LocalizedError {
        public let code: Int
        public let message: String?

        init(code: Int, message: String? = nil) {
            self.code = code
            self.message = message
        }

        public var failureReason: String? {
            let prefix = "launchctl code \(code)"
            guard let message else { return prefix }
            return prefix + " - \(message)"
        }
    }
}

public extension LaunchControl.Error {
    static func wrap(_ closure: () throws -> Int32) throws(Self) {
        do {
            let code = try closure()
            guard code == 0 else {
                throw Self(code: Int(code))
            }
        } catch let error as Self {
            throw error
        } catch {
            throw Self(code: -2, message: "\(error)")
        }
    }

    static let notImplemented = Self(code: -1, message: "Not Implemented")
}

// MARK: - Commands

public extension LaunchControl {
    static func invoke(_ args: String...) throws {
        try LaunchControl.Error.wrap {
            /// `launchctl_invoke` requires the first argument to be the "name of the command".
            let argv: [String] = ["launchctl"] + args

            /// Build a C-compatible argv array, ensuring it's null-terminated.
            var cArgv = argv.map { strdup($0) }
            cArgv.append(nil)

            let code: Int32 = cArgv.withUnsafeMutableBufferPointer { buf in
                launchctl_invoke(Int32(argv.count), buf.baseAddress, environ, nil)
            }

            /// Clean up duplicated strings
            for p in cArgv where p != nil { free(p) }

            return code
        }
    }
}
