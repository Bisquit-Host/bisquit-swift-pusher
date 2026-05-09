# Bisquit Swift Pusher

Swift/Vapor based back-end for push notifications & Live Activity

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

**Build**
```bash
swift build
```

**Run**
```bash
swift run
```

**Execute tests**
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
