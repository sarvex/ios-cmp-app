//
//  ViewController.swift
//  webviewcookies
//
//  Created by Andre Herculano on 25.01.23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import ConsentViewController
import WebKit

class ViewController: UIViewController, WebViewContainer, SPDelegate {
    @IBAction func ShowNetworkRequestsPress(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "wormholy_fire"), object: nil)
    }

    @IBOutlet weak var authIdLabel: UILabel!

    @IBAction func loadPrivacyManagerPress(_ sender: Any) {
        consentManager.loadCCPAPrivacyManager(withId: "757450")
    }

    var url = URLRequest(url: URL(string: "https://www.cgmaurer.com/sourcepoint/webview.html")!)
    var myAuthId = "andre-26.01.23-1406" // uuid 174d7c82-a56d-4ef5-ad3b-7f2c1934bdd9

    lazy var webview: AuthenticatedWebView = {
        let webview = AuthenticatedWebView(self)
        webview.setConsentFor(authId: myAuthId)
        webview.load(url)
        return webview
    }()

    lazy var consentManager: SPSDK = { SPConsentManager(
        accountId: 155,
        propertyName: try! SPPropertyName("test.webview"),
        campaigns: SPCampaigns(ccpa: SPCampaign()),
        delegate: self
    )}()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webview)
        consentManager.loadMessage(forAuthId: myAuthId)
    }

    func onConsentReady(userData: SPUserData) {
        print("onConsentReady:", userData)
        webview.reload()
    }

    func onPageLoaded(_ authId: String?, _ error: Error?) {
        if let authId = authId, !authId.isEmpty {
            authIdLabel.text = "authId cookie: \(authId)"
            authIdLabel.textColor = .systemGray
        } else {
            authIdLabel.text = "authId cookie not found."
            authIdLabel.textColor = .systemRed
        }
    }
}

extension ViewController {
    func onSPUIReady(_ controller: UIViewController) {
        present(controller, animated: true)
    }

    func onSPUIFinished(_ controller: UIViewController) {
        controller.dismiss(animated: true)
    }

    func onAction(_ action: ConsentViewController.SPAction, from controller: UIViewController) {
        print("onAction:", action)
    }

    func onError(error: SPError) {
        print("Something went wrong:", error.failureReason)
    }
}
