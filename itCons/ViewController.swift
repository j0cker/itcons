//
//  ViewController.swift
//  TextFieldExample
//
//  Created by MAC on 18/10/18.
//  Copyright © 2018 MAC. All rights reserved.
//

import UIKit
import Alamofire

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
//        clickCount += 1
        
//        lblTitle.text = "Clicked \(clickCount) times"
        username = tfUserName.text!
        password = tfPassword.text!
        url = tfServerUrl.text!
        NSLog("Username: \(tfUserName.text!)");
        NSLog("Password: \(tfPassword.text!)");
        NSLog("URL: \(tfServerUrl.text!)");
//        mockRequest()
        mockRequest(credentials: [tfUserName.text!, tfPassword.text!])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func mockRequest(credentials: [String]) {
        let params = [
            "_username": credentials[0],
            "_password": credentials[1]
        ]
        
        Alamofire.request("https://postman-echo.com/get",
                          method: .get,
                          parameters: params,
                          encoding: URLEncoding.default)
            .validate()
            .responseJSON { response in
                guard response.result.isSuccess else {
                    NSLog("Error while fetching remote rooms")
                    return
                }
                
                let value = response.result.value
                //                let value2 = JSON(value).stringValue
                NSLog("Response: \(value)");
                
                
        }
    }
    
//    func mockRequest() {
//        let params = [
//            "username": "foo",
//            "password": "123456"
//        ]
//        
//        Alamofire.request("https://postman-echo.com/get",
//                          method: .get,
//                          parameters: params,
//                          encoding: URLEncoding.default)
//            .validate()
//            .responseJSON { response in
//                guard response.result.isSuccess else {
//                    NSLog("Error while fetching remote rooms")
//                    return
//                }
//                
//                let value = response.result.value
////                let value2 = JSON(value).stringValue
//                NSLog("Response: \(value)");
//                
//                
//        }
//    }



}

