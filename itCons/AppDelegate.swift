//
//  AppDelegate.swift
//  TextFieldExample
//
//  Created by MAC on 18/10/18.
//  Copyright © 2018 MAC. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // クッキー取得
        retrieveCookies()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        // クッキー保存
        storeCookies()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // クッキー保存
        storeCookies()
    }
    
    
    // UserDefaultにクッキーを保存するメソッド
    private func storeCookies() {
        // 現在保持されているクッキーを取り出します
        guard let cookies = HTTPCookieStorage.shared.cookies else { return }
        // UserDefaultsに保存できるデータ型に変換していきます
        var cookieDictionary = [String : AnyObject]()
        for cookie in cookies {
            cookieDictionary[cookie.name] = cookie.properties as AnyObject?
        }
        // UserDefaultsに保存します
        UserDefaults.standard.set(cookieDictionary, forKey: "cookie")
    }
    
    // UserDefaultからクッキーを取得するメソッド
    private func retrieveCookies() {
        // UserDefaultsに保存してあるクッキー情報を取り出します。（この時はまだ[String : AnyObject]型）
        guard let cookieDictionary = UserDefaults.standard.dictionary(forKey: "cookie") else { return }
        // HTTPCookie型に変換していきます
        for (_, cookieProperties) in cookieDictionary {
            if let cookieProperties = cookieProperties as? [HTTPCookiePropertyKey : Any] {
                if let cookie = HTTPCookie(properties: cookieProperties ) {
                    // クッキーをメモリ内にセットします
                    HTTPCookieStorage.shared.setCookie(cookie)
                }
            }
        }
    }

    // ~以下省略~
    
    
    


}

