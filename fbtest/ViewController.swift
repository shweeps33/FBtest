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
    public var parsedID: String? = nil
    var userName: String?
    
    let NTFKey = "ImageDidChange"
    let center = NotificationCenter.default
    
    
    @objc func checkLogIn(withNotification notification : NSNotification) {
        if ((FBSDKAccessToken.current()) != nil) {
            print("Access Token Activated");
            print("CURRENT TOKEN:\(FBSDKAccessToken.current().tokenString!)")
            let access_t = "\(FBSDKAccessToken.current().tokenString!)"
            
            let url = URL(string: "https://graph.facebook.com/me?fields=id,name&access_token=\(access_t)")! //посилання для отримання ID, по якому потім отримаєм зображення, але респонс видає тільки заголовок, без body, тому розпарсити та отримати айдішнік мені поки не вдалось
            //let url = URL(string: "https://graph.facebook.com/100015045016071/picture?access_token="+access_t+"&type=large&redirect=false")! //тут я перевіряю чи працює запит зображення по айдішніку, захардкодивши свій айді (100015045016071), все працює, але звичайно толку від цього мало)
            
            var request = URLRequest(url: url)
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let data1 = data {
                    if let response1 = response {
                        do {
                            print("DATA: \(data1)")
                            print("RESPONSE: \(response1)") //без поняття чому але вертає тільки заголовок, хоча в браузері повертає body, як і мало б бути
                            if let json = try JSONSerialization.jsonObject(with: data1) as? [String: Any],
                                let datas = json["data"] as? [String: Any],
                                let id = datas["id"] as? String {
                                    self.parsedID = id //парсинг джейсона
                            }
                            if let json = try JSONSerialization.jsonObject(with: data1) as? [String: Any],
                                let datas = json["data"] as? [String: Any],
                                let name = datas["name"] as? String {
                                self.userName = name //парсинг джейсона
                            }
                            self.updateUI() //оновлюєм юайку розпарсеним джейсоном
                            
                        } catch {
                            print("Error deserializing JSON: \(error)")
                        }
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
        
        if let imgURL = imageURLParsed {
            imageURLs = URL(string: imgURL)
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

