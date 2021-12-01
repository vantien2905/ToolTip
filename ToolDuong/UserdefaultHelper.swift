//
//  UserdefaultHelper.swift
//  ToolDuong
//
//  Created by Tien Dinh on 30/11/2021.
//

import Foundation

enum UserDefaultKey: String {
    case maxPrice
}

class UserdefaultHelper {
    static let shared = UserdefaultHelper()
    
    private init() {}
    
    let userDefault = UserDefaults.standard
    
    func addData(_ value: String, key: UserDefaultKey) {
        userDefault.set(value, forKey: key.rawValue)
    }
    
    func getData(_ key: UserDefaultKey) -> String {
        return userDefault.string(forKey: key.rawValue) ?? ""
    }
}
