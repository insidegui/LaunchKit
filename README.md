# LaunchKit: launchctl as a Swift package

Based on [launchctl](https://github.com/ProcursusTeam/launchctl).

This Swift package provides the `LaunchKit` library, a Swift library that can be used to perform the same commands supported by `launchctl`, but in a programmatic way without having to invoke `launchctl` itself.

Another target is a `launchctl` executable that can be built and run the same way as the built-in command on macOS.

Its main purpose is to build the `launchctl` command for iOS to use in a Security Research Device, since iOS doesn't have a built-in `launchctl` command.

Another feature is the ability to use `LaunchKit` in other SRD tools that have a need to interface with `launchd` on iOS.
