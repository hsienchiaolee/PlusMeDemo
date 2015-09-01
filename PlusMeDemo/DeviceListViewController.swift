import UIKit
import PlusMe

class DeviceListViewController: UIViewController {
  let deviceIdentifier: String = UIDevice.currentDevice().identifierForVendor.UUIDString
  let appBundle: String = "io.plusmedemo"
  
  @IBOutlet weak var tableView: UITableView!
  var authenticator: Authenticator? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    authenticator = Authenticator(delegate: self)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    authenticator?.startDiscoveringDevices()
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    authenticator?.stopDiscoveringDevices()
  }
}

extension DeviceListViewController: UITableViewDataSource, UITableViewDelegate {
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return section == 0 ? 1 : authenticator!.nearbyDevices.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    switch indexPath.section {
    case 0:
      let kCellIdentifier = "emailCell"
      let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
      return cell
    default:
      let kCellIdentifier = "deviceCell"
      let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
      
      let device = authenticator!.nearbyDevices[indexPath.row]
      cell.textLabel?.text = device.name
      cell.detailTextLabel?.text = device.identifier
      return cell
    }
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.section == 1 {
      let device = authenticator!.nearbyDevices[indexPath.row]
      let cell = tableView.cellForRowAtIndexPath(indexPath)
      let accessorySwitch: UISwitch = cell?.accessoryView as! UISwitch
      
      if accessorySwitch.on {
        authenticator?.register(appBundle, deviceIdentifier: deviceIdentifier, device: device) { (success, device, error) in
          if !success {
            accessorySwitch.setOn(!accessorySwitch.on, animated: true)
            self.showAlert("Register Failed", message: error?.description)
          }
          
        }
      } else {
        authenticator?.unregister(appBundle, deviceIdentifier: deviceIdentifier, device: device) { (success, device, error) in
          if !success {
            accessorySwitch.setOn(!accessorySwitch.on, animated: true)
            self.showAlert("Un-Register Failed", message: error?.description)
          }
        }
      }
      
      tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
  }
  
  // MARK: Private
  func showAlert(title: String, message: String?) {
    UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "Okay").show()
  }
}

extension DeviceListViewController: AuthenticatorDelegate {
  func authenticatorDidDiscoverDevice(device: BluetoothDevice) {
      tableView.reloadData()
  }
}