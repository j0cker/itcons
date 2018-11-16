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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tfUserName: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfServerUrl: UITextField!
    @IBOutlet weak var btnLogin: UIButton!

    @IBAction func btnClick(sender: UIButton) {
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
        
        Alamofire.request("https://\(url).itcons.es/admin/login_check",
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
                                (json?.contains("Your session has timed out"))!){
                                print("PHPSESSID: Bad credentials");
                            } else {
                                let cookie = HTTPCookieStorage.shared.cookies![0]
                                print("PHPSESSID: \(cookie.value)")
                            }
                        }
                    }
                }
        }
        
        
    }



}

