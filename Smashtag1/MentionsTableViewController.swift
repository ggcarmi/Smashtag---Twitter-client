//
//  MentionsTableViewController.swift
//  Smashtag1
//
//  Created by Gai Carmi on 10/1/17.
//  Copyright © 2017 Gai Carmi. All rights reserved.
//

import UIKit
import Twitter
class MentionsTableViewController: UITableViewController {

    /**********************  vars  **********************/

    // our model - 4 sections, for : images, hashtags, url's, user mentions
    // each section contain array of MentionElement ( wrapper for diffrent type of mentions/images )
    private var sections = [SingleSectionOfElements]()
    
    var tweet: Twitter.Tweet?{
        didSet{
            if let tweet = tweet {
                sections = createSections(tweet: tweet)
                tableView.reloadData()
            }
        }
    }
    
    
    /********************** internal structs **********************/
    
    
    enum MentionElement{
        case Url(String)
        case UserMention(String)
        case Hashtag(String)
        case Image(MediaItem)
    }
    
    struct Identifiers {
        static let imageIdentifier = "Image Identifier"
        static let mentionIdentifier = "Mention Identifier"
        static let showMentionIdentifier = "Show Mention"
        static let showImageIdentifier = "Show Image"
    }
    
    struct SingleSectionOfElements{
        var mentionsType: String
        var mentionsArray: [MentionElement]
    }
    
    
    
    /**********************  functions  **********************/

    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].mentionsArray.count
    }

    // build the cells - 2 cases - image or mention
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let mention = sections[indexPath.section].mentionsArray[indexPath.row]
        
        switch mention {
            
        case .Image(let mediaItem):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.imageIdentifier, for: indexPath)
            if let imageCell = cell as? ImageTableViewCell {
                imageCell.mediaItem = mediaItem
            }
            return cell
            
        case .Url(let keyword), .UserMention(let keyword), .Hashtag(let keyword):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.mentionIdentifier, for: indexPath)
            cell.textLabel?.text = keyword
            return cell
        }
        
    }
    
    // detemine which hight the cell should be accordinf the case: image/mention
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let mention = sections[indexPath.section].mentionsArray[indexPath.row]
        
        switch mention {
            
        case .Image(let mediaItem):
            return view.bounds.width / CGFloat(mediaItem.aspectRatio)
            
        case .Hashtag, .Url, .UserMention:
            return UITableViewAutomaticDimension
        }
        
    }

    // title for section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].mentionsType
    }


    // MARK: - Navigation

    // task 5
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        guard let identifier = segue.identifier else {return}
        
        if identifier == Identifiers.showMentionIdentifier {
            if let tweetTableViewController = segue.destination.contents as? TweetTableViewController, let senderCell = sender as? UITableViewCell {
            
                if let newMentionKeyword = senderCell.textLabel?.text {
                    tweetTableViewController.searchText = newMentionKeyword
                }
            }
        }
        
        else if identifier == Identifiers.showImageIdentifier {
            if let imageViewController = segue.destination.contents as? ImageViewController,
                let senderCell = sender as? ImageTableViewCell {
                
                    DispatchQueue.main.async {
                        imageViewController.spinner.startAnimating()
                    }
                    imageViewController.imageURL = senderCell.mediaItem?.url
                }
        }
        
    }
    
    // task 6
    // we will use this func to handle the case the user click on Url
    // if its url - ofen safary, else perporm segue (prepare)
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == Identifiers.showMentionIdentifier {
            
            if let senderCell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: senderCell),
            sections[indexPath.section].mentionsType == "Url's" {
                
                guard let url = URL(string: senderCell.textLabel?.text ?? "") else { return false}
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
                
                return false
            }else{
                return true
            }
        }else{
            // image case
            return true
        }
    }
 

    

    
    
    // need to refactor , itterate the enum
    func createSections(tweet: Twitter.Tweet) -> [SingleSectionOfElements] {
        
        var sections = [SingleSectionOfElements]()
        
        if tweet.media.count > 0 {
            var images = [MentionElement]()
            
            for mediaItem in tweet.media{
                images.append(MentionElement.Image(mediaItem))
            }
            
            sections.append(SingleSectionOfElements(mentionsType: "Images", mentionsArray: images))
        }
        
        if tweet.hashtags.count > 0{
            var hashtags = [MentionElement]()
            
            for hashtagItem in tweet.hashtags {
                hashtags.append(MentionElement.Hashtag( hashtagItem.keyword ))
            }
            
            sections.append(SingleSectionOfElements(mentionsType: "Hashtags", mentionsArray: hashtags ))
        }
        
        
        if tweet.urls.count > 0 {
            var urls = [MentionElement]()
            
            for url in tweet.urls {
                urls.append(MentionElement.Url(url.keyword))
            }
            
            sections.append(SingleSectionOfElements(mentionsType: "Url's", mentionsArray: urls ))
        }
        
//        if tweet.userMentions.count > 0 {
//            var userMentions = [MentionElement]()
//
//            for userMention in tweet.userMentions {
//                userMentions.append(MentionElement.UserMention(userMention.keyword))
//            }
//
//            var userItselfMention = "@"
//            userItselfMention += tweet.user.screenName
//            userMentions.append(MentionElement.UserMention(userItselfMention))
//
//            sections.append(SingleSectionOfElements(mentionsType: "User Mentions", mentionsArray: userMentions ))
//        }else{
//            // if the section of user mention empty - we still want to add the user itself as user mention
//            var userItselfMention = "@"
//            userItselfMention += tweet.user.screenName
//            userMentions.append(MentionElement.UserMention(userItselfMention))
//
//            sections.append(SingleSectionOfElements(mentionsType: "User Mentions", mentionsArray: userMentions ))
//        }
        
        var userMentions = [MentionElement]()
        
        var userItselfMention = "@"
        userItselfMention += tweet.user.screenName
        userMentions.append(MentionElement.UserMention(userItselfMention))
        
        if tweet.userMentions.count > 0 {
            for userMention in tweet.userMentions {
                userMentions.append(MentionElement.UserMention(userMention.keyword))
            }
        }
        
        sections.append(SingleSectionOfElements(mentionsType: "User Mentions", mentionsArray: userMentions ))

        
        return sections
        
    }
}





