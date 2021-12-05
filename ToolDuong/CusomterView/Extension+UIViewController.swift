//
//  Extension+UIViewController.swift
//  ToolDuong
//
//  Created by Tien Dinh on 27/11/2021.
//

import Foundation
import UIKit

extension UIViewController {
    func hideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
        if let nav = self.navigationController {
            nav.view.endEditing(true)
        }
    }
}

