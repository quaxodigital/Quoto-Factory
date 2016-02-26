//
//  QuoteDetailViewController.swift
//  Quoto Factory
//
//  Created by Javid Sheikh on 26/02/2016.
//  Copyright © 2016 Javid Sheikh. All rights reserved.
//

import UIKit

class QuoteDetailViewController: UIViewController {
    
    var newQuoto: NewQuoto!
    
    var activityIndicator = UIActivityIndicatorView()

    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = self.newQuoto.quotoCategory.capitalizedString
        print(self.newQuoto.quotoCategory)
        getQuote(self.newQuoto.quotoCategory)
    }
    
    override func viewWillAppear(animated: Bool) {
//        self.quoteLabel.text = self.newQuoto.quotoQuote
//        self.authorLabel.text = self.newQuoto.quotoAuthor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func enableUI(enabled: Bool) {
        
        if !enabled {
            activityIndicator = UIActivityIndicatorView(frame: self.view.frame)
            activityIndicator.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = .Gray
            self.view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        } else {
            activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
        }
    }
    
    private func getQuote(category: String) {
        
        self.enableUI(false)
        
        var urlString: String
        
        if category == "random" {
            urlString = Constants.TheySaidSo.APIBaseURL + Constants.TheySaidSo.RandomExtension + "?" + Constants.TheySaidSo.APIKey
        } else {
            urlString = Constants.TheySaidSo.APIBaseURL + Constants.TheySaidSo.CategoryExtension + category + "&" + Constants.TheySaidSo.APIKey
        }
        
        let session = NSURLSession.sharedSession()
    
        let url = NSURL(string: urlString)!
    
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
        
            // if an error occurs, print it and re-enable the UI
            func displayError(error: String) {
                print(error)
                print("URL at time of error: \(url)")
            }
        
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
        
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
        
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
        
            // parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
        
            /* GUARD: Are the "photos" and "photo" keys in our result? */
            guard let contentsDictionary = parsedResult["contents"] as? [String:AnyObject] else {
                displayError("Cannot find keys 'contents' and 'quotes' in  (parsedResult)")
                return
            }
        
            guard let quote = contentsDictionary["quote"] as? String, author = contentsDictionary["author"] as? String else {
                displayError("Unable to find keys 'quote' and 'author' in quotesObject")
                return
            }
                    
            print(quote)
            print(author)
                    
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                self.enableUI(true)
                self.quoteLabel.text = quote
                self.authorLabel.text = author
        
            })
                
        }
        task.resume()
    
    }

    @IBAction func selectQuote(sender: UIButton) {
        self.newQuoto.quotoQuote = self.quoteLabel.text!
        self.newQuoto.quotoAuthor = self.authorLabel.text!
        self.performSegueWithIdentifier("segueToMainVC", sender: self)
    }

    @IBAction func getAnotherQuote(sender: UIButton) {
        getQuote(self.newQuoto.quotoCategory)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = segue.destinationViewController as! MainViewController
        controller.newQuoto = self.newQuoto
    }


}