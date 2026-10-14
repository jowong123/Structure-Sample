# Structure-Sample

## Why this exists

Rather than a single app repo, this is a snapshot of the base architecture, navigation flow, and conventions I reach for on real projects — so you can see how I structure things without needing a fully built-out feature set.

## Architecture overview

- **Pattern:** MVVM
- **Navigation:** Coordinator/Navigator pattern — a `BaseNavigator` implements a shared `Navigator` protocol, with screen-specific navigators subclassing it to override routing logic
- **Dependency Injection:** Constructor injection at the ViewModel layer — services/protocols are injected into each ViewModel's initializer, keeping Views/ViewControllers decoupled from concrete implementations and easy to unit test with mocks.
- **Networking layer:** protocol-based service layer, async-await
- **UI layer:** UIKit programmatic views with SnapKit
- **Mobile Security:** ATS Certificate Pinning, OIDC + PKCE, Biometrics, Keychain management.

```
[ProjectName]/
├── Extensions/                    # Extensions
├── Helpers/                       # Helpers
    └── Security
      └── KeychainHelper, AuthManager, PKCEHelper
│   └── Managers, ErrorHelpers
├── Navigation/                    # BaseNavigator, protocols, coordinators
├── Modules/                       # Modules
│   └── Authentication, Landings   # Example fully-built module
│     └── ViewControllers,Views,ViewModels
├── Networking/                    # API client, endpoints, models
└── Resources/                     # Assets, Storyboard, localizable strings, etc.
```

## What's implemented vs. scaffolded

| Module | Status |
|---|---|
| Login screen (UI + navigation) | ✅ Fully built |
| Base navigator / routing | ✅ Fully built |
| Networking layer | ✅  Structure Sample built |
| [Other module] | 🚧 Placeholder |

## Tech stack

- Swift, UIKit (programmatic, no storyboards)
- [SnapKit] for Auto Layout
- [SPM] for dependency management
- [R.swift] for type-safe resources
- [Alamofire] for networking

## Getting started
```
Resolve Swift Package dependencies (Xcode should do this automatically on first open), then build and run.

## Notes

This repo is meant to be read more than run — feel free to explore the `Navigation/` and `Modules/Login/` folders as the best examples of the pattern in practice.
```
