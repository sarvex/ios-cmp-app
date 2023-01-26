//
//  AuthenticatedWebView.swift
//  WebviewCookies
//
//  Created by Andre Herculano on 26.01.23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import WebKit

class AuthenticatedWebView: WKWebView, WKNavigationDelegate {
    weak var delegate: WebViewContainer?

    init(_ viewDelegate: UIViewController & WebViewContainer) {
        delegate = viewDelegate
        super.init(frame: CGRect(x: .zero, y: .zero, width: viewDelegate.view.frame.width, height: viewDelegate.view.frame.height / 2), configuration: WKWebViewConfiguration())
        navigationDelegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.getAuthId { [weak self] (authId, error) in
            self?.delegate?.onPageLoaded(authId, error)
        }
    }

    @discardableResult
    override func load(_ request: URLRequest) -> WKNavigation? {
        let session = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            let html = String(data: data!, encoding: .utf8)!
            DispatchQueue.main.async {
                self.loadHTMLString(html, baseURL: request.url)
            }
        }
        session.resume()
        return nil
    }
}

protocol WebViewContainer: AnyObject {
    func onPageLoaded(_ authId: String?, _ error: Error?)
}
