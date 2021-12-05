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
    
    var dame: Int = 0
    
    weak var delegate: FilterCollectionCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setData(_ index: Int) {
        dame = index
        titleLabel.text = "\(index)"
    }
    
    @IBAction func filterButtonTapped() {
        delegate?.filterTapped(dame)
    }

}
