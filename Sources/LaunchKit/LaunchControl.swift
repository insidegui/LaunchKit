import Foundation
@_exported import CLaunchKit

/// Subsystem for LaunchKit unified logs.
public let kLaunchKitSubsystem = "codes.rambo.research.LaunchKit"

/// A Swift-friendly wrapper for `launchctl` operations.
///
/// You can use ``LaunchControl/invoke(_:)`` with the same arguments you would pass to `launchctl` in a shell.
/// Some commands can return output as a `String`, but most commands just write to standard error / output.
///
/// > Tip: This package may provide a more convenient wrapper depending on the operations you need,
/// such as ``LaunchEnvironment`` for operations related to environment variables.
public struct LaunchControl { }

// MARK: - Commands

public extension LaunchControl {
    @discardableResult
    static func invoke(_ args: String...) throws -> String {
        try invoke(arguments: args)
    }

    @discardableResult
    static func invoke(arguments: [String]) throws -> String {
        try LaunchControl.Error.wrap {
            /// `launchctl_invoke` requires the first argument to be the "name of the command".
            let argv: [String] = ["launchctl"] + arguments

            /// Build a C-compatible argv array, ensuring it's null-terminated.
            var cArgv = argv.map { strdup($0) }
            cArgv.append(nil)

            var out: UnsafeMutablePointer<CChar>? = nil
            let code: Int32 = cArgv.withUnsafeMutableBufferPointer { buf in
                launchctl_invoke(Int32(argv.count), buf.baseAddress, environ, nil, &out)
            }

            /// Clean up duplicated strings
            for p in cArgv where p != nil { free(p) }

            let output = out.flatMap { String(cString: $0) } ?? ""
            return (code, output)
        }
    }
}
