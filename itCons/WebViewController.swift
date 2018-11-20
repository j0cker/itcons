//
//  WebViewController.swift
//  ItCons
//
//  Created by MAC on 19/11/18.
//  Copyright © 2018 MAC. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    var serverUrl: String = ""

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        print(serverUrl)
        let request = URLRequest(url: URL(string: serverUrl)!)
        webView.loadRequest(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
