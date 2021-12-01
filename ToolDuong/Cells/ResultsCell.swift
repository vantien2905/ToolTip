//
//  ResultsCell.swift
//  ToolDuong
//
//  Created by Tien Dinh on 27/11/2021.
//

import UIKit

protocol ResultsCellDelegate: AnyObject {
    func sharedLink(_ detail: NFTModel)
}

class ResultsCell: UITableViewCell {
    
    @IBOutlet weak var dameLabel: UILabel!
    @IBOutlet weak var linkLabel: UILabel!
    
    var detail: NFTModel!
    
    weak var delegate: ResultsCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        selectionStyle = .none
    }
    
    func setData(_ detail: NFTModel) {
        self.detail = detail
        linkLabel.text = "\(linkBuy + detail.id&)"
        dameLabel.text = "Luc Chien: \(detail.score&), Level: \(detail.level&), Gia: \(detail.fixed_price&.currencyFormatting())"
    }
    
    @IBAction func sharedButtonTapped() {
        delegate?.sharedLink(detail)
    }
    
    @IBAction func linkButtonTapped() {
        guard let url = detail.getLinkMerket() else { return }
        UIApplication.shared.open(url)
    }
    
}
