import Vapor

// APNS
import APNS
import VaporAPNS
import APNSCore

extension Environment {
    static func require(_ key: String) throws -> String {
        if let value = get(key) {
            return value
        }
        
        throw Abort(.internalServerError, reason: "Environment variable \(key) not configured")
    }
}

public func configure(_ app: Application) async throws {
    if app.environment == .testing {
        try routes(app)
        return
    }
    
    // Env vars
    let environment =  try APNSValidation.normalizedEnvironment(Environment.require("APNS_ENVIRONMENT"))
    let isProdEnv =    environment == "production"
    let privateKey =   APNSValidation.normalizedPrivateKey(try Environment.require("APNS_PRIVATE_KEY"))
    let privateKeyID = try Environment.require("APNS_PRIVATE_KEY_ID")
    let teamID =       try Environment.require("TEAM_ID")
    
    // APNS
    let apnsProductionConfig = APNSClientConfiguration(
        authenticationMethod: .jwt(
            privateKey:     try .loadFrom(string: privateKey),
            keyIdentifier:  privateKeyID,
            teamIdentifier: teamID
        ),
        environment: isProdEnv ? .production : .development
    )
    
    await app.apns.containers.use(
        apnsProductionConfig,
        eventLoopGroupProvider: .shared(app.eventLoopGroup),
        responseDecoder:        JSONDecoder(),
        requestEncoder:         JSONEncoder(),
        as:                     isProdEnv ? .production : .development
    )
    
    // Middleware
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // Register routes
    try routes(app)
}
