import Foundation
import LaunchKit

@main
struct launchctl_srd {
    static func main() {
        launchctl_invoke(CommandLine.argc, CommandLine.unsafeArgv, environ, nil, nil)
    }
}
