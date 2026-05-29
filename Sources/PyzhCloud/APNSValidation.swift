import Vapor

enum APNSValidation {
    private static let hexCharacterSet = CharacterSet(charactersIn: "0123456789abcdefABCDEF")
    private static let privateKeyHeader = "-----BEGIN PRIVATE KEY-----"
    private static let privateKeyFooter = "-----END PRIVATE KEY-----"

    static func normalizedEnvironment(_ raw: String) throws -> String {
        let env = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard env == "production" || env == "development" else {
            throw Abort(.internalServerError, reason: "APNS_ENVIRONMENT must be 'production' or 'development'")
        }
        return env
    }

    static func normalizedPrivateKey(_ raw: String) throws -> String {
        let key = normalizedPEMString(raw)
        if isPEMPrivateKey(key) {
            return key
        }

        if let decodedKey = base64DecodedPEMString(key), isPEMPrivateKey(decodedKey) {
            return decodedKey
        }

        if FileManager.default.fileExists(atPath: key) {
            do {
                let fileKey = try String(contentsOf: URL(fileURLWithPath: key), encoding: .utf8)
                let normalizedFileKey = normalizedPEMString(fileKey)
                guard isPEMPrivateKey(normalizedFileKey) else {
                    throw Abort(.internalServerError, reason: "APNS_PRIVATE_KEY file does not contain a valid .p8 PEM private key")
                }
                return normalizedFileKey
                
            } catch let error as Abort {
                throw error
                
            } catch {
                throw Abort(.internalServerError, reason: "Unable to read APNS_PRIVATE_KEY file: \(error.localizedDescription)")
            }
        }

        throw Abort(
            .internalServerError,
            reason: "APNS_PRIVATE_KEY must be a .p8 PEM string, a base64-encoded .p8 PEM string, or a path to a .p8 file"
        )
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

    private static func normalizedPEMString(_ raw: String) -> String {
        raw
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .removingSinglePairOfWrappingQuotes()
            .replacing("\\n", with: "\n")
            .replacing("\r\n", with: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func isPEMPrivateKey(_ value: String) -> Bool {
        value.contains(privateKeyHeader) && value.contains(privateKeyFooter)
    }

    private static func base64DecodedPEMString(_ value: String) -> String? {
        let base64 = value.filter { !$0.isWhitespace }
        
        guard let data = Data(base64Encoded: base64), let decoded = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return normalizedPEMString(decoded)
    }
}

private extension String {
    func removingSinglePairOfWrappingQuotes() -> String {
        guard count >= 2, let first, let last else {
            return self
        }
        guard first == last, first == "\"" || first == "'" else {
            return self
        }
        return String(dropFirst().dropLast())
    }
}
