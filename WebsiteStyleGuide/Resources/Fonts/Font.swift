//
//  Font.swift
//  WebsiteStyleGuide
//
//  Created by Pavel Shabliy on 05.11.2024.
//

import UIKit

enum FontSizes {
    case hiding
    case body1
    case body2
    case body3

    var size: CGFloat {
        switch self {
        case .hiding:
            return 20
        case .body1:
            return 16
        case .body2:
            return 18
        case .body3:
            return 14
        }
    }
}

extension UIFont {
    static func nunitoSansRegular(_ size: FontSizes) -> UIFont {
        return UIFont(name: "NunitoSans-12ptExtraLight_Regular", size: size.size) ?? .systemFont(ofSize: size.size)
    }
}
