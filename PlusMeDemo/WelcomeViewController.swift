import UIKit
import PlusMe

class WelcomeViewController: UIViewController {
  var device: BluetoothDevice!
  @IBOutlet weak var deviceLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    deviceLabel.text = "Logged in using \(device.name)"
  }
}