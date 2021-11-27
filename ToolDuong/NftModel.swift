//
//  NftModel.swift
//  ToolDuong
//
//  Created by Tien Dinh on 26/11/2021.
//

import Foundation
import UIKit
import SystemConfiguration

//"id":1517604,
//"name":"Metamon",
//"image_url":"https://racawebsource.s3.us-east-2.amazonaws.com/metamon/media/normal/Spirit-J2-4308.png",
//"count":1,
//"fixed_price":"715999",
//"highest_price":"0",
//"status":"active",
//"sale_type":"fixed_price",
//"token_id":"384427",
//"sale_address":"0x7B4452dD6c38597fa9364AC8905C27EA44425832"
//"status": "active",

postfix operator &
postfix func & <T>(element: T?) -> String {
    return (element == nil) ? "" : "\(element!)"
}

postfix func & <T>(element: T) -> String {
    return "\(element)"
}


import UIKit
import ObjectMapper

class BaseEntity: NSObject, Mappable {
    
    override init() {}
    
    required init?(map: Map) {
        super.init()
        self.mapping(map: map)
    }
    
    func mapping(map: Map) {
        
    }
    
}

class NFTModel: BaseEntity{
    var id: Int?
    var fixed_price: String?
    var status: String?
    var score: String?
    var level: String?
    var profile: [KeyValueModel] =  [KeyValueModel]()
    
    
    override func mapping(map: Map) {
        self.id <- map["id"]
        self.fixed_price <- map["fixed_price"]
       
        self.profile <- map["properties"]
        
        self.status <- map["status"]
        
        self.profile.forEach { keyValue in
            if keyValue.key == "Score"  {
                self.score = keyValue.value
            }
            
            if keyValue.key == "Level"  {
                self.level = keyValue.value
            }
        }
    }
    
    func getPrice() -> Int {
        return Int(fixed_price&) ?? 0
    }
    
    func isActive() -> Bool {
        return self.status == "active"
    }
}



class DataNFTModel: BaseEntity{
    var total: Int?
    var listNFT: [NFTModel]?
    
    override func mapping(map: Map) {
        self.total <- map["total"]
        self.listNFT <- map["list"]
    }
}


class KeyValueModel: BaseEntity{
    var key: String?
    var value: String?
    
    override func mapping(map: Map) {
        self.key <- map["key"]
        self.value <- map["value"]
    }
}



