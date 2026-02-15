import Vapor
@preconcurrency import APNSCore

extension Application {
    func registerPushRoutes() throws {
        // https://push-activity.bisquit.host/push
        self.post("push") { req async throws -> HTTPStatus in
            let body = try req.content.decode(PushNotificationTest.self)
            
            if Environment.get("TOTP_USE") == "ENABLED" {
                guard let totp = body.totp else {
                    throw Abort(.unauthorized, reason: "Missing TOTP")
                }
                
                try checkTOTP(totp)
            } else {
                try checkBearerToken(req)
            }
            
            guard !body.tokens.isEmpty else {
                throw Abort(.badRequest, reason: "No tokens provided")
            }

            let tokens = try body.tokens.map { try APNSValidation.normalizedDeviceToken($0) }
            let topic = try APNSValidation.resolveTopic(
                requestTopic: body.topic,
                configuredTopic: Environment.get("APNS_TOPIC")
            )
            
            let notification = APNSAlertNotification(
                alert: .init(
                    title: .raw(body.title),
                    subtitle: .raw(body.subtitle ?? ""),
                    body: .raw(body.body ?? "")
                ),
                expiration: .immediately,
                priority: .immediately,
                topic: topic,
                sound: .default
            )
            
            for token in tokens {
                do {
                    try await req.apns.client.sendAlertNotification(notification, deviceToken: token)
                } catch let error as APNSCore.APNSError {
                    req.logger.error("APNS failed token=\(token) status=\(error.responseStatus, default: "-") reason=\(error.reason, default: "-")")
                } catch {
                    req.logger.error("APNS failed token=\(token): \(error)")
                }
            }
            
            return .ok
        }
    }
}
