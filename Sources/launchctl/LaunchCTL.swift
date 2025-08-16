import Foundation
import LaunchKit

@main
struct LaunchCTL {
    static func main() throws {
        if CommandLine.arguments.contains("--test") {
            try test()
        } else {
            let ret = launchctl_invoke(CommandLine.argc, CommandLine.unsafeArgv, nil, nil)
            exit(ret)
        }
    }

    static func test() throws {
        fputs("Testing...\n", stderr)

        try LaunchControl.invoke("list")
    }
}
