import UIKit
import PlusMe

class ViewController: UIViewController {
  var authenticator: Authenticator? = nil
  var deviceIdentifier: String = UIDevice.currentDevice().identifierForVendor.UUIDString
  let appBundle: String = "io.."
  var nearbyDevices: [BluetoothDevice] = []
  var loggedInDevice: BluetoothDevice!
  
  @IBOutlet weak var registerButton: UIButton!
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadingIndicator.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
    
    authenticator = Authenticator(delegate: self)
    if (NSUserDefaults.standardUserDefaults().boolForKey("hasRegisteredDevice")) {
      loginButton.enabled = true
    }
  }
  
  @IBAction func didTapRegisterButton(sender: AnyObject) {
    authenticator?.startDiscoveringDevices()
  }
  
  @IBAction func didTapLoginButton(sender: AnyObject) {
    loadingIndicator.startAnimating()
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
      self.authenticator?.login(self.appBundle, deviceIdentifier: self.deviceIdentifier)
    })
  }
  
  @IBAction func didTapResetButton(sender: AnyObject) {
    NSUserDefaults.standardUserDefaults().removeObjectForKey("hasRegisteredDevice")
  }
  
  func showAlert(title: String, message: String?) {
    UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "Okay").show()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showLoggedInView" {
      let welcomeViewController: WelcomeViewController = segue.destinationViewController as! WelcomeViewController
      welcomeViewController.device = loggedInDevice
    }
  }
}

extension ViewController: AuthenticatorDelegate {
  func authenticatorDidDiscoverDevice(device: BluetoothDevice) {
    if (!contains(nearbyDevices, device)) {
      nearbyDevices.append(device)
      tableView.reloadData()
    }
  }
  
  func didRegisterBluetoothDevice(device: BluetoothDevice) {
    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasRegisteredDevice")
    NSUserDefaults.standardUserDefaults().synchronize()
    showAlert("Register Success", message: device.name)
    loginButton.enabled = true
  }
  
  func didFailedToRegisterWithError(error: NSError?) {
    showAlert("Register Failed", message: error?.description)
  }
  
  func didLoginWithBluetoothDevice(device: BluetoothDevice) {
    loggedInDevice = device
    self.performSegueWithIdentifier("showLoggedInView", sender: self)
    loadingIndicator.stopAnimating()
  }
  
  func didFailedToLoginWithError(error: NSError?) {
    showAlert("Login Failed", message: error?.description)
  }
  
  func didUnregisterBluetoothDevice(device: BluetoothDevice) {
    showAlert("Unregister Success", message: device.name)
  }
  
  func didFailedToUnregisterWithError(error: NSError?) {
    showAlert("Unregister Failed", message: error?.description)
  }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return nearbyDevices.count;
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let kCellIdentifier = "cellIdentifier"
    let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
    let device = nearbyDevices[indexPath.row]
    cell.textLabel?.text = device.name
    cell.detailTextLabel?.text = device.identifier
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let device = nearbyDevices[indexPath.row]
    authenticator?.register(appBundle, deviceIdentifier: deviceIdentifier, device: device)
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
  }
}