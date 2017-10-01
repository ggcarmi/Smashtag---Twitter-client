//
//  TweetTableViewCell.swift
//  Smashtag1
//
//  Created by Gai Carmi on 9/28/17.
//  Copyright © 2017 Gai Carmi. All rights reserved.
//


import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell
{
    // source tree test 2

    
    // outlets to the UI components in our Custom UITableViewCell
    
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetUserLabel: UILabel!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    
    // public API of this UITableViewCell subclass
    // each row in the table has its own instance of this class
    // and each instance will have its own tweet to show
    // as set by this var
    var tweet: Twitter.Tweet? { didSet { updateUI() } }
    
    // whenever our public API tweet is set
    // we just update our outlets using this method
    private func updateUI() {
        
        let tweetTextToHighlight = NSMutableAttributedString(string: tweet?.text ?? "" , attributes: [:])
        
        tweetTextToHighlight.addAttributes(name: NSForegroundColorAttributeName, value: UIColor.blue, wordsToGetTheirRanges: tweet!.hashtags)
        tweetTextToHighlight.addAttributes(name: NSForegroundColorAttributeName, value: UIColor.red, wordsToGetTheirRanges: tweet!.urls)
        tweetTextToHighlight.addAttributes(name: NSForegroundColorAttributeName, value: UIColor.green, wordsToGetTheirRanges: tweet!.userMentions)

        tweetTextLabel?.attributedText = tweetTextToHighlight // tweet body
//        tweetTextLabel?.text = tweet?.text // tweet body

        tweetUserLabel?.text = tweet?.user.description // tweet title-user
        
        // image
        if let profileImageURL = tweet?.user.profileImageURL {
            // FIXME: blocks main thread
            if let imageData = try? Data(contentsOf: profileImageURL) {
                tweetProfileImageView?.image = UIImage(data: imageData)
            }
        } else {
            tweetProfileImageView?.image = nil
        }
        
        // date created
        if let created = tweet?.created {
            let formatter = DateFormatter()
            if Date().timeIntervalSince(created) > 24*60*60 {
                formatter.dateStyle = .short
            } else {
                formatter.timeStyle = .short
            }
            tweetCreatedLabel?.text = formatter.string(from: created)
        } else {
            tweetCreatedLabel?.text = nil
        }
 
    }
    
}

// extention to highlight in color a string (by adding attribute ) - that is one  of the words that the array "words" contain
private extension NSMutableAttributedString {
    
    func addAttributes(name: String, value: Any,  wordsToGetTheirRanges words: [Mention]) {
        for word in words {
            self.addAttribute(name, value: value, range: word.nsrange)
        }
    }
}
