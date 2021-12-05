//
//  FilterCollectionCell.swift
//  ToolDuong
//
//  Created by Tien Dinh on 05/12/2021.
//

import UIKit

protocol FilterCollectionCellDelegate: AnyObject {
    func filterTapped(_ dame: Int)
}

class FilterCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    var dame: Int = 0
    
    weak var delegate: FilterCollectionCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setData(_ index: Int, isSelected: Bool) {
        dame = index
        titleLabel.text = "\(index)"
        bgView.backgroundColor = isSelected ? .orange : .lightGray
    }
    
    @IBAction func filterButtonTapped() {
        delegate?.filterTapped(dame)
    }

}
