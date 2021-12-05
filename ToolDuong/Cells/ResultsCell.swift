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
    @IBOutlet weak var indexLabel: UILabel!
    
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
    
    func setData(_ detail: NFTModel, highlight: Bool = false, index: Int) {
        self.detail = detail
        linkLabel.text = "\(linkBuy + detail.id&)"
        dameLabel.text = "Lực chiến: \(detail.score&), Level: \(detail.level&), Gía: \(detail.fixed_price&.currencyFormatting())"
        backgroundColor = highlight ? UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1) : .white
        indexLabel.text = "\(index)"
    }
    
    @IBAction func sharedButtonTapped() {
        delegate?.sharedLink(detail)
    }
    
    @IBAction func linkButtonTapped() {
        guard let url = detail.getLinkMerket() else { return }
        UIApplication.shared.open(url)
    }
    
}
