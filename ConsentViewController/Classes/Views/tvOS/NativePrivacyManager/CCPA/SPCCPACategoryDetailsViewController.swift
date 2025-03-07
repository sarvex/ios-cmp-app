//
//  SPCCPACategoryDetailsViewController.swift
//  ConsentViewController-tvOS
//
//  Created by Vilas on 11/05/21.
//

import Foundation
import UIKit

class SPCCPACategoryDetailsViewController: SPNativeScreenViewController {
    weak var categoryManagerDelegate: CCPAPMConsentSnaptshot?

    var category: CCPACategory?
    var partners: [String] {
        ((category?.requiringConsentVendors ?? []) + (category?.legIntVendors ?? []))
            .map { $0.name }
            .reduce([]) { $0.contains($1) ? $0 : $0 + [$1] } // filter duplicates
    }
    var sections: [SPNativeText?] {
        [viewData.byId("VendorsHeader") as? SPNativeText]
    }
    let cellReuseIdentifier = "cell"

    @IBOutlet var header: SPPMHeader!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var onButton: SPAppleTVButton!
    @IBOutlet var offButton: SPAppleTVButton!
    @IBOutlet var actionsContainer: UIStackView!
    @IBOutlet var categoryDetailsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setHeader()
        loadTextView(forComponentId: "CategoryDescription", textView: descriptionTextView, text: category?.description)
        loadImage(forComponentId: "LogoImage", imageView: logoImageView)
        loadButton(forComponentId: "OnButton", button: onButton)
        loadButton(forComponentId: "OffButton", button: offButton)
        categoryDetailsTableView.allowsSelection = false
        categoryDetailsTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        categoryDetailsTableView.delegate = self
        categoryDetailsTableView.dataSource = self
    }

    @IBAction func onBackTap(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func onOnButtonTap(_ sender: Any) {
        if let category = category {
            categoryManagerDelegate?.onCategoryOn(category)
        }
        dismiss(animated: true)
    }

    @IBAction func onOffButtonTap(_ sender: Any) {
        if let category = category {
            categoryManagerDelegate?.onCategoryOff(category)
        }
        dismiss(animated: true)
    }

    func setHeader() {
        header.spBackButton = viewData.byId("BackButton") as? SPNativeButton
        header.spTitleText = viewData.byId("Header") as? SPNativeText
        header.titleLabel.text = category?.name
        header.onBackButtonTapped = { [weak self] in self?.dismiss(animated: true) }
    }

    override func setFocusGuides() {
        addFocusGuide(from: header.backButton, to: actionsContainer, direction: .bottomTop)
        addFocusGuide(from: header.backButton, to: categoryDetailsTableView, direction: .right)
        addFocusGuide(from: actionsContainer, to: categoryDetailsTableView, direction: .rightLeft)
    }
}

// MARK: UITableViewDataSource
extension SPCCPACategoryDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        label.text = "\(sections[section]?.settings.text ?? "Partners") (\(partners.count))"
        label.font = UIFont(from: sections[section]?.settings.style?.font)
        label.textColor = UIColor(hexString: sections[section]?.settings.style?.font?.color)
        return label
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        partners.count
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = (categoryDetailsTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell?) ?? UITableViewCell()
        cell.selectionStyle = .none
        cell.textLabel?.text = partners[indexPath.row]
        return cell
    }

    public func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        true
    }
}
