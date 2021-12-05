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
    @IBOutlet weak var highlightPrice: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var rangeDame: [String] = []
    
    var listNFTResult = [NFTModel]() {
        didSet {
            resultTableView.reloadData()
        }
    }
    
    var listOrigin = [NFTModel]()
    
    let maxPriceDropdown = DropDown()
    
    
    let rangeInt =  [Int](315...330)
    
    let filterRange = [Int](319...325)
    var filterDameSelected = 0
    
    
    let listErrorID = [1149820, 1150508, 1145376, 1146195]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()
        setUpDropDown()
        configureTableView()
        stopLoading()
        configureCollectionView()
    }
    
    private func configureTableView() {
        resultTableView.register(UINib(nibName: "ResultsCell", bundle: nil), forCellReuseIdentifier: "ResultsCell")
        resultTableView.dataSource = self
        resultTableView.rowHeight = UITableView.automaticDimension
    }
    
    private func configureCollectionView() {
        collectionView.register(UINib(nibName: "FilterCollectionCell", bundle: nil), forCellWithReuseIdentifier: "FilterCollectionCell")
        collectionView.dataSource = self
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 70, height: 40)
        collectionView.collectionViewLayout = layout
    }
    
    private func setUpDropDown() {
        minDameView.setTitle( "Lực chiến nhỏ nhất")
        maxDameView.setTitle("Lực chiến lớn nhất")
        searchDameView.setTitle("Lọc theo lực chiến")
        
        var range: [String] = []
        for dame in 315...330 {
            range.append("\(dame)")
        }
        rangeDame = range
        
        minDameView.itemSelected = 5
        minDameView.dataSource = rangeDame
        maxDameView.itemSelected = rangeDame.count - 1
        maxDameView.dataSource = rangeDame
        
        filterDameSelected = rangeDame[5].toInt()
        
        
        var rangeSearch = [String]()
        for dame in 315...330 {
            rangeSearch.append("\(dame)")
        }
        
        searchDameView.dataSource = rangeSearch
        
        maxPrice.text = UserDefaultHelper.shared.getInt(.maxPrice) == 0 ? "890" : "\(UserDefaultHelper.shared.getInt(.maxPrice))"
        minPrice.text = UserDefaultHelper.shared.getInt(.minPrice) == 0 ? "550" : "\(UserDefaultHelper.shared.getInt(.minPrice))"
        maxPriceYouWantBuy.text = UserDefaultHelper.shared.getInt(.wantBuyPrice) == 0 ? "600" : "\(UserDefaultHelper.shared.getInt(.wantBuyPrice))"
        highlightPrice.text = UserDefaultHelper.shared.getInt(.hightlightPrice) == 0 ? "600" : "\(UserDefaultHelper.shared.getInt(.hightlightPrice))"
        
        maxPrice.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        minPrice.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        maxPriceYouWantBuy.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        highlightPrice.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        searchDameView.dropDownCallBack = { [weak self] index, item in
            guard let self = self else { return }
            self.listNFTResult = self.listOrigin.filter({$0.score == item})
        }
        
        maxPriceDropdown.dataSource = ["800", "850", "900", "950", "1000", "1050"]
        maxPriceDropdown.anchorView = chooseMaxPrice
        maxPriceDropdown.bottomOffset = CGPoint(x: 0,
                                                y:(maxPriceDropdown.anchorView?.plainView.bounds.height)!)
        
        maxPriceDropdown.selectionAction = {[weak self] index, item in
            self?.maxPrice.text = item
            UserDefaultHelper.shared.setData(item.toInt(), key: .maxPrice)
        }
        
        minPrice.keyboardType = .numberPad
        maxPrice.keyboardType = .numberPad
        maxPriceYouWantBuy.keyboardType = .numberPad
        
    }
    
    private func startLoading() {
        indicatorView.startAnimating()
        indicatorView.isHidden = false
        findButton.isEnabled = false
        findButton.backgroundColor = .gray
    }
    
    private func stopLoading() {
        indicatorView.stopAnimating()
        indicatorView.isHidden = true
        findButton.isEnabled = true
        findButton.backgroundColor = .orange
    }
    
    @IBAction func chooseMaxPriceTapped() {
        maxPriceDropdown.show()
    }
    
    @IBAction func btnTim(_ sender: UIButton) {
        print("MIN DAME: \(minDameView.getContentInt())")
        print("MAX DAME: \(maxDameView.getContentInt())")
        print("MAX PRICE: \(maxPrice.getIntValue())")
        print("MIN PRICE: \(minPrice.getIntValue())")
        lbLoading.text = "Đợi xíu nhé...tìm đã. gấp gì, GOOD LUCK ^^."
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: {
            self.findButton.isEnabled = true
            self.findButton.backgroundColor = .orange
        })
        
        requestNFT { (listNft) -> Void in
            guard let listNft = listNft else {return}
            
            print("-----------------Tong số có : \(listNft.count) con -------------")
            
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
                                let kq = "Lực chiến: \(nftModel.score&), Level: \(nftModel.level&), Giá: \(nftModel.fixed_price&.currencyFormatting()), link:  \(linkBuy + nftModel.id&)"
                                print(kq)
                                if nftModel.getPrice() <= self.maxPriceYouWantBuy.text&.toInt()*1000 && count > 1 {
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
//                print("------------------------Bắt đầu danh sách----------------------")
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
                    
                    self.lbLoading.text = "Tìm quá nhiều bị chặn rồi, Đổi vpn lại nha!!"
                    self.stopLoading()
                    return
                }
                success(dataNft.listNFT?.filter({$0.getPrice() >= self.minPrice.getIntValue()*1000 &&
                    $0.getPrice() <= self.maxPrice.getIntValue()*1000
                    
                }).sorted(by: { (nft1, nft2) -> Bool in
                    return nft1.getPrice() <= nft2.getPrice()
                }))
            case .failure:
                self.lbLoading.text = "Lỗi rồi! Không load được pet. Thử lại nhé."
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
                    error()
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
        let highlight = listNFTResult[indexPath.row].getPrice() <= highlightPrice.text&.toInt()*1000
        cell.setData(listNFTResult[indexPath.row], highlight: highlight, index: indexPath.row + 1)
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

extension ViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterRange.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionCell", for: indexPath) as! FilterCollectionCell
        cell.setData(filterRange[indexPath.row], isSelected: self.filterDameSelected == filterRange[indexPath.row])
        cell.delegate = self
        return cell
    }
}

extension ViewController: FilterCollectionCellDelegate {
    func filterTapped(_ dame: Int) {
        self.filterDameSelected = dame
        self.listNFTResult = self.listOrigin.filter({$0.score == "\(dame)"})
        collectionView.reloadData()
    }
}

extension ViewController {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        switch textField {
        case minPrice:
            UserDefaultHelper.shared.setData(textField.text&.toInt(), key: .minPrice)
        case maxPrice:
            UserDefaultHelper.shared.setData(textField.text&.toInt(), key: .maxPrice)
        case maxPriceYouWantBuy:
            UserDefaultHelper.shared.setData(textField.text&.toInt(), key: .wantBuyPrice)
        case highlightPrice:
            UserDefaultHelper.shared.setData(textField.text&.toInt(), key: .hightlightPrice)
        default:
            break
        }
    }
}
