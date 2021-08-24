//
//  UserProfileVC.swift
//  Networking
//
//  Created by Valera Vasilevich on 23.08.21.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase

class UserProfileVC: UIViewController {
    
    lazy var fbLoginButton: UIButton = {
        let loginButton = FBLoginButton()
        loginButton.frame = CGRect(x: 64, y: view.frame.height - 128, width: view.frame.width - 128, height: 28)
        loginButton.delegate = self
        return loginButton
    }()
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        
        userNameLabel.isHidden = true
        
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchinUserData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    private func setupViews() {
        view.addSubview(fbLoginButton)
    }
    
}

// MARK: Facebook SDK

extension UserProfileVC: LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        if error != nil {
            print(error!)
            return
        }
        
        print("Successfully logged in with Facebook...")
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
        
        print("Did log out of Facebook...")
        
        
        openLoginViewController()
        
    }
    
    
    private func openLoginViewController() {
        
        do {
            try Auth.auth().signOut()
            
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                self.present(loginViewController, animated: true, completion: nil)
                return
            }
        } catch let error {
            print("Failed to sign out with error: ", error.localizedDescription)
        }
    }
    
    private func fetchinUserData() {
        
        if Auth.auth().currentUser != nil {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            Database.database().reference().child("users").child(uid)
                .observeSingleEvent(of: .value) { (snapshot) in
                    
                    guard let userData = snapshot.value as? [String: Any] else { return }
                    let currentUser = CurrentUser(uid: uid, data: userData)
                    
                    self.activityIndicator.stopAnimating()
                    self.userNameLabel.isHidden = false
                    
                    self.userNameLabel.text = "\(currentUser?.name ?? "Noname") Logged in with Facebook"
                    
                } withCancel: { (error) in
                    print(error)
                }

        }
    }
    
    
}
