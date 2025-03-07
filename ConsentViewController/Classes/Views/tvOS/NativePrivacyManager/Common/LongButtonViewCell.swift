//
//  LongButtonViewCell.swift
//  ConsentViewController-tvOS
//
//  Created by Andre Herculano on 25.06.21.
//

import UIKit

class LongButtonViewCell: UITableViewCell {
    var labelText: String?
    var isOn: Bool?
    var isCustom = false
    var onText: String?
    var offText: String?
    var customText: String?
    var selectable = false

    @IBOutlet var label: UILabel!
    @IBOutlet var customLabel: UILabel!
    @IBOutlet var stateLabel: UILabel!

//    override var isAccessibilityElement: Bool { set {} get { false }}
//    override var accessibilityElements: [Any]? { set {} get {[
//        label as Any,
//        customLabel as Any,
//        stateLabel as Any
//    ]}}

    func setup(from nativeCell: SPNativeLongButton?) {
        customText = isCustom ? nativeCell?.settings.customText : nil
        onText = nativeCell?.settings.onText ?? "On"
        offText = nativeCell?.settings.offText ?? "Off"
    }

    func loadUI() {
        label.text = labelText
        label.setDefaultTextColorForDarkMode()
        customLabel.setDefaultTextColorForDarkMode()
        stateLabel.setDefaultTextColorForDarkMode()
        if let customText = customText {
            customLabel.isHidden = false
            customLabel.text = customText
        } else {
            customLabel.isHidden = true
        }
        accessoryType = selectable ? .disclosureIndicator : .none
        if let isOn = isOn {
            stateLabel.isHidden = false
            stateLabel.text = isOn ? onText : offText
        } else {
            stateLabel.isHidden = true
        }
        accessibilityIdentifier = "\(labelText ?? "") \(stateLabel.text ?? "")"
    }

    override func prepareForReuse() {
        labelText = nil
        isOn = nil
        selectable = false
        loadUI()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        loadUI()
        selectionStyle = .none
    }
}
