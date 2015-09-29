# PlusMeDemo
This is an example app of how to use the PlusMe Framework

### Install PlusMe Framework
1. Drag and drop the PlusMe.Framework into your project
2. Go to your target build phrases and drag and drop PlusMe.Framework into `Copy Files` build phrase

### Using Plusme Framework
#### Authenticator
To get an authenticator:
```swift
import PlusMe

let PlusMe.Authenticator(delegate: self)

```

#### Discovering new devices 
Begin discovering devices and implement the AuthenticatorDelegate
```swift
authenticator.startDiscoveringDevices()

extension DeviceListViewController: AuthenticatorDelegate {
  func authenticatorDidDiscoverDevice(device: BluetoothDevice) {
  }
}
```

#### Register
Once you've found a bluetooth device and wish to register:
```swift
  let deviceIdentifier: String = "DEVICE_IDENTIFIER"
  let appBundle: String = "APP_BUNDLE_ID"
  
  authenticator.register(appBundle, 
    deviceIdentifier: deviceIdentifier, 
    device: bluetoothDevice) { (success, device, error) in }
```

#### Login
When you are ready to login:
```swift
  authenticator.login(appBundle, 
    deviceIdentifier: deviceIdentifier) { (success, device, error) in }
```

#### Un-Register
Unregistering a device:
```swift
  authenticator.unregister(appBundle,
    deviceIdentifier: deviceIdentifier,
    device: bluetoothDevice) { (success, device, error) in }
```
