//
//  ViewController.swift
//  Referendapartij
//
//  Created by Andrei Nechaev on 1/10/17.
//  Copyright © 2017 Andrei Nechaev. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {

    let DOMAIN = "referendapartij.nl"
    var webView: WKWebView!
    var request: URLRequest?
    var poolURL: URL = URL(string: "http://signup.referendapartij.nl")!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hue:0.541, saturation:0.899, brightness:0.545, alpha:1)
        let frame = CGRect(x: 0, y: 20, width: view.frame.width, height: view.frame.height-20)
        webView = WKWebView(frame: frame)
        
        webView.navigationDelegate = self
        
        self.request = URLRequest(url: poolURL)
        self.webView.load(self.request!)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.removeFromSuperview()
        view.addSubview(webView)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showAlert(error)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showAlert(error)
    }

    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("provisional navigation")
    }
    
    func showAlert(_ error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let exitAction = UIAlertAction(title: "Exit", style: .destructive) { _ in
            exit(12)
        }
        let reloadAction = UIAlertAction(title: "Reload", style: .default) { _ in
            DispatchQueue.main.async {
                self.webView.load(self.request!)
            }
        }
        
        alertController.addAction(exitAction)
        alertController.addAction(reloadAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        let resp = navigationResponse.response as! HTTPURLResponse
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: resp.allHeaderFields as! [String:String], for: resp.url!)
        
        for cookie in cookies {
            HTTPCookieStorage.shared.setCookie(cookie)
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        var navigationRequest = navigationAction.request
        let path = navigationRequest.url?.absoluteString
        guard let thePath = path else {
            decisionHandler(.cancel)
            return
        }
        print(thePath)
        switch thePath {
        case let p where p.contains(DOMAIN):
            decisionHandler(.allow)
                
        case let p where p.contains("accounts.google.com"):
            decisionHandler(.allow)
        default:
            guard let url = navigationRequest.url else {
                decisionHandler(.cancel)
                return
            }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [String: Any](), completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
            decisionHandler(.cancel)
        }
        
//        if let path = path, !(path.contains(poolURL.absoluteString)) {
//            let url = URL(string: path)!
//            if #available(iOS 10.0, *) {
//                UIApplication.shared.open(url, options: [String: Any](), completionHandler: nil)
//            } else {
//                UIApplication.shared.openURL(url)
//            }
//            decisionHandler(.cancel)
//            return
//        }
//        
//        decisionHandler(.allow)
//        webView.reload()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        
        coordinator.animate(alongsideTransition: { _ in
            let frame = CGRect(x: 0, y: 20, width: size.width, height: size.height-20)
            self.webView.frame = frame
        }, completion: nil)
    }

}

