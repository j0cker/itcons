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
    var username: String = ""
    var password: String = ""
    var url: String = ""
    var proto: String = ""
    var access: Bool = false
    var container: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let defaults = UserDefaults.standard
        let serverContext = defaults.object(forKey:"ServerContext") as? String ?? String()
        if (serverContext != "") {
            ViewControllerUtils().showActivityIndicatorBackground(uiView: self.view, container: container)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tfUserName.borderStyle = UITextBorderStyle.roundedRect
        tfPassword.borderStyle = UITextBorderStyle.roundedRect
        tfServerUrl.borderStyle = UITextBorderStyle.roundedRect
        tfDomain.borderStyle = UITextBorderStyle.roundedRect
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Check if user is logged
        let defaults = UserDefaults.standard
        let serverContext = defaults.object(forKey:"ServerContext") as? String ?? String()
        if (serverContext != "") {
            perform(#selector(showWebViewController), with: nil, afterDelay: 1)
        } else {
            let subdomain = defaults.object(forKey:"Subdomain") as? String ?? String()
            if (subdomain != "") {
                tfServerUrl.text = subdomain
            }
        }
    }
    
    
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tfUserName: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfServerUrl: UITextField!
    @IBOutlet weak var tfDomain: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    
    @IBAction func btnClick(sender: UIButton) {
        if (!(tfServerUrl.text?.isEmpty)!) {
            checkURL(urlString: tfServerUrl.text!)
        } else {
            print("Empty fields")
            self.view.showToast(toastMessage: "Rellene todos los campos", duration: 2)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func checkURL(urlString: String){
        
        if (!(tfUserName.text?.isEmpty)! && !(tfPassword.text?.isEmpty)!) {
            
            ViewControllerUtils().showActivityIndicator(uiView: self.view, container: container)
            
            // Set up the URL request
            let fullUrl = "https://\(urlString).itcons.es/admin/login"
            let url = URL(string: fullUrl)
            let urlRequest = URLRequest(url: url!)
            
            // set up the session
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            // make the request
            let task = session.dataTask(with: urlRequest) {
                (data, response, error) in
                // check for any errors on HTTPS protocol
                if (error != nil) {
                    // HTTP
                    self.proto = "http"
                    self.cookieRequest(url: self.tfServerUrl.text!, credentials: [self.tfUserName.text!, self.tfPassword.text!])
                } else {
                    // HTTPS
                    if let httpResponse = response as? HTTPURLResponse {
//                        print(httpResponse.statusCode)
//                        if (httpResponse.statusCode == 200) {
                        if (200...499 ~= httpResponse.statusCode) {
                            self.proto = "https"
                            self.cookieRequest(url: self.tfServerUrl.text!, credentials: [self.tfUserName.text!, self.tfPassword.text!])
                        } else {
                            self.view.showToast(toastMessage: "No pudo conectarse con el servidor", duration: 2)
                        }
                    }
                }
                
            }
            task.resume()
            
        } else {
            print("Empty fields")
            self.view.showToast(toastMessage: "Rellene todos los campos", duration: 2)
        }
    }
    
    
    func cookieRequest(url: String, credentials: [String]) {
        print("CookieRequest")
        let params = [
            "_username": credentials[0],
            "_password": credentials[1]
        ]
        
        Alamofire.request("\(self.proto)://\(url).itcons.es/admin/login_check",
            method: .post,
            parameters: params,
            encoding: URLEncoding.default)
            .responseData { (responseObject) -> Void in
                
                if let responseStatus = responseObject.response?.statusCode {
                    if responseStatus != 200 {
                        // TODO
                        print("ERROR: Not valid URL")
                        ViewControllerUtils().hideActivityIndicator(uiView: self.container)
                        self.view.showToast(toastMessage: "Subdominio erróneo", duration: 2)
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
                                self.showWebViewController(serverUrl: "\(self.proto)://\(url).itcons.es", subdomain: url)
                                ViewControllerUtils().hideActivityIndicator(uiView: self.container)
                            }
                        }
                    }
                }
        }
        
        
    }
    
    func retry(url: String, credentials: [String]) {
        print("Retry")
        let params = [
            "_username": credentials[0],
            "_password": credentials[1]
        ]
        
        Alamofire.request("\(self.proto)://\(url).itcons.es/admin/login_check",
            method: .post,
            parameters: params,
            encoding: URLEncoding.default)
            .responseData { (responseObject) -> Void in
                
                if let responseStatus = responseObject.response?.statusCode {
                    if responseStatus != 200 {
                        // TODO
                        print("ERROR: Not valid URL")
                        ViewControllerUtils().hideActivityIndicator(uiView: self.container)
                        self.view.showToast(toastMessage: "Subdominio erróneo", duration: 2)
                    } else {
                        if let data = responseObject.data {
                            let json = String(data: data, encoding: String.Encoding.utf8)
                            if ((json?.contains("Bad credentials"))! ||
                                (json?.contains("Your session has timed out"))! ||
                                (json?.contains("¿Has olvidado la contraseña?"))!){
                                print("PHPSESSID: Bad credentials");
                                ViewControllerUtils().hideActivityIndicator(uiView: self.container)
                                self.view.showToast(toastMessage: "Credenciales erróneas", duration: 2)
                                //                                }                               }
                            } else {
                                let cookie = HTTPCookieStorage.shared.cookies![0]
                                print("PHPSESSID: \(cookie.value)")
                                self.showWebViewController(serverUrl: "\(self.proto)://\(url).itcons.es", subdomain: url)
                                ViewControllerUtils().hideActivityIndicator(uiView: self.container)
                            }
                        }
                    }
                }
        }
        
    }
    
    @objc func showWebViewController(serverUrl : String, subdomain : String) {
        let viewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        if (serverUrl != "") {
            viewController.serverUrl = serverUrl
            viewController.subdomain = subdomain
        }
        self.present(viewController, animated: false, completion: nil)
    }
    
    
    
}

