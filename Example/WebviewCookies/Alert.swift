//
//  Alert.swift
//  WebviewCookies
//
//  Created by Andre Herculano on 26.01.23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class Alert: UIAlertController {
    init(title: String, message: String) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
        self.message = message
        addAction(UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
