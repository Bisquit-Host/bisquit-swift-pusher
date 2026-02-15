import Vapor
import SwiftOTP

func checkTOTP(_ totp: Int32) throws {
    guard
        let key = Environment.get("TOTP_KEY"),
        let secret = base32DecodeToData(key),
        let gen = TOTP(secret: secret, digits: 6, timeInterval: 30, algorithm: .sha1)
    else {
        throw Abort(.unauthorized, reason: "Invalid TOTP_KEY")
    }
    
    let string = String(format: "%06d", totp)
    let now = Date()
    
    for i in -1...1 {
        if let code = gen.generate(time: now.addingTimeInterval(TimeInterval(i * 30))),
           code == string {
            return
        }
    }
    
    throw Abort(.unauthorized, reason: "Invalid TOTP")
}
