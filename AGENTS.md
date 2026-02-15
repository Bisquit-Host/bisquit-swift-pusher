# Repository Guidelines

## Project Structure

- `Package.swift`: SwiftPM manifest (executable product: `PyzhCloud`)
- `Sources/PyzhCloud/`: application code
  - `entrypoint.swift`: app startup (binds `0.0.0.0:911`)
  - `configure.swift`: middleware + APNS setup via environment variables
  - `routes.swift`, `pushRoutes.swift`, `debugRoutes.swift`: HTTP endpoints (e.g. `POST /push`, `GET /debug/ping`)
  - `Models/`: request/response `Content` models
- `Tests/PyzhCloudTests/`: test sources (currently present, but the `.testTarget` is commented out in `Package.swift`)
- `Resources/`: optional runtime resources (currently empty)

## Build, Test, and Development Commands
- `swift build`: builds the executable
- `swift run PyzhCloud serve`: runs the server locally (defaults to port `911`)
- `swift test`: runs unit tests (requires enabling the test target in `Package.swift`)
- `docker build -t pyzhcloud .`: builds the production image defined in `Dockerfile`
- `docker run -p 911:911 --env-file .env pyzhcloud`: runs the container (create `.env` locally; do not commit secrets)

## Coding Style & Naming Conventions
- Swift only; follow Swift API Design Guidelines
- Indentation: 4 spaces; keep lines readable and avoid deeply nested closures
- Naming: `UpperCamelCase` for types, `lowerCamelCase` for functions/vars; prefer descriptive names (e.g. `registerPushRoutes()`)

## Testing Guidelines
- Frameworks: `Testing` (Swift Testing) + `VaporTesting`
- Test location: `Tests/PyzhCloudTests/`; name tests after behavior (e.g. `@Test("Debug ping")`)

## Security & Configuration
- Env vars are documented in `README.md`
- Never commit private keys, tokens, or device tokens; use local `.env`/secrets tooling instead
