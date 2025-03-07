//
//  SPGDPRVendorDetailsViewController.swift
//  ConsentViewController-tvOS
//
//  Created by Vilas on 11/05/21.
//

import Foundation
import UIKit

class SPGDPRVendorDetailsViewController: SPNativeScreenViewController {
    struct Section {
        let header: SPNativeText?
        let content: [String]

        init? (header: SPNativeText?, content: [String]?) {
            if content == nil || content?.isEmpty == true { return nil }
            self.header = header
            self.content = content! // swiftlint:disable:this force_unwrapping
        }
    }

    weak var vendorManagerDelegate: GDPRPMConsentSnaptshot?

    let cellReuseIdentifier = "cell"
    var vendor: GDPRVendor?
    var sections: [Section] {[
        Section(header: viewData.byId("PurposesText") as? SPNativeText, content: vendor?.consentCategories.map { $0.name }),
        Section(header: viewData.byId("SpecialPurposesText") as? SPNativeText, content: vendor?.iabSpecialPurposes),
        Section(header: viewData.byId("FeaturesText") as? SPNativeText, content: vendor?.iabFeatures),
        Section(header: viewData.byId("SpecialFeaturesText") as? SPNativeText, content: vendor?.iabSpecialFeatures)
    ].compactMap { $0 }}

    @IBOutlet var headerView: SPPMHeader!
    @IBOutlet var qrCodeImageView: UIImageView!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var onButton: SPAppleTVButton!
    @IBOutlet var offButton: SPAppleTVButton!
    @IBOutlet var vendorDetailsTableView: UITableView!
    @IBOutlet var actionsContainer: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setHeader()
        loadTextView(forComponentId: "VendorDescription", textView: descriptionTextView, text: vendor?.description)
        loadButton(forComponentId: "OnButton", button: onButton)
        loadButton(forComponentId: "OffButton", button: offButton)
        if let vendorUrl = vendor?.policyUrl?.absoluteString {
            qrCodeImageView.image = QRCode(from: vendorUrl)
            qrCodeImageView.isHidden = qrCodeImageView.image == nil
        }
        vendorDetailsTableView.allowsSelection = false
        vendorDetailsTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        vendorDetailsTableView.delegate = self
        vendorDetailsTableView.dataSource = self
    }

    @IBAction func onOnButtonTap(_ sender: Any) {
        if let vendor = vendor {
            vendorManagerDelegate?.onVendorOn(vendor)
        }
        dismiss(animated: true)
    }

    @IBAction func onOffButtonTap(_ sender: Any) {
        if let vendor = vendor {
            vendorManagerDelegate?.onVendorOff(vendor)
        }
        dismiss(animated: true)
    }

    func setHeader () {
        headerView.spBackButton = viewData.byId("BackButton") as? SPNativeButton
        headerView.spTitleText = viewData.byId("Header") as? SPNativeText
        headerView.titleLabel.text = vendor?.name
        headerView.onBackButtonTapped = { [weak self] in self?.dismiss(animated: true) }
    }

    override func setFocusGuides() {
        addFocusGuide(from: headerView.backButton, to: actionsContainer, direction: .bottomTop)
        addFocusGuide(from: headerView.backButton, to: vendorDetailsTableView, direction: .right)
        addFocusGuide(from: actionsContainer, to: vendorDetailsTableView, direction: .rightLeft)
    }
}

// MARK: UITableViewDataSource
extension SPGDPRVendorDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        label.text = sections[section].header?.settings.text
        label.font = UIFont(from: sections[section].header?.settings.style?.font)
        label.textColor = UIColor(hexString: sections[section].header?.settings.style?.font?.color)
        return label
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].content.count
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = (vendorDetailsTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell?) ?? UITableViewCell()
        cell.textLabel?.text = sections[indexPath.section].content[indexPath.row]
        cell.textLabel?.setDefaultTextColorForDarkMode()
        return cell
    }

    public func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        true
    }
}
