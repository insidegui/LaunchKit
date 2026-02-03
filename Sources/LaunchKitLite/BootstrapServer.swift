import Foundation

@_silgen_name("_xpc_domain_routine")
func _xpc_domain_routine(_ routine: UInt64, _ message: xpc_object_t, _ reply: UnsafeMutablePointer<xpc_object_t?>) -> Int32

@_silgen_name("xpc_user_sessions_enabled")
func xpc_user_sessions_enabled() -> Int64

@_silgen_name("xpc_user_sessions_get_foreground_uid")
func xpc_user_sessions_get_foreground_uid(_ flag: UInt64) -> Int64

/// Minimal pure-Swift launchd client implementation without additional dependencies.
public struct BootstrapServer: @unchecked Sendable {
    public struct ServerError: LocalizedError, Sendable {
        public private(set) var code: Int32
        public private(set) var message: String?

        init(code: Int32, message: String? = nil) {
            self.code = code
            self.message = message
        }

        public var failureReason: String? { message ?? "Code \(code)" }

        static let noReply = ServerError(code: -1, message: "No reply from launchd.")
        static let invalidReply = ServerError(code: -2, message: "Invalid reply from launchd.")
        static func missingValue(_ key: String) -> ServerError { ServerError(code: -3, message: "Invalid reply from launchd: missing value for \"\(key)\".") }
    }

    public struct Domain: Hashable, Sendable {
        public let handle: UInt64
        public let type: UInt64

        public static let system = Domain(handle: 0, type: 1)
        public static let user = Domain(handle: 501, type: 2)

        public static func custom(handle: UInt64, type: UInt64) -> Domain {
            Domain(handle: handle, type: type)
        }

        func resolved() -> Domain {
            guard self == .user else { return self }
            guard xpc_user_sessions_enabled() == 1 else { return self }

            let resolvedHandle = UInt64(truncatingIfNeeded: xpc_user_sessions_get_foreground_uid(0))

            return Domain(handle: resolvedHandle, type: type)
        }
    }

    public let domain: Domain

    public init(domain: Domain) {
        self.domain = domain.resolved()
    }

    // MARK: - Base

    private var templateMessage: xpc_object_t {
        let message = xpc_dictionary_create_empty()
        xpc_dictionary_set_uint64(message, "handle", domain.handle)
        xpc_dictionary_set_uint64(message, "type", domain.type)
        return message
    }

    private func ensureReply(_ ret: Int32, _ reply: xpc_object_t?) throws(ServerError) -> xpc_object_t {
        guard ret == 0 else {
            throw ServerError(code: ret)
        }

        guard let reply else {
            throw ServerError.noReply
        }

        guard xpc_get_type(reply) == XPC_TYPE_DICTIONARY else {
            throw ServerError.invalidReply
        }

        return reply
    }

    // MARK: - Sevice Management

    @discardableResult
    public func kickstart(service: String, kill: Bool = true, unthrottle: Bool = true) throws(ServerError) -> pid_t {
        let message = templateMessage
        xpc_dictionary_set_bool(message, "kill", kill)
        xpc_dictionary_set_bool(message, "unthrottle", unthrottle)
        xpc_dictionary_set_string(message, "name", service)

        var _reply: xpc_object_t?
        let ret = _xpc_domain_routine(702, message, &_reply) // XPC_ROUTINE_KICKSTART_SERVICE

        let reply = try ensureReply(ret, _reply)

        let pid = xpc_dictionary_get_int64(reply, "pid")

        return pid_t(truncatingIfNeeded: pid)
    }

    // MARK: - Environment

    public func getEnv(variable: String) throws(ServerError) -> String? {
        let message = templateMessage
        xpc_dictionary_set_string(message, "envvar", variable)

        var _reply: xpc_object_t?
        let ret = _xpc_domain_routine(820, message, &_reply) // XPC_ROUTINE_GETENV

        /// Return value of 3 occurs when the variable is not found, that's not an error for us.
        guard ret != 3 else {
            return nil
        }

        let reply = try ensureReply(ret, _reply)

        guard let value = xpc_dictionary_get_string(reply, "value") else {
            throw ServerError.missingValue("value")
        }

        return String(cString: value, encoding: .utf8)
    }

    public func setEnv(variable: String, value: String) throws(ServerError) {
        try setEnv(variables: [variable : value])
    }

    public func unsetEnv(variable: String) throws(ServerError) {
        try _setEnv(variables: [variable : .unset])
    }

    public func setEnv(variables: [String : String]) throws(ServerError) {
        try _setEnv(variables: variables.mapValues { VariableState.set($0) })
    }

    private enum VariableState {
        case set(String)
        case unset
    }

    private func _setEnv(variables: [String : VariableState]) throws(ServerError) {
        let envVars = xpc_dictionary_create_empty()
        for (key, state) in variables {
            switch state {
            case .set(let value):
                xpc_dictionary_set_string(envVars, key, value)
            case .unset:
                xpc_dictionary_set_value(envVars, key, xpc_null_create())
            }
        }

        let message = templateMessage
        xpc_dictionary_set_value(message, "envvars", envVars)

        var reply: xpc_object_t?
        let ret = _xpc_domain_routine(819, message, &reply) // XPC_ROUTINE_SETENV

        guard ret == 0 else {
            throw ServerError(code: ret)
        }
    }
}
