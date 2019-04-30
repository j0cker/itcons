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
    var urlExt: String = ""
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
        let subdomainContext = defaults.object(forKey:"Subdomain") as? String ?? String()
        let urlExt = defaults.object(forKey:"urlExt") as? String ?? String()
        if (serverContext != "" && subdomainContext != "" && urlExt != "") {
//            perform(#selector(showWebViewController), with: nil, afterDelay: 1)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.showWebViewController(serverUrl: serverContext, subdomain: subdomainContext, urlExt: urlExt)
            })
            
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
    @IBOutlet weak var tfExt: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    
    @IBAction func btnClick(sender: UIButton) {
        if (ViewControllerUtils().isConnectedToNetwork()){
            if (!(tfServerUrl.text?.isEmpty)!) {
                
                urlExt = "es"
                checkURL(urlString: tfServerUrl.text!, urlExt: urlExt, user: tfUserName.text!, pass: tfPassword.text!)
                
            } else {
                print("Empty fields")
                self.view.showToast(toastMessage: "Rellene todos los campos", duration: 2)
            }
        } else {
            self.view.showToast(toastMessage: "Compruebe su conexión", duration: 2)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func checkURL(urlString: String, urlExt: String, user: String, pass: String) {
        
        if (!(tfUserName.text?.isEmpty)! && !(tfPassword.text?.isEmpty)!) {
            
            ViewControllerUtils().showActivityIndicator(uiView: self.view, container: container)
            
            // Set up the URL request
            let fullUrl = "https://\(urlString).itcons.\(urlExt)/admin/login"
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
                    self.cookieRequest(completion: { (data, success) in
                        
                        if(success == "FALSE" && self.urlExt == "es"){
                            self.urlExt = "app"
                            self.checkURL(urlString: self.tfServerUrl.text!, urlExt: self.urlExt, user: self.tfUserName.text!, pass: self.tfPassword.text!)
                        }
                        
                    }, url: urlString, urlExt: urlExt, credentials: [user, pass])
                } else {
                    // HTTPS
                    if let httpResponse = response as? HTTPURLResponse {
                        //                        print(httpResponse.statusCode)
                        //                        if (httpResponse.statusCode == 200) {
                        if (200...499 ~= httpResponse.statusCode) {
                            self.proto = "https"
                            self.cookieRequest(completion: { (data, success) in
                                
                                if(success == "FALSE" && self.urlExt == "es"){
                                    self.urlExt = "app"
                                    self.checkURL(urlString: self.tfServerUrl.text!, urlExt: self.urlExt, user: self.tfUserName.text!, pass: self.tfPassword.text!)
                                }
                                
                            }, url: urlString, urlExt: urlExt, credentials: [user, pass])
                        
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
    
    
    func cookieRequest(completion: @escaping ([Any]?, String) ->Void, url: String, urlExt: String, credentials: [String]) {
        
        print("CookieRequest")
        
        let params = [
            "_username": credentials[0],
            "_password": credentials[1]
        ]
        
        Alamofire.request("\(self.proto)://\(url).itcons.\(urlExt)/admin/login_check",
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
                        
                        completion(nil, "FALSE")
                        
                    } else {
                        if let data = responseObject.data {
                            let json = String(data: data, encoding: String.Encoding.utf8)
                            if ((json?.contains("Bad credentials"))! ||
                                (json?.contains("Your session has timed out"))! ||
                                (json?.contains("¿Has olvidado la contraseña?"))!){
                                print("PHPSESSID: Bad credentials");
                                self.retry(url: url, urlExt: urlExt, credentials: credentials)
                                completion(nil, "FALSE")
                                
                            } else {
                                let cookie = HTTPCookieStorage.shared.cookies![0]
                                print("PHPSESSID: \(cookie.value)")
                                self.showWebViewController(serverUrl: "\(self.proto)://\(url).itcons.\(urlExt)", subdomain: url, urlExt: urlExt)
                                ViewControllerUtils().hideActivityIndicator(uiView: self.container)
                                completion(nil, "TRUE")
                            }
                        }
                    }
                }
        }
        
        
    }
    
    func retry(url: String, urlExt: String, credentials: [String]) {
        print("Retry")
        let params = [
            "_username": credentials[0],
            "_password": credentials[1]
        ]
        
        Alamofire.request("\(self.proto)://\(url).itcons.\(urlExt)/admin/login_check",
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
                                self.showWebViewController(serverUrl: "\(self.proto)://\(url).itcons.\(urlExt)", subdomain: url, urlExt: urlExt)
                                ViewControllerUtils().hideActivityIndicator(uiView: self.container)
                            }
                        }
                        
                    }
                }
        }
        
    }
    
    func showWebViewController(serverUrl : String, subdomain : String, urlExt: String) {
        let viewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        if (serverUrl != "") {
            viewController.serverUrl = serverUrl
            viewController.subdomain = subdomain
            viewController.urlExt = urlExt
        }
        self.present(viewController, animated: false, completion: nil)  
    }
    
}

