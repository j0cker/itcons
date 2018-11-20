//
//  WebViewController.swift
//  ItCons
//
//  Created by MAC on 19/11/18.
//  Copyright © 2018 MAC. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    var serverUrl: String = ""
    var container: UIView = UIView()
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        webView.delegate = self
        
        if (serverUrl != nil && serverUrl != "") {
            let request = URLRequest(url: URL(string: serverUrl)!)
            webView.loadRequest(request)
            // Save URL value
            let defaults = UserDefaults.standard
            defaults.set(serverUrl, forKey: "ServerContext")
        } else if (UserDefaults.standard.object(forKey:"ServerContext") as? String ?? String() != nil) {
            serverUrl = UserDefaults.standard.object(forKey:"ServerContext") as? String ?? String()
            let request = URLRequest(url: URL(string: serverUrl)!)
            webView.loadRequest(request)
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        ViewControllerUtils().showActivityIndicator(uiView: view, container: container)
        print("WebView: LoadStart")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        ViewControllerUtils().hideActivityIndicator(uiView: container)
        print("WebView: LoadFinish")
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        ViewControllerUtils().hideActivityIndicator(uiView: container)
        if (serverUrl != nil && serverUrl != "") {
            let request = URLRequest(url: URL(string: serverUrl)!)
            webView.loadRequest(request)
            // Save URL value
            let defaults = UserDefaults.standard
            defaults.set(serverUrl, forKey: "ServerContext")
        } else if (UserDefaults.standard.object(forKey:"ServerContext") as? String ?? String() != nil) {
            serverUrl = UserDefaults.standard.object(forKey:"ServerContext") as? String ?? String()
            let request = URLRequest(url: URL(string: serverUrl)!)
            webView.loadRequest(request)
        }
        print("WebView: didFailLoadWithError")
    }
    
    
    
}
