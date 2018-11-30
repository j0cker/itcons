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
    var subdomain: String = ""
    var container: UIView = UIView()
    let refreshControl: UIRefreshControl = UIRefreshControl()
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        webView.delegate = self
        
        if (serverUrl != "") {
            let request = URLRequest(url: URL(string: serverUrl)!)
            webView.loadRequest(request)
            // Save URL value
            let defaults = UserDefaults.standard
            defaults.set(serverUrl, forKey: "ServerContext")
            defaults.set(subdomain, forKey: "Subdomain")
        } else if (UserDefaults.standard.object(forKey:"ServerContext") as? String ?? String() != nil) {
            serverUrl = UserDefaults.standard.object(forKey:"ServerContext") as? String ?? String()
            let request = URLRequest(url: URL(string: serverUrl)!)
            webView.loadRequest(request)
        }
        
        // Text (Pull to refresh) with format (Textcolor Black) for RefreshControl
        refreshControl.attributedTitle = NSAttributedString(string: "Deslice para refrescar", attributes: [
            NSForegroundColorAttributeName: UIColor.white
            ])
        
        // #selector(refresh) = "refresh" function called
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        
        // TintColor - Color of Activity Indicator
        refreshControl.tintColor = UIColor.white
        
        // Add RefreshControl to WebView
        webView.scrollView.addSubview(refreshControl)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        ViewControllerUtils().showActivityIndicator(uiView: view, container: container)
        //        print("WebView: LoadStart")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        ViewControllerUtils().hideActivityIndicator(uiView: container)
        //        refreshControl.endRefreshing()
        //        print("WebView: LoadFinish")
        let currentURL = self.webView.request?.mainDocumentURL?.absoluteString;
        //        print("CURR_URL: \(currentURL)")
        if (currentURL != nil && currentURL != "" && (currentURL?.contains("admin/login"))!) {
            removeCookies()
            let defaults = UserDefaults.standard
            defaults.set("", forKey: "ServerContext")
            defaults.removeObject(forKey:"cookie")
            self.showLoginViewController()
        }
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        ViewControllerUtils().hideActivityIndicator(uiView: container)
        refreshControl.endRefreshing()
        //        print("WebView: didFailLoadWithError")
        let currentURL = self.webView.request?.mainDocumentURL?.absoluteString;
        //        print("CURR_URL: \(currentURL)")
        if (currentURL != nil && currentURL != "" && (currentURL?.contains("admin/login"))!) {
            removeCookies()
            let defaults = UserDefaults.standard
            defaults.set("", forKey: "ServerContext")
            defaults.removeObject(forKey:"cookie")
            self.showLoginViewController()
        } else {
            self.view.showToast(toastMessage: "Compruebe su conexión", duration: 2)
        }
    }
    
    // Forbid external links
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let requestURL = request.mainDocumentURL?.absoluteString;
        if (!(requestURL?.contains(".itcons.es"))!) {
            return false
        }
        return true
    }
    
    // Refresh the WebView
    func refresh(sender:AnyObject) {
        refreshControl.endRefreshing()
        webView.reload()
    }
    
    func showLoginViewController() {
//        let viewController = UIStoryboard(name: "Main", bundle: nil)
//            .instantiateViewController(withIdentifier: "ViewController") as! ViewController
////        self.present(viewController, animated: false, completion: nil)
//        self.present(viewController, animated: false, completion: {
            self.dismiss(animated: false, completion: nil)
//        })
    }
    
    func removeCookies() {
        let storage = HTTPCookieStorage.shared
        for cookie in storage.cookies! {
            storage.deleteCookie(cookie)
        }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        let currentURL = self.webView.request?.mainDocumentURL?.absoluteString;
        if (self.presentedViewController != nil && !(currentURL?.contains("admin/login"))!) {
            super.dismiss(animated: flag, completion: completion)
        } else if ((currentURL?.contains("admin/login"))!) {
            removeCookies()
            let defaults = UserDefaults.standard
            defaults.set("", forKey: "ServerContext")
            defaults.removeObject(forKey:"cookie")
            let viewController = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "ViewController") as! ViewController
            self.present(viewController, animated: false, completion: nil)
        }
    }
    
    
    
}
