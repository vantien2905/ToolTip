//
//  LoginViewController.swift
//  ToolDuong
//
//  Created by Tien Dinh on 28/11/2021.
//

import UIKit
import FirebaseRemoteConfig
import Firebase

enum RemoteConfigKey: String {
    case serverUrl = "api_url"
}


class LoginViewController: UIViewController {
    
    @IBOutlet weak var userNameTextfield: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBAction func loginButtonTapped() {
//        let deviceID = UIDevice.current.identifierForVendor!.uuidString
//        print("\(deviceID)")
//        let newUrl = RemoteConfigManager.shared.getValue(fromKey: .serverUrl)
//        print(newUrl)
//
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(identifier: "ViewController")
//        vc.modalPresentationStyle = .fullScreen
//        self.present(vc, animated: true, completion: nil)
    }
    
}


//    struct RemoteConfigManager {
//
//      // local default value
//
//        static let shared = RemoteConfigManager()
//
//        fileprivate var remoteConfig: RemoteConfig
//
//        fileprivate init() {
//            self.remoteConfig = RemoteConfig.remoteConfig()
//        }
//
//        func getValue(fromKey key: RemoteConfigKey) -> String {
//
//            if let value = self.remoteConfig.configValue(forKey: key.rawValue).stringValue {
//                return value
//            }
//            return ""
//        }
//
//
//        func fetchRemoteConfig(_ finish: (()-> Void)?) {
//            let expirationDuration = 10
////            if self.remoteConfig.configSettings.isDeveloperModeEnabled {
////                expirationDuration = 0
////            }
//            remoteConfig.fetch(withExpirationDuration: TimeInterval(expirationDuration)) { (status, _) in
//                if status == RemoteConfigFetchStatus.success {
//                    self.remoteConfig.fetchAndActivate(completionHandler: nil)
////                    self.remoteConfig.activate(completion: nil)
////                    self.remoteConfig.activateFetched()
//                    let url =  RemoteConfigManager.shared.getValue(fromKey: .serverUrl)
//                }
//                finish?()
//            }
//        }
//
//    }
