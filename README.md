# LaunchKit: launchctl as a Swift package

Based on [launchctl](https://github.com/ProcursusTeam/launchctl).

This Swift package provides the `LaunchKit` library, a Swift library that can be used to perform the same commands supported by `launchctl`, but in a programmatic way without having to invoke `launchctl` itself.

Another target is a `launchctl` executable that can be built and run the same way as the built-in command on macOS.

Its main purpose is to build the `launchctl` command for iOS to use in a Security Research Device, since iOS doesn't have a built-in `launchctl` command.

Another feature is the ability to use `LaunchKit` in other SRD tools that have a need to interface with `launchd` on iOS.

## Suggested entitlements (iOS / SRD)

Binaries that need to perform `launchctl` operations on iOS should include the same entitlements used by the sample `launchctl_srd` target:

```xml
<key>com.apple.private.xpc.launchd.userspace-reboot</key>
<true/>
<key>com.apple.private.xpc.persona-creator</key>
<true/>
<key>com.apple.private.xpc.service-attach</key>
<true/>
<key>com.apple.private.xpc.service-configure</key>
<true/>
```

These are defined in `iOS/launchctl_srd/launchctl_srd/launchctl_srd.entitlements`. Depending on the exact operations you perform, a subset may be sufficient.
