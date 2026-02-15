import Vapor

enum APNSValidation {
    private static let hexCharacterSet = CharacterSet(charactersIn: "0123456789abcdefABCDEF")

    static func normalizedEnvironment(_ raw: String) throws -> String {
        let env = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard env == "production" || env == "development" else {
            throw Abort(.internalServerError, reason: "APNS_ENVIRONMENT must be 'production' or 'development'")
        }
        return env
    }

    static func normalizedPrivateKey(_ raw: String) -> String {
        raw
            .replacingOccurrences(of: "\\n", with: "\n")
            .replacingOccurrences(of: "\r\n", with: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func resolveTopic(requestTopic: String?, configuredTopic: String?) throws -> String {
        let request = requestTopic?.trimmingCharacters(in: .whitespacesAndNewlines)
        let configured = configuredTopic?.trimmingCharacters(in: .whitespacesAndNewlines)

        if let configured, configured.isEmpty {
            throw Abort(.internalServerError, reason: "APNS topic not configured")
        }
        if let request, request.isEmpty {
            throw Abort(.badRequest, reason: "Invalid APNS topic")
        }
        if let configured, let request, configured != request {
            throw Abort(.badRequest, reason: "APNS topic mismatch")
        }
        if let request { return request }
        if let configured { return configured }

        throw Abort(.internalServerError, reason: "APNS topic not configured")
    }

    static func normalizedDeviceToken(_ raw: String) throws -> String {
        let token = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard token.unicodeScalars.allSatisfy({ hexCharacterSet.contains($0) }) else {
            throw Abort(.badRequest, reason: "Invalid device token characters")
        }
        return token
    }
}
