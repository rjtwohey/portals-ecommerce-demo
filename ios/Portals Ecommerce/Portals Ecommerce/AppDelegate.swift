import UIKit
import IonicPortals
import IonicLiveUpdates
import CapacitorCamera

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Register Portals
        // PortalsRegistrationManager.shared.register(key: "")

        try? LiveUpdateManager.shared.add(.help)
        try? LiveUpdateManager.shared.add(.webapp)
        try? LiveUpdateManager.shared.add(.featured)

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension Portal {
    static let featured = Self(
        name: "featured",
        startDir: "portals/featured",
        liveUpdateConfig: .featured
    )

    private static let commonPlugins: [Plugin] = [
        .type(ShopAPIPlugin.self),
        .instance(
            WebVitalsPlugin { portalName, duration in
                print("Portal \(portalName) - First Contentful Paint: \(duration)ms")
            }
        )
    ]

    static let checkout = Self(
        name: "checkout",
        startDir: "portals/shopwebapp",
        initialContext: ["startingRoute": "/checkout"],
        plugins: commonPlugins,
        liveUpdateConfig: .webapp
    )
    
    static let help = Self(
        name: "help",
        startDir: "portals/shopwebapp",
        initialContext: ["startingRoute": "/help"],
        plugins: commonPlugins,
        liveUpdateConfig: .help
    )
    
    static let user = Self(
        name: "user",
        startDir: "portals/shopwebapp",
        initialContext: ["startingRoute": "/user"],
        plugins: commonPlugins,
        liveUpdateConfig: .webapp
    )
    .adding(CameraPlugin.self)
}

extension LiveUpdate {
    private static let activeChannel = "production"

    static let webapp = Self(
        appId: "ccabf2bf",
        channel: activeChannel,
        syncOnAdd: true
    )

    static let help = Self(
        appId: "ccabf2bf",
        channel: activeChannel,
        syncOnAdd: true
    )

    static let featured = Self(
        appId: "535e2752",
        channel: activeChannel,
        syncOnAdd: true
    )
}

