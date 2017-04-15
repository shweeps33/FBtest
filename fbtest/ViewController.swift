//
//  ViewController.swift
//  fbtest
//
//  Created by Admin on 23.02.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Foundation
import NotificationCenter

class ViewController: UIViewController {
    public var imageURLParsed: String? = nil
    var userName: String?
    
    let NTFKey = "ImageDidChange"
    let center = NotificationCenter.default
    
    
    @objc func checkLogIn(withNotification notification : NSNotification) {
        if ((FBSDKAccessToken.current()) != nil) {
            print("Access Token Activated");
            print("CURRENT TOKEN:\(FBSDKAccessToken.current().tokenString!)")
            
            let url = URL(string: "https://private-anon-552af0a44f-drugnews.apiary-proxy.com/users/login_by_facebook")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = "{\n  \"facebook_token\": \"\(FBSDKAccessToken.current().tokenString!)\"\n}".data(using: .utf8)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    do {
                        print(data)
                    }
                    
                } else {
                    print(error ?? "")
                }
            }
            
            task.resume()
            
            
        } else {
            print("Access Token Deactivated")
        }
    }
    
    
    
    //*****************************************
    
    func setNameFunc(name: String) {
        DispatchQueue.main.async {
            self.setName.text = name
        }
    }
    
    func updateUI() {
        if let imgURL = imageURLParsed, let usersName = userName {
            imageURLs = URL(string: imgURL)
            self.setNameFunc(name: usersName)
            DispatchQueue.main.async {
            self.imageView.frame = CGRect(x: self.view.frame.width/2-64, y: self.view.frame.height/4-64, width: 128, height: 128)
            self.view.addSubview(self.imageView)
            }
        }
    }
    
    let loginBtn: FBSDKLoginButton = {
        let btn = FBSDKLoginButton()
        btn.readPermissions = ["public_profile", "email"]
        return btn
    }()
    
    var imageURLs: URL? = nil {
        didSet {
            fetchImage()
        }
    }
    
    private func fetchImage() {
        if let url = imageURLs {
            if let imageData = NSData(contentsOf: url) {
                DispatchQueue.main.async {
                    self.image = UIImage(data: imageData as Data)
                }
                
            }
        }
    }
    
    private var imageView = UIImageView()
    
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }
    
    @IBOutlet weak var setName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(loginBtn)
        loginBtn.center = view.center;
        
        center.addObserver(self, selector: #selector(checkLogIn), name:NSNotification.Name.FBSDKAccessTokenDidChange, object:nil) //обсервер для кнопки "Логіна", запускає весь функціонал (checkLogIn)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

