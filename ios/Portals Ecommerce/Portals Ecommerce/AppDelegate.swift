import UIKit
import IonicPortals
import CapacitorCamera
import CapawesomeCapacitorLiveUpdate

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Fetch the latest web bundle for each portal from Capawesome Cloud.
        Task {
            await syncProviderPortals()
        }

        return true
    }

    private func syncProviderPortals() async {
        for portal in [Portal.checkout, .help, .featured] {
            do {
                _ = try await portal.syncProvider()
                print("Capawesome provider sync succeeded for portal '\(portal.name)'.")
            } catch {
                print("Capawesome provider sync failed for portal '\(portal.name)': \(error.localizedDescription)")
            }
        }
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
    private static let webAppId = "0ca581ce-f6cc-4e2c-a5f8-47a8169371c4"
    private static let featuredAppId = "791104da-928d-43ac-8c06-5c01462e460e"
    private static let activeChannel = "default"

    /// Constructs a Capawesome live update manager for a portal. Each portal gets a stable,
    /// unique `managerKey` so it persists its own active bundle.
    private static func providerManager(for target: String) -> LiveUpdateIonicManager? {
        let config: [String: Any]
        switch target {
        case "webapp":
            config = [
                "managerKey": "portal-webapp",
                "appId": webAppId,
                "channel": activeChannel
            ]
        case "help":
            config = [
                "managerKey": "portal-help",
                "appId": webAppId,
                "channel": activeChannel
            ]
        case "featured":
            config = [
                "managerKey": "portal-featured",
                "appId": featuredAppId,
                "channel": activeChannel
            ]
        default:
            return nil
        }

        return try? LiveUpdateIonicManager(configuration: config)
    }

    static let featured = Self(
        name: "featured",
        startDir: "portals/featured",
        plugins: [.type(LiveUpdatePlugin.self)],
        liveUpdateSource: providerManager(for: "featured").map { .provider(manager: $0) }
    )

    private static let commonPlugins: [Plugin] = [
        .type(LiveUpdatePlugin.self),
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
        liveUpdateSource: providerManager(for: "webapp").map { .provider(manager: $0) }
    )

    static let help = Self(
        name: "help",
        startDir: "portals/shopwebapp",
        initialContext: ["startingRoute": "/help"],
        plugins: commonPlugins,
        liveUpdateSource: providerManager(for: "help").map { .provider(manager: $0) }
    )

    static let user = Self(
        name: "user",
        startDir: "portals/shopwebapp",
        initialContext: ["startingRoute": "/user"],
        plugins: commonPlugins,
        liveUpdateSource: providerManager(for: "webapp").map { .provider(manager: $0) }
    )
    .adding(CameraPlugin.self)
}
