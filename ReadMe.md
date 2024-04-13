## This is the repository with test assignment for Bird company.

# BLocation

BLocation - is simple SDK, that allows consumer to retrieve current device location and report it to Birds dummy server.

## How to build an Example Application

This repo also contains Example App. To build it, you must have mac os with installed Xcode 15.1

- Clone repo
- Open BLocationExample folder
- Create ```.env``` file, inside BLocationExample folder. With an API key exported (see example below)
```bash
export API_KEY="<your_key>"
```
- Open .pbxproj file
- Wait until packages will be resolved
- Run project


## How to add BLocation to external application?

Add next line to your `Package.swift` file or add git link via Xcode dependencies manager
```
.package(url: "https://github.com/exoberfox/BLocation.git", from: "<version>")
```

## Setup

Create instance of BLocation and call setup method, providing apiKey.
```
import BLocation

let blocation = BLocation()
blocation.setup("<your_api_key>")
```

If setup method will be skipped, or will fail - other methods will ignore calls and throw error with description.

## Usage

Simply call any of public methods to start/stop retrieving current coordinates, or to request current location just once.
SDK will request permission if needed and also will check if your Application has necessary keys inside Info.plist

To start reporting current location, you'll have to implement `BLocationSessionDelegate` protocol with single method - `subscriptionCancelledCalledTimes`
This method is called, when subscribtion is canceled. Due to user request, or request error (failed to auth/refresh token/malformed data/etc.) 

```
import BLocation
...

Task {
    try? await blocation.reportCurrentLocation()
}

Task {
    try? await blocation.startUpdatingLocation(self) // Delegate goes here
}

blocation.stopUpdatingLocation()
```

## Used technologies

SDK is build with minimum deployment target of  iOS 15.0. This is the most optimal version, to support older devices and to use lates technologies stack.
There are **no** external dependencies used in sdk implementation.
But there are some extra packages added to Example application:
- SwiftFormat - to automatically keep your clean
- SecretsManager - to maintain secrets outside of source code and git

Also, sdk contains several tests for setup logic. Despite the fact that the SDK contains a large amount of other code, that requires testing coverage, the limited time to complete the task forces me to focus on a small example in the form of several unit tests.

External interface contains no frameworks/libraries, allowing client to use single import.

## Room for improvement

- SwiftLint, SwiftGen, XcodeGen, etc. 
A huge variaty of other usefull stuff may be added to Example project. Some of this packages are really neccesary to build maintanable ci, others are irreplaceable to build project in a huge team. But sience time is running short and only one persons maintains codebase - its fine without this dependencies

- More detailed modularisation
Its nice idea to have as atomic parts as possible inside your sdk-s and Applications. We can easily divide our smal monolith for Networking Layer, DTO-s Layer, Permissions Layer, DI... But for now we are fine.

- Analytics and health
- Api client improvements. Retry policy, error monitoring, open Api generation, mocks with sourcery, etc.
- Git flow/trunk based flow
- Different strategies for reporting/error handling. Batching. Cache and retries for failed reports. Detailed CLManager settings.
- More tests
