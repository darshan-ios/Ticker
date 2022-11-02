

import UIKit
import SDWebImage

protocol MessageTableViewCellDelegate: class {
  func messageTableViewCellUpdate()
}

class MessageTableViewCell: UITableViewCell {
  
  @IBOutlet weak var profilePic: UIImageView?
  @IBOutlet weak var messageTextView: UITextView?
    @IBOutlet weak var dateTimeLbl: UILabel!
    
    let dateFormatter = DateFormatter()
    
    func set(_ message: ObjectMessage, _ isDateHidden: Bool) {
      profilePic?.image = UIImage(named: "profile pic")
    messageTextView?.text = message.message
      
        if isDateHidden == true {
            dateTimeLbl?.isHidden = true
            dateTimeLbl?.text = "\(DateService.shared.getDateStringFromServerTimeStemp(Double(message.timestamp))) " + "\(DateService.shared.format(Date(timeIntervalSince1970: TimeInterval(message.timestamp))))"
        }
        else {
            dateTimeLbl?.isHidden = false
            dateTimeLbl?.text = "\(DateService.shared.getDateStringFromServerTimeStemp(Double(message.timestamp))) " + "\(DateService.shared.format(Date(timeIntervalSince1970: TimeInterval(message.timestamp))))"
        }
      
    guard let imageView = profilePic else { return }
    guard let userID = message.ownerID else { return }
//      let strDate = DateService.shared.getDateStringFromServerTimeStemp(Double(message.timestamp))
   
    ProfileManager.shared.userData(id: userID) { user in
      guard let urlString = user?.profilePicLink else { return }
      imageView.sd_setImage(with: URL(string: urlString), placeholderImage: #imageLiteral(resourceName: "profile pic"))
    }
  }
}

class MessageAttachmentTableViewCell: MessageTableViewCell {
  
  @IBOutlet weak var attachmentImageView: UIImageView!
  @IBOutlet weak var attachmentImageViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var attachmentImageViewWidthConstraint: NSLayoutConstraint!
  @IBOutlet weak var dateandTimeLbl: UILabel!
    
  weak var delegate: MessageTableViewCellDelegate?
  
  override func prepareForReuse() {
    super.prepareForReuse()
    attachmentImageView.cancelDownload()
    attachmentImageView.image = nil
    attachmentImageViewHeightConstraint.constant = 250 / 1.3
    attachmentImageViewWidthConstraint.constant = 250
  }
  
  override func set(_ message: ObjectMessage, _ isDateHidden: Bool) {
      super.set(message, isDateHidden)
      if isDateHidden == true {
          dateTimeLbl?.isHidden = true
          dateandTimeLbl?.text = "\(DateService.shared.getDateStringFromServerTimeStemp(Double(message.timestamp))) " + "\(DateService.shared.format(Date(timeIntervalSince1970: TimeInterval(message.timestamp))))"
      }
      else {
          dateTimeLbl?.isHidden = false
          dateandTimeLbl?.text = "\(DateService.shared.getDateStringFromServerTimeStemp(Double(message.timestamp))) " + "\(DateService.shared.format(Date(timeIntervalSince1970: TimeInterval(message.timestamp))))"
      }
    switch message.contentType {
    case .location:
      attachmentImageView.image = UIImage(named: "locationThumbnail")
    case .photo:
      guard let urlString = message.profilePicLink else { return }
      attachmentImageView.setImage(url: URL(string: urlString)) {[weak self] image in
        guard let image = image, let weakSelf = self else { return }
        guard weakSelf.attachmentImageViewHeightConstraint.constant != image.size.height, weakSelf.attachmentImageViewWidthConstraint.constant != image.size.width else { return }
        if max(image.size.height, image.size.width) <= 250 {
          weakSelf.attachmentImageViewHeightConstraint.constant = image.size.height
          weakSelf.attachmentImageViewWidthConstraint.constant = image.size.width
          weakSelf.delegate?.messageTableViewCellUpdate()
          return
        }
        weakSelf.attachmentImageViewWidthConstraint.constant = 250
        weakSelf.attachmentImageViewHeightConstraint.constant = image.size.height * (250 / image.size.width)
        weakSelf.delegate?.messageTableViewCellUpdate()
      }
    default: break
    }
  }
}
