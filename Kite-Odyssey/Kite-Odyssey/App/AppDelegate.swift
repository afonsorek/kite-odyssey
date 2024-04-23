//
//  AppDelegate.swift
//  Kite-Odyssey
//
//  Created by Afonso Rekbaim on 20/03/24.
//

import SwiftUI
import AppTrackingTransparency
import FirebaseCore
import FirebaseMessaging
import GoogleMobileAds
import AdSupport
import FirebaseAnalytics

@main
class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        application.registerForRemoteNotifications()
        FirebaseApp.configure()
        
        #if DEBUG
            Analytics.setAnalyticsCollectionEnabled(false)
        #else
            Analytics.setAnalyticsCollectionEnabled(true)
        #endif
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
                        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )
        
        application.registerForRemoteNotifications()
        
        return true
    }
    

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let fcm = Messaging.messaging().fcmToken {
            print("Firebase: \(fcm)")
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
           // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
           // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
       }

       func applicationDidEnterBackground(_ application: UIApplication) {
           // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
       }

       func applicationWillEnterForeground(_ application: UIApplication) {
           // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
       }

       func applicationDidBecomeActive(_ application: UIApplication) {
           // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
       }

}
