import UIKit
import PlusMe

class DeviceListViewController: UIViewController {
  let deviceIdentifier: String = UIDevice.currentDevice().identifierForVendor.UUIDString
  let appBundle: String = "io.plusmedemo"
  
  @IBOutlet weak var tableView: UITableView!
  var authenticator: Authenticator!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    authenticator = Authenticator(delegate: self)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    authenticator.startDiscoveringDevices()
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    authenticator.stopDiscoveringDevices()
  }
  
  // MARK: Private
  func showAlert(title: String, message: String?) {
    UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "Okay").show()
  }
}

extension DeviceListViewController: UITableViewDataSource, UITableViewDelegate {
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return authenticator.knownDevices.count > 0 ? 3 : 2
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0: return 1
    case 1: return authenticator.knownDevices.count > 0 ? authenticator.knownDevices.count : authenticator.nearbyDevices.count
    case 2: return authenticator.nearbyDevices.count
    default: return 0
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      let kCellIdentifier = "emailCell"
      return tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
    } else {
      let kCellIdentifier = "deviceCell"
      let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
      
      var device: BluetoothDevice!
      if indexPath.section == 1 && authenticator.knownDevices.count > 0 {
        device = authenticator.knownDevices[indexPath.row]
        let accessorySwitch = cell.viewWithTag(100) as! UISwitch
        accessorySwitch.on = true
      } else {
        device = authenticator.nearbyDevices[indexPath.row]
      }
      
      cell.textLabel?.text = device.name
      cell.detailTextLabel?.text = device.identifier
      
      return cell
    }
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
    
    if indexPath.section > 0 {
      var device: BluetoothDevice!
      if indexPath.section == 1 && authenticator.knownDevices.count > 0 {
        device = authenticator.knownDevices[indexPath.row]
      } else {
        device = authenticator.nearbyDevices[indexPath.row]
      }
      
      let cell = tableView.cellForRowAtIndexPath(indexPath)
      let accessorySwitch = cell?.viewWithTag(100) as! UISwitch
      accessorySwitch.setOn(!accessorySwitch.on, animated: true)
      
      if accessorySwitch.on {
        authenticator.register(appBundle, deviceIdentifier: deviceIdentifier, device: device) { (success, device, error) in
          if !success {
            accessorySwitch.setOn(!accessorySwitch.on, animated: true)
            self.showAlert("Register Failed", message: error?.description)
          }
          
        }
      } else {
        authenticator.unregister(appBundle, deviceIdentifier: deviceIdentifier, device: device) { (success, device, error) in
          if !success {
            accessorySwitch.setOn(!accessorySwitch.on, animated: true)
            self.showAlert("Un-Register Failed", message: error?.description)
          }
        }
      }
    }
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 1: return authenticator.knownDevices.count > 0 ? "SUGGESTED DEVICES" : "OTHER DEVICES"
    case 2: return "OTHER DEVICES"
    default: return nil
    }
  }
  
  func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    if self.title == "Register" {
      let appDescription = "+ME lets you login without a password when this device is paired with another device. This app will automatically login whenever the paired devices are in  your possession with bluetooth turned on."
      let otherDeviceDescription = "Your device has not paired with these devices. use caution before connecting."
      
      switch section {
      case 0: return appDescription
      case 1: return authenticator.knownDevices.count > 0 ? nil : otherDeviceDescription
      case 2: return otherDeviceDescription
      default: return nil
      }
    }
    return nil
  }
}

extension DeviceListViewController: AuthenticatorDelegate {
  func authenticatorDidDiscoverDevice(device: BluetoothDevice) {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.tableView.reloadData()
    })
  }
}