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

## Usage

First setup a model for your document. The current implementation of Vapor-Firestore uses helper wrappers when defining documents for example:

```swift
struct ArticleFields: Codable {
    var title: Firestore.StringValue
    var subTitle: Firestore.StringValue
    var isAvailable: Firestore.BooleanValue
    var publishedAt: Firestore.TimestampValue
    var likeCount: Firestore.IntegerValue
}
```

To create a new document using this model:

```swift
let testObject = ArticleFields(title: Firestore.StringValue("A title"), subTitle: Firestore.StringValue("A subtitle"), isAvailable: Firestore.BooleanValue(true), publishedAt: Firestore.TimestampValue(Date()), likeCount: Firestore.IntegerValue(1))

let result = try client.firestore.createDocument(path: "test", fields: testObject, on: request)
```

To retrieve an array of all objects in this collection using this model:

```swift
let result: [Firestore.Document<ArticleFields>] = try client.firestore.listDocuments(path: "test", on: request)
```

To retrieve an individual object in this collection using this model:

```swift
let result: Firestore.Document<ArticleFields> = try client.firestore.getDocument(path: "test/<object-id>", on: request)
```

To update a document with all fields:

```swift
let result = try client.firestore.updateDocument(path: "test/<object-id>", fields: testObject, updateMask: nil, on: request)
```

To update specific fields of a document you must declare a new model with only those fields and pass a mask:

```swift

struct ArticleUpdateFields: Codable {
    var title: Firestore.StringValue
}

let updateObject = ArticleUpdateFields(title: Firestore.StringValue("An updated title again"))
let result = try client.firestore.updateDocument(path: "test/<object-id>", fields: updateObject, updateMask: ["title"], on: request)
```


## Testing

The Vapor-Firstore project contains some example simple unit tests. If you want to run these tests you will need to create a test Firestore database and add the service account credentials to `Application+Testing.swift`.
The testUpdateDoc and testGetDoc tests require a document to exist before they will pass. The easiest way to do this is to first run just the testCreateDoc test which will create a document of the test structure and output its object-id. Cut and paste this id into the update and get tests and then comment out testCreateDoc to avoid continually createing documents everytime you run the tests.


## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Ferno, a similar project for connecting to Firebase realime database. [Ferno](https://github.com/vapor-community/ferno.git)
* Stripe Provider, a great template and example provider [stripe-provider](https://github.com/vapor-community/stripe-provider)
* Vapor Discord for answering all my questions


