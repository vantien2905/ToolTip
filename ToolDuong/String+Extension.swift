//
//  String+Extension.swift
//  ToolDuong
//
//  Created by Tien Dinh on 27/11/2021.
//

import Foundation



    // formatting text for currency textField

    extension String {
        // formatting text for currency textField
        func currencyFormatting() -> String {
            if let value = Double(self) {
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                formatter.maximumFractionDigits = 0
                formatter.minimumFractionDigits = 0
                if let str = formatter.string(for: value) {
                    return str
                }
            }
            return ""
        }
    }

