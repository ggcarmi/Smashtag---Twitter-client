//
//  ImageViewController.swift
//  Smashtag1
//
//  Created by Gai Carmi on 10/2/17.
//  Copyright © 2017 Gai Carmi. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate{
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            // to zoom we have to handle viewForZooming(in scrollView:)
            scrollView.delegate = self
            // and we must set our minimum and maximum zoom scale
            scrollView.minimumZoomScale = 0.03
            scrollView.maximumZoomScale = 3.0
            // most important thing to set in UIScrollView is contentSize
            scrollView.contentSize = imageView.frame.size
            scrollView.addSubview(imageView)
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    fileprivate var imageView = UIImageView()
    
    // convenience computed property
    // lets us get involved every time we set an image in imageView
    // we can do things like resize the imageView,
    //   set the scroll view's contentSize,
    //   and stop the spinner
    private var image: UIImage? {
        get { return imageView.image }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            // careful here because scrollView might be nil
            // (for example, if we're setting our image as part of a prepare)
            // so use optional chaining to do nothing
            // if our scrollView outlet has not yet been set
            scrollView?.contentSize = imageView.frame.size
            // now that we've set an image
            // stop any spinner that exists from spinning
            spinner?.stopAnimating()
        }
    }
    
    // our Model
    // publicly settable
    // when it changes (but only if we are on screen)
    //   we'll fetch the image from the imageURL
    // if we're off screen when this happens (view.window == nil)
    //   viewWillAppear will get it for us later
    var imageURL: URL? {
        didSet {
            image = nil
            if view.window != nil {
                fetchImage()
            }
        }
    }
    
    // put our imageView into the view hierarchy
    // as a subview of the scrollView
    // (will install it into the content area of the scroll view)
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
    }
    
    // for efficiency, we will only actually fetch the image
    // when we know we are going to be on screen
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil {
            fetchImage()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UIScrollViewDelegate method
    // required for zooming
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//            if UIDevice.current.orientation.isLandscape {
//                print("Landscape")
//                image = imageView.image
//            } else {
//                print("Portrait")
//                image = imageView.image
//            }
//    }


    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // fetches the image at imageURL
    // does so off the main thread
    // then puts a closure back on the main queue
    //   to handle putting the image in the UI
    //   (since we aren't allowed to do UI anywhere but main queue)
    private func fetchImage() {
        if let url = imageURL {
            // we're going to start something on another queue soon
            // so let's start a spinner going in the UI to let the user know
            // we'll stop this any time an image actually gets set
            // (we'd never want the spinner and an image appearing at the same time!)
            spinner.startAnimating()
            // try? Data(contentsOf:) blocks the thread it is on
            // we are currently on the main thread
            // so we must dispatch that call off to a background queue
            // we'll use one of the shared, global, concurrent background queues
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let urlContents = try? Data(contentsOf: url)
                // now that we're back from blocking
                // are we still even interested in this url (i.e. does it == self.imageURL)?
                if let imageData = urlContents, url == self?.imageURL {
                    // now we want to set the image in the UI
                    // but we are not on the main thread right now
                    // so we are not allowed to do UI
                    // no problem: just dispatch the UI stuff back to the main queue
                    DispatchQueue.main.async {
                        self?.image = UIImage(data: imageData)
                    }
                }
            }
        }
    }
    
}


