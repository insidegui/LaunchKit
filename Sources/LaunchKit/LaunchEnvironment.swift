import Foundation
import OSLog

/// Helper for reading and writing environment variables configured via `launchctl setenv`.
public struct LaunchEnvironment: CustomStringConvertible {
    private let logger = Logger(subsystem: kLaunchKitSubsystem, category: String(describing: LaunchEnvironment.self))

    public static let defaultKeys: Set<String> = [
        "DYLD_INSERT_LIBRARIES"
    ]

    private enum Value: CustomStringConvertible {
        case set(String)
        case unset

        var description: String {
            switch self {
            case .set(let value): "<set>(\"\(value)\")"
            case .unset: "<unset>"
            }
        }

        var value: String? {
            switch self {
            case .set(let value): value
            case .unset: nil
            }
        }
    }

    private var keys: Set<String>
    private var dictionary: [String: Value]
    
    /// Creates an environment by reading from `launchd`.
    /// - Parameter keys: The environment keys that should be tracked by this environment.
    public init(_ keys: Set<String> = LaunchEnvironment.defaultKeys) {
        self.keys = keys
        self.dictionary = [:]

        dictionary.reserveCapacity(Self.defaultKeys.count)

        for key in keys {
            do {
                let value = try LaunchControl.invoke("getenv", key)

                dictionary[key] = .set(value)
            } catch {
                logger.error("Error initializing environment variable \(key, privacy: .public) from launchd state: \(error, privacy: .public)")

                dictionary[key] = .unset
            }
        }
    }

    /// Re-reads all environment variables tracked by this environment.
    public mutating func read() {
        self = LaunchEnvironment(keys)
    }

    /// Writes all environment variables tracked by this environment.
    public func write() {
        for (key, state) in dictionary {
            do {
                switch state {
                case .set(let value):
                    try LaunchControl.invoke("setenv", key, value)
                case .unset:
                    try LaunchControl.invoke("unsetenv", key)
                }
            } catch {
                logger.error("Error writing environment variable \(key, privacy: .public) with state \(state): \(error, privacy: .public)")
            }
        }
    }

    /// Reads or writes an environment variable via a subscript.
    ///
    /// The environment will only contain keys that were specified when it was first created.
    /// Setting a new key that was not specified in the environment's key set will automatically
    /// insert that key into the set, so subsequent calls to ``read()`` will also read it.
    ///
    /// - note: Changes are not committed until ``write()`` is called on the environment.
    public subscript(_ key: String) -> String? {
        get {
            if case .set(let value) = dictionary[key] {
                value
            } else {
                nil
            }
        }
        set {
            /// Make sure our set of keys contains the key being set.
            keys.insert(key)

            if let newValue {
                dictionary[key] = .set(newValue)
            } else {
                dictionary[key] = .unset
            }
        }
    }
}

public extension LaunchEnvironment {
    var description: String {
        dictionary
            .map { "\($0.key)=\($0.value.value, default: "")" }
            .joined(separator: "\n")
    }
}
