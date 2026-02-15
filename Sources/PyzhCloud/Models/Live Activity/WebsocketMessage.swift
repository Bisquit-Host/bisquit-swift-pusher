struct WebsocketMessage: Codable {
    let event: String
    let args: [String]
}
