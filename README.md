# Bisquit Swift Pusher

💧 A project built with the Vapor web framework

## Environment variables
- APNS_PRIVATE_KEY
- APNS_PRIVATE_KEY_ID
- APNS_TOPIC (App's bundle id)
- APNS_ENVIRONMENT (production/development)
- TEAM_ID
- TOTP_USE ("ENABLED" to enforce TOTP)
- TOTP_KEY (required only when `TOTP_USE` is "ENABLED")
- PUSH_BEARER_TOKEN (required when `TOTP_USE` is not "ENABLED")

## Getting Started

To build the project using the Swift Package Manager, run the following command in the terminal from the root of the project:
```bash
swift build
```

To run the project and start the server, use the following command:
```bash
swift run
```

To execute tests, use the following command:
```bash
swift test
```

## Push API

Send a push notification directly to provided device tokens:

`POST /push`

`totp` is required only when `TOTP_USE` is set to "ENABLED"
When `TOTP_USE` is not "ENABLED", pass `Authorization: Bearer <token>` and set `PUSH_BEARER_TOKEN`

Example body:
```json
{
  "title": "Hello",
  "subtitle": "Optional",
  "body": "Optional",
  "tokens": ["<64-char APNS device token>"],
  "totp": 123456,
  "topic": "com.example.app"
}
```

### See more

- [Vapor Website](https://vapor.codes)
- [Vapor Documentation](https://docs.vapor.codes)
- [Vapor GitHub](https://github.com/vapor)
- [Vapor Community](https://github.com/vapor-community)
