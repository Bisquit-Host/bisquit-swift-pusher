import Vapor

func checkBearerToken(_ req: Request) throws {
    guard let expected = Environment.get("PUSH_BEARER_TOKEN"), !expected.isEmpty else {
        throw Abort(.unauthorized, reason: "Bearer token not configured")
    }
    
    guard let provided = req.headers.bearerAuthorization?.token else {
        throw Abort(.unauthorized, reason: "Missing bearer token")
    }
    
    guard provided == expected else {
        throw Abort(.unauthorized, reason: "Invalid bearer token")
    }
}
