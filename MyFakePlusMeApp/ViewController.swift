import UIKit
import PlusMe

class ViewController: UIViewController {
    var plusMeAuthenticator: PlusMeAuthenticator? = nil
    var deviceIdentifier: String = UIDevice.currentDevice().identifierForVendor.UUIDString
    let appBundle: String = "io.PlusMe.PlusMe"
    var nearbyDevices: Array<String> = []
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        plusMeAuthenticator = PlusMeAuthenticator(delegate: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        if (NSUserDefaults.standardUserDefaults().boolForKey("hasRegisteredDevice")) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                self.plusMeAuthenticator?.login(self.appBundle, deviceIdentifier: self.deviceIdentifier)
            })
            
        }
    }
    
    @IBAction func didTapActionButton(sender: AnyObject) {
        plusMeAuthenticator?.startDiscoveringDevices()
    }
    
    @IBAction func didTapResetButton(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("hasRegisteredDevice")
    }
    
    func showAlert(title: String, message: String?) {
        UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "Okay").show()
    }
}

extension ViewController: PlusMeAuthenticatorDelegate {
    func authenticatorDidDiscoverDevice(deviceIdentifier: String) {
        nearbyDevices.append(deviceIdentifier)
        tableView.reloadData()
    }
    
    func didRegisterBluetoothDevice(identifier: String) {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasRegisteredDevice")
        NSUserDefaults.standardUserDefaults().synchronize()
        showAlert("Register Success", message: identifier)
    }
    
    func didFailedToRegisterWithError(error: NSError?) {
        showAlert("Register Failed", message: error?.description)
    }
    
    func didLoginWithBluetoothDevice(identifier: String) {
        showAlert("Login Success", message: identifier)
    }
    
    func didFailedToLoginWithError(error: NSError?) {
        showAlert("Login Failed", message: error?.description)
    }
    
    func didUnregisterBluetoothDevice(identifier: String) {
        showAlert("Unregister Success", message: identifier)
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
        cell.textLabel?.text = nearbyDevices[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let bluetoothDeviceIdentifier = nearbyDevices[indexPath.row]
        plusMeAuthenticator?.register(appBundle, deviceIdentifier: deviceIdentifier, bluetoothDeviceIdentifier: bluetoothDeviceIdentifier)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
}