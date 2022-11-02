

import UIKit

class ConversationCell: UITableViewCell {
  
  //MARK: IBOutlets
  @IBOutlet weak var profilePic: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  
  //MARK: Private properties
  let userID = UserManager().currentUserID() ?? ""
  
  //MARK: Public methods
  func set(_ conversation: ObjectConversation) {
    timeLabel.text = DateService.shared.format(Date(timeIntervalSince1970: TimeInterval(conversation.timestamp)))
    messageLabel.text = conversation.lastMessage
    guard let id = conversation.userIDs.filter({$0 != userID}).first else { return }
    let isRead = conversation.isRead[userID] ?? true
    if !isRead {
      nameLabel.font = nameLabel.font.bold
      messageLabel.font = messageLabel.font.bold
      messageLabel.textColor = ThemeService.purpleColor
      timeLabel.font = timeLabel.font.bold
    }
    ProfileManager.shared.userData(id: id) {[weak self] profile in
      self?.nameLabel.text = profile?.name
      guard let urlString = profile?.profilePicLink else {
        self?.profilePic.image = UIImage(named: "profile pic")
        return
      }
      self?.profilePic.setImage(url: URL(string: urlString))
    }
  }
  
  //MARK: Lifecycle
  override func prepareForReuse() {
    super.prepareForReuse()
    profilePic.cancelDownload()
    nameLabel.font = nameLabel.font.regular
    messageLabel.font = messageLabel.font.regular
    timeLabel.font = timeLabel.font.regular
    messageLabel.textColor = .gray
    messageLabel.text = nil
  }
}

