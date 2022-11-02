

import UIKit

class AuthViewController: UIViewController {
  
  //MARK: IBOutlets
  @IBOutlet weak var registerImageView: UIImageView!
  @IBOutlet weak var registerNameTextField: UITextField!
  @IBOutlet weak var registerEmailTextField: UITextField!
    @IBOutlet weak var registerPhoneNumberTextField: UITextField!
    @IBOutlet weak var registerPasswordTextField: UITextField!
  @IBOutlet weak var loginEmailTextField: UITextField!
  @IBOutlet weak var loginPasswordTextField: UITextField!
  @IBOutlet var separatorViews: [UIView]!
  @IBOutlet weak var cloudsImageView: UIImageView!
  @IBOutlet weak var cloudsImageViewLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var loginViewTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var registerViewTopConstraint: NSLayoutConstraint!
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  //MARK: Private properties
  private var selectedImage: UIImage?
  private let manager = UserManager()
  private let imageService = ImagePickerService()
  
  //MARK: Lifecycle
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    animateClouds()
  }
}

//MARK: IBActions
extension AuthViewController {
  
  @IBAction func register(_ sender: Any) {
    guard let name = registerNameTextField.text, let email = registerEmailTextField.text, let password = registerPasswordTextField.text, let phone = registerPhoneNumberTextField.text else {
      return
    }
    guard !name.isEmpty else {
      separatorViews.filter({$0.tag == 2}).first?.backgroundColor = .red
      return
    }
    guard email.isValidEmail() else {
      separatorViews.filter({$0.tag == 3}).first?.backgroundColor = .red
        return
    }
      guard phone.isValidPhone() else {
          separatorViews.filter({$0.tag == 5}).first?.backgroundColor = .red
          return
      }
    guard password.count > 5 else {
      separatorViews.filter({$0.tag == 4}).first?.backgroundColor = .red
      return
    }
    view.endEditing(true)
    let user = ObjectUser()
    user.name = name
    user.email = email
    user.password = password
    user.phoneNum = phone
    user.profilePic = selectedImage
    ThemeService.showLoading(true)
    manager.register(user: user) {[weak self] response in
      ThemeService.showLoading(false)
      switch response {
        case .failure:
          self?.showAlert()
        case .success:
          let vc = UIStoryboard.initial(storyboard: UserManager().currentUserID().isNone ? .auth : .conversations)
            UIApplication.shared.keyWindow?.rootViewController = vc
      }
    }
  }
  
  @IBAction func login(_ sender: Any) {
    guard let email = loginEmailTextField.text, let password = loginPasswordTextField.text else {
      return
    }
    guard email.isValidEmail() else {
      separatorViews.filter({$0.tag == 0}).first?.backgroundColor = .red
      return
    }
    guard password.count > 5 else {
      separatorViews.filter({$0.tag == 1}).first?.backgroundColor = .red
      return
    }
    view.endEditing(true)
    let user = ObjectUser()
    user.email = email
    user.password = password
    ThemeService.showLoading(true)
    manager.login(user: user) {[weak self] response in
      ThemeService.showLoading(false)
      switch response {
      case .failure: self?.showAlert()
      case .success:
          let vc = UIStoryboard.initial(storyboard: UserManager().currentUserID().isNone ? .auth : .conversations)
            UIApplication.shared.keyWindow?.rootViewController = vc
      }
    }
  }
  
  @IBAction func switchViews(_ sender: UIButton) {
    let shouldShowLogin = loginViewTopConstraint.constant != 30
    sender.setTitle(!shouldShowLogin ? "Login": "Create New Account", for: .normal)
    loginViewTopConstraint.constant = shouldShowLogin ? 30 : -800
    registerViewTopConstraint.constant = shouldShowLogin ? -800 : 30
    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
      self.view.layoutIfNeeded()
    })
  }
  
  @IBAction func profileImage(_ sender: Any) {
    imageService.pickImage(from: self) {[weak self] image in
      self?.registerImageView.image = image
      self?.selectedImage = image
    }
  }
}

//MARK: Private methods
extension AuthViewController {
  
  private func animateClouds() {
    cloudsImageViewLeadingConstraint.constant = 0
    cloudsImageView.layer.removeAllAnimations()
    view.layoutIfNeeded()
    let distance = view.bounds.width - cloudsImageView.bounds.width
    self.cloudsImageViewLeadingConstraint.constant = distance
    UIView.animate(withDuration: 15, delay: 0, options: [.repeat, .curveLinear], animations: {
      self.view.layoutIfNeeded()
    })
  }
}

//MARK: UITextField Delegate
extension AuthViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return textField.resignFirstResponder()
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    separatorViews.forEach({$0.backgroundColor = .darkGray})
  }
}
