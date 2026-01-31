import Foundation
import LaunchKit

@main
struct LaunchCTL {
    static func main() throws {
        if CommandLine.arguments.contains("--test") {
            try test()
        } else {
            let ret = launchctl_invoke(CommandLine.argc, CommandLine.unsafeArgv, nil, nil, nil)
            exit(ret)
        }
    }
}

#if DEBUG
// MARK: - Development Tests

extension LaunchCTL {
    static func test() throws {
        fputs("Testing...\n", stderr)

        testLaunchEnvironment()
    }

    static func testLaunchEnvironment() {
        fputs("Read default set\n", stderr)
        var env = LaunchEnvironment()
        print(env)

        fputs("\nWrite TEST_ENV\n", stderr)
        env["TEST_ENV"] = "hello"
        env.write()

        fputs("\nRe-read after setting TEST_ENV\n", stderr)
        env.read()
        print(env)

        fputs("\nUnset TEST_ENV\n", stderr)
        env["TEST_ENV"] = nil
        env.write()

        fputs("\nRe-read after unsetting TEST_ENV\n", stderr)
        env.read()
        print(env)
    }
}
#endif
