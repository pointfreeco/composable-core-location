# Composable Core Location

[![CI](https://github.com/pointfreeco/composable-core-location/workflows/CI/badge.svg)](https://github.com/pointfreeco/composable-core-location/actions?query=workflow%3ACI)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fpointfreeco%2Fcomposable-core-location%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/pointfreeco/composable-core-location)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fpointfreeco%2Fcomposable-core-location%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/pointfreeco/composable-core-location)

Composable Core Location is library that bridges [the Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) and [Core Location](https://developer.apple.com/documentation/corelocation).

* [Example](#example)
* [Basic usage](#basic-usage)
* [Installation](#installation)
* [Documentation](#documentation)
* [Help](#help)

## Example

Check out the [LocationManager](./Examples/LocationManager) demo to see ComposableCoreLocation in practice.

## Basic Usage

To use ComposableCoreLocation in your application, you can add an action to your domain that represents all of the actions the manager can emit via the `CLLocationManagerDelegate` methods:

```swift
import ComposableCoreLocation

enum AppAction {
  case locationManager(LocationManager.Action)

  // Your domain's other actions:
  ...
}
```

The `LocationManager.Action` enum holds a case for each delegate method of `CLLocationManagerDelegate`, such as `didUpdateLocations`, `didEnterRegion`, `didUpdateHeading`, and more.

Next we add a `LocationManager`, which is a wrapper around `CLLocationManager` that the library provides, to the application's environment of dependencies:

```swift
struct AppEnvironment {
  var locationManager: LocationManager

  // Your domain's other dependencies:
  ...
}
```

Then, we simultaneously subscribe to delegate actions and request authorization from our application's reducer by returning an effect from an action to kick things off. One good choice for such an action is the `onAppear` of your view.

```swift
let appReducer = Reducer<AppState, AppAction, AppEnvironment> {
  state, action, environment in

  switch action {
  case .onAppear:
    return .merge(
      environment.locationManager
        .delegate()
        .map(AppAction.locationManager),

      environment.locationManager
        .requestWhenInUseAuthorization()
        .fireAndForget()
    )

  ...
  }
}
```

With that initial setup we will now get all of `CLLocationManagerDelegate`'s delegate methods delivered to our reducer via actions. To handle a particular delegate action we can destructure it inside the `.locationManager` case we added to our `AppAction`. For example, once we get location authorization from the user we could request their current location:

```swift
case .locationManager(.didChangeAuthorization(.authorizedAlways)),
     .locationManager(.didChangeAuthorization(.authorizedWhenInUse)):

  return environment.locationManager
    .requestLocation()
    .fireAndForget()
```

If the user denies location access we can show an alert telling them that we need access to be able to do anything in the app:

```swift
case .locationManager(.didChangeAuthorization(.denied)),
     .locationManager(.didChangeAuthorization(.restricted)):

  state.alert = """
    Please give location access so that we can show you some cool stuff.
    """
  return .none
```

Otherwise, we'll be notified of the user's location by handling the `.didUpdateLocations` action:

```swift
case let .locationManager(.didUpdateLocations(locations)):
  // Do something cool with user's current location.
  ...
```

Once you have handled all the `CLLocationManagerDelegate` actions you care about, you can ignore the rest:

```swift
case .locationManager:
  return .none
```

And finally, when creating the `Store` to power your application you will supply the "live" implementation of the `LocationManager`, which is an instance that holds onto a `CLLocationManager` on the inside and interacts with it directly:

```swift
let store = Store(
  initialState: AppState(),
  reducer: appReducer,
  environment: AppEnvironment(
    locationManager: .live,
    // And your other dependencies...
  )
)
```

This is enough to implement a basic application that interacts with Core Location.

The true power of building your application and interfacing with Core Location in this way is the ability to _test_ how your application interacts with Core Location. It starts by creating a `TestStore` whose environment contains a `.failing` version of the `LocationManager`. Then, you can selectively override whichever endpoints your feature needs to supply deterministic functionality.

For example, to test the flow of asking for location authorization, being denied, and showing an alert, we need to override the `create` and `requestWhenInUseAuthorization` endpoints. The `create` endpoint needs to return an effect that emits the delegate actions, which we can control via a publish subject. And the `requestWhenInUseAuthorization` endpoint is a fire-and-forget effect, but we can make assertions that it was called how we expect.

```swift
let store = TestStore(
  initialState: AppState(),
  reducer: appReducer,
  environment: AppEnvironment(
    locationManager: .failing
  )
)

var didRequestInUseAuthorization = false
let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()

store.environment.locationManager.create = { locationManagerSubject.eraseToEffect() }
store.environment.locationManager.requestWhenInUseAuthorization = {
  .fireAndForget { didRequestInUseAuthorization = true }
}
```

Then we can write an assertion that simulates a sequence of user steps and location manager delegate actions, and we can assert against how state mutates and how effects are received. For example, we can have the user come to the screen, deny the location authorization request, and then assert that an effect was received which caused the alert to show:

```swift
store.send(.onAppear)

// Simulate the user denying location access
locationManagerSubject.send(.didChangeAuthorization(.denied))

// We receive the authorization change delegate action from the effect
store.receive(.locationManager(.didChangeAuthorization(.denied))) {
  $0.alert = """
    Please give location access so that we can show you some cool stuff.
    """

// Store assertions require all effects to be completed, so we complete
// the subject manually.
locationManagerSubject.send(completion: .finished)
```

And this is only the tip of the iceberg. We can further test what happens when we are granted authorization by the user and the request for their location returns a specific location that we control, and even what happens when the request for their location fails. It is very easy to write these tests, and we can test deep, subtle properties of our application.

## Installation

You can add ComposableCoreLocation to an Xcode project by adding it as a package dependency.

  1. From the **File** menu, select **Swift Packages › Add Package Dependency…**
  2. Enter "https://github.com/pointfreeco/composable-core-location" into the package repository URL text field

## Documentation

The latest documentation for the Composable Core Location APIs is available [here](https://pointfreeco.github.io/composable-core-location/).

## Help

If you want to discuss Composable Core Location and the Composable Architecture, or have a question about how to use them to solve a particular problem, ask around on [its Swift forum](https://forums.swift.org/c/related-projects/swift-composable-architecture).

## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.
