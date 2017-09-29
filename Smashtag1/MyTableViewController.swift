//
//  MyTableViewController.swift
//  Smashtag1
//
//  Created by Gai Carmi on 9/28/17.
//  Copyright © 2017 Gai Carmi. All rights reserved.
//

import UIKit
import Twitter

class MyTableViewController: UITableViewController, UITextFieldDelegate {

//    let list = ["milk","honey","fish","tomato","bread"]
    private var tweets = [Array<Twitter.Tweet>]() {
        didSet{
            //print(tweets)
        }
    }

    @IBOutlet weak var searchTextField: UITextField! {
        didSet{
            searchTextField.delegate = self
        }
    }
    
    
    // public part of our Model
    // when this is set
    // we'll reset our tweets Array
    // to reflect the result of fetching Tweets that match
    var searchText: String? {
        didSet {
            searchTextField?.text = searchText
            searchTextField?.resignFirstResponder() // when someone press search, hide the keyboard
            lastTwitterRequest = nil
            tweets.removeAll()
            tableView.reloadData()
            searchForTweets()
            title = searchText
        }
    }
    
    
    // we track this so that
    // a) we ignore tweets that come back from other than our last request
    // b) when we want to refresh, we only get tweets newer than our last request
    private var lastTwitterRequest: Twitter.Request?
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTextField {
            searchText = searchTextField.text
        }
        return true
    }
    
    
    // takes the searchText part of our Model
    // and fires off a fetch for matching Tweets
    // when they come back (if they're still relevant)
    // we update our tweets array
    // and then let the table view know that we added a section
    // (it will then call our UITableViewDataSource to get what it needs)
    private func searchForTweets() {
        // "lastTwitterRequest?.newer ??" was added after lecture for REFRESHING
        print("GGG - searchForTweets")
        if let request = lastTwitterRequest?.newer ?? twitterRequest() {
            lastTwitterRequest = request
            request.fetchTweets { [weak self] newTweets in      // this is off the main queue
                DispatchQueue.main.async {                      // so dispatch back to main queue
                    if request == self?.lastTwitterRequest {
                        self?.tweets.insert(newTweets, at:0)
                        self?.tableView.insertSections([0], with: .fade)
                    }
                    self?.refreshControl?.endRefreshing() // REFRESHING
                }
            }
        }else {
            self.refreshControl?.endRefreshing() // REFRESHING
        }
        
        
//        // "lastTwitterRequest?.newer ??" was added after lecture for REFRESHING
//        print("GGG - searchForTweets")
//        if let request = twitterRequest() {
//            lastTwitterRequest = request
//            request.fetchTweets { [weak self] newTweets in      // this is off the main queue
//                                     // so dispatch back to main queue
//                    if request == self?.lastTwitterRequest {
//                        self?.tweets.insert(newTweets, at:0)
//                    }
//                }
//
//        }
    }
    
    

    
    
    
    // MARK: Updating the Table
    // just creates a Twitter.Request
    // that finds tweets that match our searchText
    private func twitterRequest() -> Twitter.Request? {
        if let query = searchText, !query.isEmpty {
            return Twitter.Request(search: query, count: 100)
        }
        return nil
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableViewAutomaticDimension

        
//        // but use whatever autolayout says the height should be as the actual row height
//        self.tableView.rowHeight = UITableViewAutomaticDimension
//        // we use the row height in the storyboard as an "estimate"
//        self.tableView.estimatedRowHeight = tableView.rowHeight
        
        
        // the row height could alternatively be set
        // using the UITableViewDelegate method heightForRowAt
//        searchText = "#stanford"  //

    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        tableView.setNeedsLayout()
//        tableView.layoutIfNeeded()
//        tableView.reloadData()
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tweets.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        return list.count
        return tweets[section].count
    }

//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("raw \(indexPath.row) selected")
//    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
//        cell.textLabel?.text = list[indexPath.row]
        
        // Configure the cell...
        let tweet: Tweet = tweets[indexPath.section][indexPath.row]
//        cell.textLabel?.text = tweet.text
//        cell.detailTextLabel?.text = tweet.user.name
//        print("GGG \(tweet.text) ")
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }
        return (cell)
        
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
