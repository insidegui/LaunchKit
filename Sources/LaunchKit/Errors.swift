import Foundation

package extension LaunchControl {
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

package extension LaunchControl.Error {
    static func wrap(_ closure: () throws -> (code: Int32, output: String)) throws(Self) -> String {
        do {
            let (code, output) = try closure()
            guard code == 0 else {
                throw Self(code: Int(code))
            }
            return output
        } catch let error as Self {
            throw error
        } catch {
            throw Self(code: -2, message: "\(error)")
        }
    }

    static let notImplemented = Self(code: -1, message: "Not Implemented")
}
