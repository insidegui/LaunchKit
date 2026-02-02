#import "launchctl.h"

#import "xpc_private.h"

/// Domain currently set via `launchctl_set_domain`.
///
/// - warning: Do not read directly! Use `launchctl_get_domain`.
static LaunchCTLDomain gCurrentDomain = LaunchCTLDomainSystem;

dispatch_queue_t domainLock(void)
{
    static dispatch_once_t onceToken;
    static dispatch_queue_t queue;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("DomainLock", dispatch_queue_attr_make_with_qos_class(NULL, QOS_CLASS_USER_INITIATED, 0));
    });
    return queue;
}

void launchctl_set_domain(LaunchCTLDomain domain)
{
    dispatch_sync(domainLock(), ^{
        gCurrentDomain = domain;
    });
}

LaunchCTLDomain launchctl_get_domain(void)
{
    __block LaunchCTLDomain domain;
    dispatch_sync(domainLock(), ^{
        domain = gCurrentDomain;
    });
    return domain;
}

void withLaunchCTLDomain(LaunchCTLDomain domain, void(^block)(void) NS_NOESCAPE)
{
    LaunchCTLDomain restoreDomain = launchctl_get_domain();

    if (domain != restoreDomain) launchctl_set_domain(domain);
    block();
    if (domain != restoreDomain) launchctl_set_domain(restoreDomain);
}

uint64_t _launchctl_resolve_domain_handle(void)
{
    LaunchCTLDomain domain = launchctl_get_domain();

    switch (domain) {
        case LaunchCTLDomainUser: {
            if (xpc_user_sessions_enabled()) {
                return xpc_user_sessions_get_foreground_uid(0);
            } else {
                return 0;
            }
        }
        case LaunchCTLDomainSystem:
            return 0;
    }
}
