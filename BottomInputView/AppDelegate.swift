//
//  AppDelegate.swift
//  BottomInputView
//
//  Created by nice2meet on 2023/2/27.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        // window?.rootViewController = ViewController()
        window?.rootViewController = BannerController()
        window?.makeKeyAndVisible()
        
        return true
    }


}

