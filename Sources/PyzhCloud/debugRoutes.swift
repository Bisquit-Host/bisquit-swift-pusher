import Vapor

extension Application {
    func registerDebugRoutes() throws {
        let debug = self.grouped("debug")
        
        // https://push-activity.bisquit.host/debug/ping
        debug.get("ping") { req -> String in
            "pong"
        }
    }
}
