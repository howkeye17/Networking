//
//  LoginViewController.swift
//  Networking
//
//  Created by Valera Vasilevich on 18.08.21.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {
    
//    var ref: DatabaseReference!
    
    var userProfile: UserProfile?
    
    lazy var fbLoginButton: UIButton = {
        let loginButton = FBLoginButton()
        loginButton.frame = CGRect(x: 32, y: 350, width: view.frame.width - 64, height: 28)
        loginButton.delegate = self
        return loginButton
    }()
    
    lazy var customFBLoginButton: UIButton = {
        
        let loginButton = UIButton()
        loginButton.backgroundColor = UIColor.blue
        loginButton.setTitle("Login with Facebook", for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.frame = CGRect(x: 32, y: 420, width: view.frame.width - 64, height: 28)
        loginButton.layer.cornerRadius = 4
        loginButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
        
        return loginButton
    }()
    
    lazy var signInWithEmail: UIButton = {
       
        let loginButton = UIButton()
        loginButton.frame = CGRect(x: 32, y: 490, width: view.frame.width - 64, height: 28)
        loginButton.setTitle("Sign In with Email", for: .normal)
        loginButton.addTarget(self, action: #selector(openSignInVC), for: .touchUpInside)
        return loginButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        
        setupViews()
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    private func setupViews() {
        view.addSubview(fbLoginButton)
        view.addSubview(customFBLoginButton)
        view.addSubview(signInWithEmail)
    }
    
    private func openMainViewController() {
        dismiss(animated: true)
    }
    
    @objc private func openSignInVC() {
        performSegue(withIdentifier: "SignIn", sender: self)
    }
    
}

// MARK: Facebook SDK

extension LoginViewController: LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        if error != nil {
            print(error!)
            return
        }
        
        guard AccessToken.isCurrentAccessTokenActive else { return }
        
        signIntoFirebase()
        
        print("Successfully logged in with Facebook....")
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
        print("User log out from Facebook...")
    }
    
    @objc private func handleCustomFBLogin() {
        
        LoginManager().logIn(permissions: ["email", "public_profile"], from: self) { (result, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let result = result else { return }
            
            if result.isCancelled { return }
            else {
                self.signIntoFirebase()
            }
        }
    }
    
    private func signIntoFirebase() {
        
        let accessToken = AccessToken.current
        
        guard let accessTokenString = accessToken?.tokenString else { return }
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        Auth.auth().signIn(with: credentials) { (user, error)  in
            
            if let error = error {
                print("Something went wrong with our facebook user: ", error)
                return
            }
            
            print("Successfully logged in with our FB user.")
            self.fetchFacebookfields()
        }
    }
    
    private func fetchFacebookfields() {
        
        GraphRequest(graphPath: "me", parameters: ["fields" : "id, name, email"]).start { (_, result, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            if let userData = result as? [String: Any] {
                self.userProfile = UserProfile(data: userData)
                print(userData)
                print(self.userProfile?.name ?? "nil")
                self.saveIntoFirebase()
            }
        }
    }
    
    private func saveIntoFirebase() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userData = ["name" : userProfile?.name, "email" : userProfile?.email]
        
        let values = [uid : userData]
        
        //        ref = Database.database().reference()
        
        Database.database().reference().child("users").updateChildValues(values) { (error, _) in
            
            if let error = error {
                print(error)
                return
            }
            
            print("Successfully saved user into Firebase database.")
            self.openMainViewController()
        }
    }
    
}


