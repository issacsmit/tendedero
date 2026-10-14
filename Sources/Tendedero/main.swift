import AppKit

MainActor.assumeIsolated {
    let app = NSApplication.shared
    let defaults: UserDefaults
    #if DEBUG
    if CommandLine.arguments.contains("--rope-demo") {
        let suite = "io.github.issacsmit.Linebreak.demo"
        defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
    } else { defaults = .standard }
    #else
    defaults = .standard
    #endif
    let delegate = AppDelegate(line: Line(defaults: defaults))
    app.delegate = delegate
    app.setActivationPolicy(.accessory)
    withExtendedLifetime(delegate) { app.run() }
}
