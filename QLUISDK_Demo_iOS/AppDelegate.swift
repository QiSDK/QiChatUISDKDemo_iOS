//
//  AppDelegate.swift
//  QLUISDK_Demo_iOS
//

import UIKit
import IQKeyboardManagerSwift
import TeneasyChatSDKUI_iOS

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.enable = true
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("应用进入后台，ChatLib保持连接")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("应用即将进入前台，立即检查ChatLib连接状态")
        GlobalChatManager.shared.connectIfNeeded()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}
