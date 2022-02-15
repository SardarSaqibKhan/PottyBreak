//
//  AppDelegate.swift
//  PottyBreak
//
//  Created by MacBook Pro on 14/03/2019.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import GoogleSignIn
import UserNotifications

import Firebase
import FirebaseCore
import FirebaseInstanceID
import FirebaseAuth
import FirebaseMessaging
import FirebaseDatabase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

     let gcmMessageIDKey = "gcm.message_id"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        ////Google Api Keys
        GMSPlacesClient.provideAPIKey("AIzaSyAqu4LBAcUGQ19eORpHjKSQqKDe9d_SimY")
        GMSServices.provideAPIKey("AIzaSyAqu4LBAcUGQ19eORpHjKSQqKDe9d_SimY")
        
        configureNotification(application)
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        UserManager.shared.currentUser =   User(id: "123", name: "Junaid", email: "abc@gmail.com");
    
        if UserDefaults.standard.object(forKey: "FirstInstall") == nil{
            UserDefaults.standard.set(false, forKey:
                "FirstInstall")
            UserDefaults.standard.synchronize()
        }
        if UserDefaults.standard.bool(forKey: "FirstInstall")
        {
            
        }else{
            try? Auth.auth().signOut()
            UserDefaults.standard.set(true, forKey:
                "FirstInstall")
        }
        return true
    }
   
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        if let id = Auth.auth().currentUser?.uid
        {
            Database.database().reference().child("Users").child(id).updateChildValues(["badge":0])
            UIApplication.shared.applicationIconBadgeNumber = 0
            print("UserID:\(id) updated badge to zero when we come back into foreground")
        }
    
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}
extension AppDelegate
{
   func configureNotification(_ application: UIApplication)
   {
    UIApplication.shared.applicationIconBadgeNumber = 0
    if #available(iOS 10.0, *) {
        // For iOS 10 display notification (sent via APNS)
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
    } else {
        let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
    }
    
    application.registerForRemoteNotifications()
    }
}



@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Notification Created Shukar");
        
        if UIApplication.shared.applicationState == .active { // In iOS 10 if app is in foreground do nothing.
            var id = notification.request.content.userInfo["from_User_Id"]! as! String
            //  Database.database().reference().child("Badges").updateChildValues([id:0]);
            Database.database().reference().child("Users").child(id).updateChildValues(["badge":0])
            
            return;
        } else { // If app is not active you can show banner, sound and badge.
            completionHandler([.alert, .badge, .sound])
        }
        
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        let application = UIApplication.shared
        
        if(application.applicationState == .active){
            print("user tapped the notification bar when the app is in foreground")
            // window?.rootViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Dashboard")
            
        }
        
        if(application.applicationState == .inactive)
        {
            print("user tapped the notification bar when the app is in background")
            let  from_name = response.notification.request.content.userInfo["from_name"] as! String
            let  from_User_Id = response.notification.request.content.userInfo["from_User_Id"] as! String
            let  CID = response.notification.request.content.userInfo["chatID"] as! String
            UserDefaults.standard.set(from_User_Id, forKey: "from_User_Id")

            var destination =  UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AllContactsVC") as! AllContactsVC
            let userId = from_User_Id
            destination.toID = userId
            Database.database().reference(withPath: "Chats").child("\(CID)").observe(.value) { (snapshot) in
                        let json = snapshot.value as! [String:Any]
                        let chat = Chat(json: json)
                        chat.id = CID;
                        
                        Database.database().reference(withPath: "Users").child("\(userId)").observe(.value) { (snapshot) in
                            let json = snapshot.value as! [String: Any]
//                            destination.partnerUser = User(json: json)
//                            destination.chat = chat
                            self.window?.rootViewController = destination

                        }}
                }
    }
}



extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        
        print("Firebase registration token----: \(fcmToken)");
        postToken();
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        postToken();
        
    }
    func postToken()
    {
        if let refreshedToken = InstanceID.instanceID().token() {//1Open
            print("==========================================================================AppDelegate-InstanceID TokenExist===============: \(refreshedToken)")
            if let id = Auth.auth().currentUser?.uid{       //2Open
                print("current User Exist:\(id)");
                if let user = UserDefaults.standard.string(forKey: "user") //3Open
                {
                    print("User in UD Exist:\(user)");
                    
                    if(user == Auth.auth().currentUser!.uid) //4Open
                    {
                        print("user in UD and Current user matched");
                        UserDefaults.standard.set(refreshedToken as Any?, forKey: "token");
                        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).updateChildValues(["fcmToken":refreshedToken]);
                    }
                    else{ //4Closed
                        print("user in ud and current user not matched");
                        Database.database().reference().child("Users").child(user).updateChildValues(["fcmToken":""]);
                        Database.database().reference().child("Users").child(id).updateChildValues(["fcmToken":refreshedToken])
                        UserDefaults.standard.set(refreshedToken as Any?, forKey: "token");
                        UserDefaults.standard.set(id as Any?, forKey: "user");
                        
                    }
                }
                else{   //3Closed
                    print("user not exist in UD");
                    UserDefaults.standard.set(refreshedToken as Any?, forKey: "token");
                    UserDefaults.standard.set(id as Any?, forKey: "user");
                    Database.database().reference().child("Users").child(id).updateChildValues(["fcmToken":refreshedToken])
                }
            }
            else{
                print("Current User not Exist");
                UserDefaults.standard.set(refreshedToken as Any?, forKey: "token")
            }
        }
        else {//1C
            print("Token not Fount");
        }
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Message Data", remoteMessage.appData)
    }
    func postToken(Token:[String:AnyObject])
    {
        let dbRef = Database.database().reference();
        dbRef.child("fcmToken").child(Messaging.messaging().fcmToken!).setValue(Token);
    }
}


