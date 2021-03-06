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
import DropDown

// https://market-api.radiocaca.com/nft-sales?pageNo=1&pageSize=20&sortBy=created_at&order=desc&name=&saleType&category=13&tokenType
//
typealias RequestSuccessListNFT = (_ listNFT: [NFTModel]?) -> Void
typealias RequestSuccessNFT = (_ nft : NFTModel) -> Void

let linkBuy = "https://market.radiocaca.com/#/market-place/"

extension UITextField {
    func getIntValue() -> Int {
        return Int(self.text&) ?? 0
    }
}

extension String {
    func toInt() -> Int {
        return Int(self) ?? 0
    }
}

//1149820

class ViewController: UIViewController {
    
    @IBOutlet weak var lbLoading: UILabel!
    @IBOutlet weak var minDameView: AppDropdown!
    @IBOutlet weak var maxDameView: AppDropdown!
    @IBOutlet weak var minPrice: UITextField!
    @IBOutlet weak var maxPrice: UITextField!
    
    @IBOutlet weak var searchDameView: AppDropdown!
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var chooseMaxPrice: UIButton!
    
    @IBOutlet weak var maxPriceYouWantBuy: UITextField!
    
    var rangeDame: [String] = []
    
    var listNFTResult = [NFTModel]() {
        didSet {
            resultTableView.reloadData()
        }
    }
    
    var listOrigin = [NFTModel]()
    
    let maxPriceDropdown = DropDown()
    
    
    let rangeInt =  [Int](315...330)
    
    
    let listErrorID = [1149820, 1150508, 1145376, 1146195]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()
        setUpDropDown()
        configureTableView()
        stopLoading()
    }
    
    private func configureTableView() {
        resultTableView.register(UINib(nibName: "ResultsCell", bundle: nil), forCellReuseIdentifier: "ResultsCell")
        resultTableView.dataSource = self
        resultTableView.rowHeight = UITableView.automaticDimension
    }
    
    private func setUpDropDown() {
        minDameView.setTitle( "MIN DAME")
        maxDameView.setTitle("MAX DAME")
        searchDameView.setTitle("SEARCH DAME")
        
        var range: [String] = []
        for dame in 315...330 {
            range.append("\(dame)")
        }
        rangeDame = range
        
        minDameView.itemSelected = 5
        minDameView.dataSource = rangeDame
        maxDameView.itemSelected = rangeDame.count - 1
        maxDameView.dataSource = rangeDame
        
        
        var rangeSearch = [String]()
        for dame in 320...330 {
            rangeSearch.append("\(dame)")
        }
        
        searchDameView.dataSource = rangeSearch
        
        maxPrice.text = "850000"
        minPrice.text = "655000"
        maxPriceYouWantBuy.text = "750000"
        
        searchDameView.dropDownCallBack = { [weak self] index, item in
            guard let self = self else { return }
            self.listNFTResult = self.listOrigin.filter({$0.score == item})
        }
        
        maxPriceDropdown.dataSource = ["750000", "800000", "850000", "900000"]
        maxPriceDropdown.anchorView = chooseMaxPrice
        maxPriceDropdown.bottomOffset = CGPoint(x: 0,
                                                y:(maxPriceDropdown.anchorView?.plainView.bounds.height)!)
        
        maxPriceDropdown.selectionAction = {[weak self] index, item in
            self?.maxPrice.text = item
        }
        
        minPrice.keyboardType = .numberPad
        maxPrice.keyboardType = .numberPad
        maxPriceYouWantBuy.keyboardType = .numberPad
        
    }
    
    private func startLoading() {
        indicatorView.startAnimating()
        indicatorView.isHidden = false
        findButton.isEnabled = false
    }
    
    private func stopLoading() {
        indicatorView.stopAnimating()
        indicatorView.isHidden = true
        findButton.isEnabled = true
    }
    
    @IBAction func chooseMaxPriceTapped() {
        maxPriceDropdown.show()
    }
    
    @IBAction func btnTim(_ sender: UIButton) {
        print("MIN DAME: \(minDameView.getContentInt())")
        print("MAX DAME: \(maxDameView.getContentInt())")
        print("MAX PRICE: \(maxPrice.getIntValue())")
        print("MIN PRICE: \(minPrice.getIntValue())")
        lbLoading.text = "?????i x??u nh??...pet ngon, pet ngon, GOOD LUCK ^^."
        findButton.setAnimationTouch()
        listNFTResult.removeAll()
        listOrigin.removeAll()
        timPetNao()
    }
    
    @IBAction func resortButtonTapped() {
        self.listNFTResult = self.listNFTResult.sorted(by: { (nft1, nft2) -> Bool in
            return nft1.getPrice() <= nft2.getPrice()
        })
    }
    
    private func checkNotError(_ Id: Int) -> Bool {
        return !listErrorID.contains(Id)
    }
    
    
    func timPetNao() {
        startLoading()
        requestNFT { (listNft) -> Void in
            guard let listNft = listNft else {return}
            
            print("-----------------Tong s??? c?? : \(listNft.count) con -------------")
            
            let dispatchGroup = DispatchGroup()
            
            var count = 0
            //Filter less than max price to get detail NFT
            for nftModel in listNft {
                dispatchGroup.enter()
                var stop = false
                
                self.requestDetailNFT(id: nftModel.id&) { nft in
                    dispatchGroup.leave()
                    self.lbLoading.text = "Loading \(count)/ \(listNft.count)"
                    
                    nft.profile.forEach { keyValue in
                        if keyValue.key == "Level" {
                            nftModel.level = keyValue.value
                        }
                        
                        if keyValue.key == "Score"
                            && keyValue.value&.toInt() >= self.minDameView.getContentInt()
                            && keyValue.value&.toInt() <= self.maxDameView.getContentInt()
                            && nftModel.isActive() && self.checkNotError(nftModel.id ?? 0) {
                                count =  count + 1
                                if count >= 50 {
                                    stop = true
                                    self.stopLoading()
                                    
                                }
                                nftModel.score = keyValue.value
                                let kq = "L???c chi???n: \(nftModel.score&), Level: \(nftModel.level&), Gi??: \(nftModel.fixed_price&.currencyFormatting()), link:  \(linkBuy + nftModel.id&)"
                                print(kq)
                                if nftModel.getPrice() <= self.maxPriceYouWantBuy.text&.toInt()  {
                                    guard let url = nftModel.getLinkMerket() else { return }
                                    stop = true
                                    UIApplication.shared.open(url)
                                }
                                
                                self.listNFTResult.append(nftModel)
                                self.listOrigin.append(nftModel)
                                self.resultTableView.reloadData()
                        }
                    }
                    
                } error: {
                    dispatchGroup.leave()
                    self.lbLoading.text = "Loading \(count)/ \(listNft.count)"
                }
                if stop {
                    self.stopLoading()
                    break
                }
            }
            //            }
            
            
            // end foreach
            dispatchGroup.notify(queue: DispatchQueue.main, execute: {
                self.stopLoading()
                self.listNFTResult =  self.listOrigin.sorted { (nft1, nft2) -> Bool in
                    return nft1.getPrice() < nft2.getPrice()
                }
                self.listOrigin = self.listNFTResult
                // xuat du lieu
                //                self.txtKQ.text = ""
//                print("------------------------B???t ?????u danh s??ch----------------------")
//                self.listNFTResult.forEach { nftModel in
//                    let kq = "Luc Chien: \(nftModel.score&), Level: \(nftModel.level&), Gia: \(nftModel.fixed_price&.currencyFormatting()), link:  \(linkBuy + nftModel.id&)"
//                    print(kq)
//
//                    //                    self.txtKQ.text = self.txtKQ.text& + "\n" + kq
//                }
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
                    
                    self.lbLoading.text = "T??m qu?? nhi???u b??? ch???n r???i, ?????i vpn l???i nha!!"
                    self.stopLoading()
                    return
                }
                success(dataNft.listNFT?.filter({$0.getPrice() >= self.minPrice.getIntValue() &&
                    $0.getPrice() <= self.maxPrice.getIntValue()
                    
                }).sorted(by: { (nft1, nft2) -> Bool in
                    return nft1.getPrice() <= nft2.getPrice()
                }))
            case .failure:
                self.lbLoading.text = "L???i r???i! Kh??ng load ???????c pet. Th??? l???i nh??."
                print("Can not load data")
                self.stopLoading()
            }
        }
    }
    
    
    
    func requestDetailNFT(id: String, success: @escaping RequestSuccessNFT, error: @escaping (()-> Void)) {
        let urlString = "https://market-api.radiocaca.com/nft-sales/" + id
        
        //let manager = Alamofire.SessionManager.default
        let request = AF.request(urlString, method: .get)
        request.responseData { (dataResponse) in
            switch dataResponse.result {
            case .success(let data):
                let json = JSON(data)
                
                guard let nftModel = Mapper<NFTModel>().map(JSONObject: json["data"].dictionaryObject) else {
                    print("Can not parser")
                    print(json)
                    return
                }
                
                success(nftModel)
            case .failure:
                error()
                print("Can not load data")
            }
            
            
        }
    }
    
    
}


extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listNFTResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultsCell", for: indexPath) as! ResultsCell
        cell.setData(listNFTResult[indexPath.row])
        cell.delegate = self
        return cell
    }
}

extension ViewController: ResultsCellDelegate {
    func sharedLink(_ detail: NFTModel) {
        let someText:String = "ID: \(detail.id&), Luc Chien: \(detail.score&), Level: \(detail.level&), Gia: \(detail.fixed_price&.currencyFormatting())"
        print("ID PET: \(detail.id&)")
        guard let objectsToShare:URL = detail.getLinkMerket() else { return }
        let sharedObjects:[AnyObject] = [objectsToShare as AnyObject,someText as AnyObject]
        let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
}


