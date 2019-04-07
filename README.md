# Vapor Firestore Provider

Vapor-firestore is a lightweight provider which allows you to easily connect your Vapor project to a Firestore database and perform basic crud operations via the Firebase REST API.

### Prerequisites
You will need:
- Vapor 3.0+

### Installing

In your Package.swift file, add the line

```swift
.package(url: "https://github.com/PitchLabsAsh/vapor-firestore.git", from: "0.1.0")
```

Also add `VaporFirestore` as a dependency

```swift
dependencies: ["Vapor", ..., "VaporFirestore"]
```

## Setup

1. To use the VaporFirestore, you'll need a Firebase project, a service account to communicate with the Firebase service, and a configuration file with your service account's credentials.

* If you don't already have a Firebase project, add one in the Firebase console.
* Navigate to the Service Accounts tab in your project's settings page.
* Click the Generate New Private Key button at the bottom of the Firebase Admin SDK section of the Service Accounts tab.
* After you click the button, a JSON file containing your service account's credentials will be downloaded. You'll need this to initialize VaporFirestore in the next step.


2. Register `VaporFirestore` as a Provider and import `VaporFirestore`. This is usually done in `configure.swift`

```swift
import VaporFirstore

let firestoreConfig = FirestoreConfig(projectId: "projectId", email: "service-account-email", privateKey: "service-account-private-key")
services.register(firestoreConfig)
try! services.register(FirestoreProvider())
```

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Ferno, a similar project for connecting to Firebase realime database. [Ferno](https://github.com/vapor-community/ferno.git)
* Stripe Provider, a great template and example provider [stripe-provider](https://github.com/vapor-community/stripe-provider)
* Vapor Discord for answering all my questions


