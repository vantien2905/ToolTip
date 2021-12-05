//
//  UserDefaultHelper.swift
//  ToolDuong
//
//  Created by Tien Dinh on 05/12/2021.
//

import Foundation

enum UserDefaultKey: String {
    case minPrice
    case maxPrice
    case hightlightPrice
    case wantBuyPrice
}


class UserDefaultHelper {
    static let shared = UserDefaultHelper()
    
    let userDefault = UserDefaults.standard
    
    func setData(_ value: Int, key: UserDefaultKey) {
        userDefault.removeObject(forKey: key.rawValue)
        userDefault.set(value, forKey: key.rawValue)
    }
    
    func getInt(_ key: UserDefaultKey) -> Int {
        return userDefault.integer(forKey: key.rawValue)
    }
}
