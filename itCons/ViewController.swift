//
//  ViewController.swift
//  TextFieldExample
//
//  Created by MAC on 18/10/18.
//  Copyright © 2018 MAC. All rights reserved.
//

import UIKit
import Alamofire
import Foundation

class ViewController: UIViewController {
    var clickCount = 0
    //created a string variable
    var username: String = ""
    var password: String = ""
    var url: String = ""
    var proto: String = "http"
    var httpsMode: Bool = false
    var container: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let defaults = UserDefaults.standard
        let serverContext = defaults.object(forKey:"ServerContext") as? String ?? String()
        if (serverContext != nil && serverContext != "") {
            ViewControllerUtils().showActivityIndicatorBackground(uiView: self.view, container: container)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Check if user is logged
        let defaults = UserDefaults.standard
        let serverContext = defaults.object(forKey:"ServerContext") as? String ?? String()
        if (serverContext != nil && serverContext != "") {
            print("SERV1: \(serverContext)")
            perform(#selector(showWebViewController), with: nil, afterDelay: 1)
            
        }
    }
    
    
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tfUserName: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfServerUrl: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    
    @IBAction func btnClick(sender: UIButton) {
        ViewControllerUtils().showActivityIndicator(uiView: self.view, container: container)
        cookieRequest(url: tfServerUrl.text!, credentials: [tfUserName.text!, tfPassword.text!])
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func cookieRequest(url: String, credentials: [String]) {
        let params = [
            "_username": credentials[0],
            "_password": credentials[1]
        ]
        
        if (!url.isEmpty && !credentials[0].isEmpty && !credentials[0].isEmpty) {
            
            Alamofire.request("\(proto)://\(url).itcons.es/admin/login_check",
                method: .post,
                parameters: params,
                encoding: URLEncoding.default)
                .responseData { (responseObject) -> Void in
                    
                    if let responseStatus = responseObject.response?.statusCode {
                        if responseStatus != 200 {
                            // TODO
                            print("ERROR: Not valid URL")
                        } else {
                            if let data = responseObject.data {
                                let json = String(data: data, encoding: String.Encoding.utf8)
                                if ((json?.contains("Bad credentials"))! ||
                                    (json?.contains("Your session has timed out"))! ||
                                    (json?.contains("¿Has olvidado la contraseña?"))!){
                                    print("PHPSESSID: Bad credentials");
                                    self.retry(url: url, credentials: credentials)
                                } else {
                                    let cookie = HTTPCookieStorage.shared.cookies![0]
                                    print("PHPSESSID: \(cookie.value)")
                                    self.showWebViewController(serverUrl: "\(self.proto)://\(url).itcons.es")
                                    ViewControllerUtils().hideActivityIndicator(uiView: self.container)
                                }
                            }
                        }
                    }
            }
            
        } else {
            // TODO show Bad Credentials Toast
            print("Empty fields")
        }
        
        
    }
    
    func retry(url: String, credentials: [String]) {
        let params = [
            "_username": credentials[0],
            "_password": credentials[1]
        ]
        
        Alamofire.request("\(proto)://\(url).itcons.es/admin/login_check",
            method: .post,
            parameters: params,
            encoding: URLEncoding.default)
            .responseData { (responseObject) -> Void in
                
                if let responseStatus = responseObject.response?.statusCode {
                    if responseStatus != 200 {
                        // TODO
                        print("ERROR: Not valid URL")
                    } else {
                        if let data = responseObject.data {
                            let json = String(data: data, encoding: String.Encoding.utf8)
                            if ((json?.contains("Bad credentials"))! ||
                                (json?.contains("Your session has timed out"))! ||
                                (json?.contains("¿Has olvidado la contraseña?"))!){
                                print("PHPSESSID: Bad credentials");
                                if (!self.httpsMode) {
                                    self.httpsMode = true
                                    self.proto = "https"
                                    self.cookieRequest(url: self.tfServerUrl.text!, credentials: [self.tfUserName.text!, self.tfPassword.text!])
                                } else {
                                    // TODO show Bad Credentials Toast
                                    ViewControllerUtils().hideActivityIndicator(uiView: self.container)
                                    self.proto = "http"
                                    self.httpsMode = false
                                    
                                }
                            } else {
                                let cookie = HTTPCookieStorage.shared.cookies![0]
                                print("PHPSESSID: \(cookie.value)")
                                self.showWebViewController(serverUrl: "\(self.proto)://\(url).itcons.es")
                                ViewControllerUtils().hideActivityIndicator(uiView: self.container)
                            }
                        }
                    }
                }
        }
        
    }
    
    @objc func showWebViewController(serverUrl : String) {
        let viewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        if (serverUrl != nil && serverUrl != "") {
            viewController.serverUrl = serverUrl
        }
        self.present(viewController, animated: false, completion: nil)
    }
    
    
    
}

