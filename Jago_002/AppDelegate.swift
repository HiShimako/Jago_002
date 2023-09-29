//
//  AppDelegate.swift
//  Jago_002
//
//  Created by user on 2023/09/11.
//

import UIKit
import Firebase
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

// アプリのアップグレード時にユーザーが作成したrealm情報を維持する為のコード
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let config = Realm.Configuration(
               // 今回の変更では、最初のマイグレーションなので、バージョン番号を1に設定します。
               schemaVersion: 1,

               // バージョン番号が以前のバージョンよりも大きい場合に、マイグレーションブロックを設定します。
               migrationBlock: { migration, oldSchemaVersion in
                   // マイグレーションの内容を記述する
                   // 今回はスキーマが変更されたが、特に既存データの移行が必要ない場合、ここは空のままでも問題ありません。
               })

           // デフォルトの Realm に新しい設定を適用する
           Realm.Configuration.defaultConfiguration = config

      
        return true
        
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

