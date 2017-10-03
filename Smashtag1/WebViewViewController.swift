//
//  WebViewViewController.swift
//  Smashtag1
//
//  Created by Gai Carmi on 10/3/17.
//  Copyright © 2017 Gai Carmi. All rights reserved.
//


import UIKit

class WebViewViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    var textUrl: String? {
        didSet{
            _ = self.view // nice trick to force the view populate his hirarchy
            updateUI()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.loadRequest(URLRequest(url: URL(string: "https://www.apple.com")!))
//        textUrl = " "
//        webView.delegate = self
//        self.navigationItem.setHidesBackButton(true, animated: false)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//        override func viewDidAppear(_ animated: Bool) {
//        }
    
    func updateUI() {
        if let urlText = textUrl, let url = URL(string: urlText) {
            //            let request = URLRequest(url: url)
            ////            if webView == nil {super.viewDidLoad() }
            //            webView?.loadRequest(request)
            
            let request = URLRequest(url: URL(string: "https://wordpress.com")! )
            //            if webView == nil {super.viewDidLoad() }
            webView?.loadRequest(request)
            
        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

