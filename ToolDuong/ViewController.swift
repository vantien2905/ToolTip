//
//  ViewController.swift
//  ToolDuong
//
//  Created by Tien Dinh on 26/11/2021.
//

import UIKit
import Alamofire
import SwiftyJSON
import ObjectMapper

// https://market-api.radiocaca.com/nft-sales?pageNo=1&pageSize=20&sortBy=created_at&order=desc&name=&saleType&category=13&tokenType
//
typealias RequestSuccessListNFT = (_ listNFT: [NFTModel]?) -> Void
typealias RequestSuccessNFT = (_ nft : NFTModel) -> Void

let linkBuy = "https://market.radiocaca.com/#/market-place/"

class ViewController: UIViewController {
    
    @IBOutlet weak var txtScore: UITextField!
    @IBOutlet weak var lbLoading: UILabel!
    @IBOutlet weak var txtKQ: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        txtScore.text = "325"
     
    }
    
    @IBAction func btnTim(_ sender: UIButton) {
        lbLoading.text = "Bắt đầu tìm kiếm vui lòng đợi"
        timPetNao(id: txtScore.text&)
    }
    
    func timPetNao(id: String) {
       requestNFT { (listNft) -> Void in
           guard let listNft = listNft else {return}
           
           print("-----------------Tong số có : \(listNft.count) con -------------")
           let dispatchGroup = DispatchGroup()
           var listNFTResult = [NFTModel]()
           
        var count = 0
           listNft.forEach { nftModel in
               dispatchGroup.enter()
            self.requestDetailNFT(id: nftModel.id&) { nft in
                       dispatchGroup.leave()
                count =  count + 1
                self.lbLoading.text = "Loading \(count)/ \(listNft.count)"
                        
                       nft.profile.forEach { keyValue in
                        if keyValue.key == "Level" {
                            nftModel.level = keyValue.value
                        }
                        
                        if keyValue.key == "Score" && keyValue.value == self.txtScore.text&  && nftModel.isActive() {
                            nftModel.score = keyValue.value
                            let kq = "Luc Chien: \(nftModel.score&), Level: \(nftModel.level&), Gia: \(nftModel.fixed_price&.currencyFormatting()), link:  \(linkBuy + nftModel.id&)"
                               print(kq)
                            listNFTResult.append(nftModel)
                           }
                       }
                   }
           }
           
           // end foreach
           dispatchGroup.notify(queue: DispatchQueue.main, execute: {
               listNFTResult =  listNFTResult.sorted { (nft1, nft2) -> Bool in
                   return nft1.getPrice() < nft2.getPrice()
               }
               
               // xuat du lieu
            self.txtKQ.text = ""
            print("------------------------Bắt đầu danh sách----------------------")
               listNFTResult.forEach { nftModel in
                let kq = "Luc Chien: \(nftModel.score&), Level: \(nftModel.level&), Gia: \(nftModel.fixed_price&.currencyFormatting()), link:  \(linkBuy + nftModel.id&)"
                   print(kq)
                
                self.txtKQ.text = self.txtKQ.text& + "\n" + kq
               }
           })
       }
   }
    
    func requestNFT(success: @escaping RequestSuccessListNFT) {
       // let urlString = "https://market-api.radiocaca.com/nft-sales?pageNo=1&pageSize=2000&sortBy=created_at&order=desc&name=&saleType&category=13"
        let urlString = "https://market-api.radiocaca.com/nft-sales?pageNo=1&pageSize=2000&sortBy=single_price&name=&order=asc&saleType&category=13&tokenType"
               //let manager = Alamofire.SessionManager.default
        
        let request = AF.request(urlString, method: .get)
        request.responseData { (dataResponse) in
            switch dataResponse.result {
            case .success(let data):
                let json = JSON(data)
                guard let dataNft = Mapper<DataNFTModel>().map(JSONObject: json.dictionaryObject) else {
                    print("*********Can not parser**************")
                   // print(String(data: data, encoding: .utf8))
                    print("*********Can not parser**************")
                    
                    self.lbLoading.text = "Tìm quá nhiều bị chặn, đợi tầm 5-10 phút tìm lại"
                    
                    return
                }
                success(dataNft.listNFT?.sorted(by: { (nft1, nft2) -> Bool in
                    return nft1.fixed_price& <= nft2.fixed_price&
                }))
            case .failure:
               print("Can not load data")
            }
            
          
        }
    }



    func requestDetailNFT(id: String, success: @escaping RequestSuccessNFT) {
        let urlString = "https://market-api.radiocaca.com/nft-sales/" + id
            
               //let manager = Alamofire.SessionManager.default
        let request = AF.request(urlString, method: .get)
        request.responseData { (dataResponse) in
            switch dataResponse.result {
            case .success(let data):
                let json = JSON(data)
               
                guard let nftModel = Mapper<NFTModel>().map(JSONObject: json["data"].dictionaryObject) else {
                    print("Can not parser")
                    return
                }
                
                success(nftModel)
            case .failure:
               print("Can not load data")
            }
            
          
        }
    }


}





