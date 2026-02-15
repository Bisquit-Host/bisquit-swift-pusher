import Vapor
@preconcurrency import APNSCore

func routes(_ app: Application) throws {
    try app.registerPushRoutes()
    try app.registerDebugRoutes()
    
    // MARK: - Live Activity
    // http://push-activity.bisquit.host/liveactivity/start
    app.post("liveactivity", "start") { req -> EventLoopFuture<String> in
        let input = try req.content.decode(LiveActivityInput.self)
        let configuredEnv = try APNSValidation.normalizedEnvironment(Environment.require("APNS_ENVIRONMENT"))
        let requestedEnv = try APNSValidation.normalizedEnvironment(input.environment)
        guard configuredEnv == requestedEnv else {
            throw Abort(.badRequest, reason: "APNS environment mismatch")
        }
        
        print("Input:", input)
        
        var headers: HTTPHeaders = [:]
        headers.add(name: "Origin", value: "https://mgr.bisquit.host")
        
        return WebSocket.connect(to: input.WSUrl, headers: headers, on: req.eventLoop) { ws in
            ws.send("{\"event\":\"auth\",\"args\":[\"\(input.WSToken)\"]}")
            
            ws.onText { _, message in
                print(message)
                
                if message.contains("console output") {
                    let data = Data(message.utf8)
                    
                    guard let wsMessage = try? JSONDecoder().decode(WebsocketMessage.self, from: data) else {
                        return
                    }
                    
                    var output = ""
                    
                    if wsMessage.event == "console output" {
                        output = wsMessage.args.first!
                    } else {
                        output = "Server Error"
                    }
                    
                    let alert = APNSLiveActivityNotification(
                        expiration: .immediately,
                        priority: .immediately,
                        appID: input.appID,
                        contentState: [
                            "latestMessage": output
                        ],
                        event: .update,
                        timestamp: Int(Date().timeIntervalSince1970)
                    )
                    
                    do {
                        try await req.apns.client.sendLiveActivityNotification(
                            alert,
                            deviceToken: input.liveActivityToken
                        )
                    } catch let e as APNSError {
                        print("APNS failed: status=\(e.responseStatus), reason=\(e.reason?.errorDescription ?? "nil")")
                    } catch {
                        print("Non-APNS error:", error)
                    }
                }
            }
            
            req.eventLoop.scheduleTask(in: .minutes(14)) {
                let alert = APNSLiveActivityNotification(
                    expiration: .immediately,
                    priority: .immediately,
                    appID: input.appID,
                    contentState: [
                        "latestMessage": "Restart Live Activity"
                    ],
                    event: .end,
                    timestamp: Int(Date().timeIntervalSince1970)
                )
                
                Task {
                    try await req.apns.client.sendLiveActivityNotification(
                        alert,
                        deviceToken: input.liveActivityToken
                    )
                    
                    try await ws.close()
                }
            }
        }
        .transform(to: "OK")
    }
}
