//
//  ViewController.swift
//  TextFieldExample
//
//  Created by MAC on 18/10/18.
//  Copyright © 2018 MAC. All rights reserved.
//

import UIKit

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

