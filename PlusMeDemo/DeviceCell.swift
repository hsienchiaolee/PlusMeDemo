import UIKit
import PureLayout

class DeviceCell: UITableViewCell {
  var connectedSwitch: UISwitch!
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
    
    connectedSwitch = UISwitch()
    self.contentView.addSubview(connectedSwitch)
    connectedSwitch.autoAlignAxisToSuperviewAxis(.Horizontal)
    connectedSwitch.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 8)
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func encodeWithCoder(aCoder: NSCoder) {
    super.encodeWithCoder(aCoder)
  }
}
