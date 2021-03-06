//
//  AppDropdown.swift
//  DXG E-Office
//
//  Created by DINH VAN TIEN on 11/8/19.
//  Copyright © 2019 Lac Viet Corp. All rights reserved.
//

import UIKit
import DropDown

class AppDropdown: BaseViewXib {

    @IBOutlet weak var vTitle       : AppTitleLogo!
    @IBOutlet weak var lbContent    : UILabel!
    @IBOutlet weak var imgArrow     : UIImageView!
    @IBOutlet weak var vBottom      : UIView!
    @IBOutlet weak var actionButton : UIButton!

    let dropdown = DropDown()
    
    var itemSelected = 0

    var dropDownCallBack: ((_ index: Int, _ item: String) -> Void)?
    
    var dataSource: [String] = [] {
        didSet {
            if !self.dataSource.isEmpty {
                imgArrow.isHidden = false
                dropdown.dataSource = self.dataSource
                self.lbContent.text = itemSelected == -1 ? self.dataSource.first : self.dataSource[self.itemSelected]
                if itemSelected == -1 {
                    self.itemSelected = 0
                }
            }
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        configureDropDown()
    }
    
    func hideTextAndLogo(){
        vTitle.isHidden = true
    }
    
    func hideLineBottom(){
        vBottom.isHidden = true
    }

    func setTitle(_ title: String) {
        vTitle.setTitleAndLogo(title)
    }

    func configureDropDown() {
        self.setColor(UIColor.gray)
//        imgArrow.image = .green
        dropdown.anchorView = vBottom
        dropdown.bottomOffset = CGPoint(x: 0,
                                        y:(dropdown.anchorView?.plainView.bounds.height)!)
        
        if itemSelected != -1 {
            self.lbContent.text = self.dataSource[itemSelected]
        }
        
        dropdown.cellNib = UINib(nibName: "DropdownSelectedCell", bundle: nil)
        dropdown.customCellConfiguration = { (index: Index,
                                              item: String,
                                              cell: DropDownCell) -> Void in
            guard let cell = cell as? DropdownSelectedCell else { return }
           
            cell.title.text = self.dataSource[index].uppercased()
//            cell.img.image =  self.itemSelected == index
//                ? AppImage.selected
//                : AppImage.unselected
        }
        
        dropdown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self.itemSelected = index
            self.imgArrow.rotateView(0.0)
            self.setColor(UIColor.gray)
            self.lbContent.text = item
            self.dropDownCallBack?(index, item)
            self.dropdown.reloadAllComponents()
        }
        
        dropdown.willShowAction = { [weak self] in
            guard let self = self else { return }
            self.imgArrow.rotateView(.pi)
            self.setColor(UIColor.green)
        }

        dropdown.cancelAction = { [weak self] in
            guard let self = self else { return }
            self.imgArrow.rotateView(0.0)
            self.setColor(UIColor.green)
        }
    }
    
    func setItemSelected(index: Int) {
        lbContent.text = dataSource[index]
        self.itemSelected = index
    }

    private func setColor(_ color: UIColor) {
        self.vBottom.backgroundColor = color
    }
    
    func setBackGroundColor(_ color: UIColor) {
        self.view?.backgroundColor = color
    }
    
    func setTextColor(_ color: UIColor) {
        self.lbContent.textColor = color
    }

    @IBAction func btnDropdownTapped() {
        dropdown.show()
    }
    
    func getContentInt() -> Int {
        return Int(lbContent.text&) ?? 0
    }
}
