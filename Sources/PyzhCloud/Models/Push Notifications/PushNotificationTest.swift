import Vapor

struct PushNotificationTest: Content {
    let title: String
    let subtitle: String?
    let body: String?
    let tokens: [String]
    let totp: Int32?
    let topic: String?
}
