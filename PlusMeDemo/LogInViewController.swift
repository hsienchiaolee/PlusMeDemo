import UIKit
import PlusMe

class LogInViewController: UIViewController {
  let deviceIdentifier: String = UIDevice.currentDevice().identifierForVendor.UUIDString
  let appBundle: String = "io.plusmedemo"
  
  @IBOutlet weak var checkmarkImageView: UIImageView!
  @IBOutlet weak var statusLabel: UILabel!
  
  var authenticator: Authenticator!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    authenticator = Authenticator(delegate: nil)
  }
  
  override func viewDidAppear(animated: Bool) {
    self.statusLabel.text = "Logging in..."
    authenticator.login(appBundle, deviceIdentifier: deviceIdentifier) { (success, device, error) -> Void in
      if success {
        self.checkmarkImageView.hidden = false
        self.statusLabel.text = "Authenticated using \(device!.name)"
      }
    }
  }
}