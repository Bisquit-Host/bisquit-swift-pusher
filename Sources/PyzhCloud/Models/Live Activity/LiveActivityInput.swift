import Vapor

struct LiveActivityInput: Content {
    let WSUrl: String
    let WSToken: String
    let liveActivityToken: String
    let environment: String
    let appID: String
}
