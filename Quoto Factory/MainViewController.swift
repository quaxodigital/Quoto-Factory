//
//  MainViewController.swift
//  Quoto Factory
//
//  Created by Javid Sheikh on 23/02/2016.
//  Copyright © 2016 Javid Sheikh. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: variables
    var newQuoto: NewQuoto!
    
    var chosenQuoteLabel: UILabel!
    var topConstraint: NSLayoutConstraint!
    var bottomConstraint: NSLayoutConstraint!
    var trailingConstraint: NSLayoutConstraint!
    var leadingConstraint: NSLayoutConstraint!
    var constraints: [NSLayoutConstraint]!
    var quoteLabelPosition: CGPoint!
    var quoteLabelFontSize: CGFloat!
    
    var isWhite = true

    var topConstraintConstant: CGFloat!
    var bottomConstraintConstant: CGFloat!
    var trailingConstraintConstant: CGFloat!
    var leadingConstraintConstant: CGFloat!
    
    // Rate me variables
    var minSessions = 5
    var tryAgainSessions = 3
    
    // MARK: IBOutlets
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var instructionLabelMiddle: UILabel!
    
    @IBOutlet weak var chosenImageView: UIImageView!
    @IBOutlet weak var labelSubview: UIView!
    
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIToolbar!
    
    @IBOutlet weak var chooseQuoteButton: UIButton!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI setup
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 242/255, green: 46/255, blue: 70/255, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Futura-CondensedExtraBold", size: 24)!]
        
        self.toolbar.barTintColor = UIColor(red: 242/255, green: 46/255, blue: 70/255, alpha: 1.0)
        self.toolbar.tintColor = UIColor.whiteColor()
        
        self.instructionLabelMiddle.layer.masksToBounds = true
        self.instructionLabelMiddle.layer.cornerRadius = 12
        
        // Chosen quote label
        self.chosenQuoteLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.labelSubview.bounds.width - 100, height: self.labelSubview.bounds.height - 100))
        self.chosenQuoteLabel.textAlignment = .Center
        self.chosenQuoteLabel.numberOfLines = 0
        self.chosenQuoteLabel.translatesAutoresizingMaskIntoConstraints = false
        self.labelSubview.addSubview(chosenQuoteLabel)
        // Constraints
        self.topConstraintConstant = 0
        self.bottomConstraintConstant = 0
        self.trailingConstraintConstant = 0
        self.leadingConstraintConstant = 0
        self.topConstraint = NSLayoutConstraint(item: chosenQuoteLabel, attribute: .Top, relatedBy: .Equal, toItem: self.labelSubview, attribute: .TopMargin, multiplier: 1, constant: topConstraintConstant)
        self.bottomConstraint = NSLayoutConstraint(item: chosenQuoteLabel, attribute: .Bottom    , relatedBy: .Equal, toItem: self.labelSubview, attribute: .BottomMargin, multiplier: 1, constant: bottomConstraintConstant)
        self.trailingConstraint = NSLayoutConstraint(item: chosenQuoteLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self.labelSubview, attribute: .TrailingMargin, multiplier: 1, constant: trailingConstraintConstant)
        self.leadingConstraint = NSLayoutConstraint(item: chosenQuoteLabel, attribute: .Leading, relatedBy: .Equal, toItem: self.labelSubview, attribute: .LeadingMargin, multiplier: 1, constant: leadingConstraintConstant)
        self.constraints = [topConstraint, bottomConstraint, trailingConstraint, leadingConstraint]
        self.labelSubview.addConstraints(constraints)
        
        // Text attributes
        self.chosenQuoteLabel.font = UIFont(name: "GillSans-Bold", size: 22)
        self.chosenQuoteLabel.textColor = UIColor.whiteColor()
        self.chosenQuoteLabel.layer.shadowColor = UIColor.blackColor().CGColor
        self.chosenQuoteLabel.layer.shadowRadius = 1
        self.chosenQuoteLabel.layer.shadowOffset = CGSizeMake(2, 2)
        self.chosenQuoteLabel.layer.shadowOpacity = 1
        
        // Gesture recognizers
        let gestureQuote = UIPanGestureRecognizer(target: self, action: #selector(MainViewController.dragQuoteLabel(_:)))
        self.chosenQuoteLabel.addGestureRecognizer(gestureQuote)
        self.chosenQuoteLabel.userInteractionEnabled = true
        
        self.quoteLabelPosition = CGPointMake(self.view.bounds.width / 2, self.view.bounds.height / 2)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(MainViewController.resizeText(_:)))
        self.view.addGestureRecognizer(pinchGesture)
        
        self.quoteLabelFontSize = 22
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(MainViewController.changeQuoteFontColor(_:)))
        longPress.minimumPressDuration = 1.2
        self.view.addGestureRecognizer(longPress)

    }
    
    override func viewWillAppear(animated: Bool) {
        
        // Set image and quote if chosen
        if self.newQuoto == nil {
            self.chosenQuoteLabel.hidden = true
            self.instructionLabelMiddle.alpha = 0
        } else {
            self.chosenImageView.image = self.newQuoto.quotoImage
            
            self.chosenQuoteLabel.hidden = false
            self.chosenQuoteLabel.text = self.newQuoto.quotoQuote + self.newQuoto.quotoAuthor
            
            self.instructionLabelMiddle.alpha = 1
        }
        
        // Disable camera button if camera not available
        self.cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        
        // Disable share button if no image is selected
        if self.chosenImageView.image == UIImage(named: "Placeholder.png") {
            self.actionButton.enabled = false
        } else {
            self.actionButton.enabled = true
        }
        
        if self.chosenQuoteLabel.text == nil && self.chosenImageView.image
            == UIImage(named: "Placeholder.png") {
            self.cancelButton.enabled = false
        } else {
            self.cancelButton.enabled = true
        }
                
        // Hide instruction labels
        UIView.animateWithDuration(2, delay: 6, options: .CurveLinear, animations: { () -> Void in
            self.instructionLabelMiddle.alpha = 0
            }, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Image picker delegate methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        guard let image = image as? UIImage else {
            print("Unable to select chosen image")
            return
        }
        self.chosenImageView.image = image
        if self.newQuoto == nil {
            newQuoto = NewQuoto(quotoImage: image, quotoQuote: "", quotoAuthor: "", quotoCategory: "")
        } else {
            self.newQuoto.quotoImage = image
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = segue.destinationViewController as! QuoteViewController
        if self.newQuoto == nil {
            self.newQuoto = NewQuoto(quotoImage: UIImage(named: "Placeholder.png")!, quotoQuote: "", quotoAuthor: "", quotoCategory: "")
        }
        controller.newQuoto = self.newQuoto
    }
    
    // MARK: generate quoto function
    private func generateQuoto() -> UIImage {
        self.navigationController?.navigationBarHidden = true
        self.toolbar.hidden = true
        self.instructionLabelMiddle.hidden = true
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let quoto: UIImage = UIGraphicsGetImageFromCurrentImageContext()
                
        self.navigationController?.navigationBarHidden = false
        self.toolbar.hidden = false
        self.instructionLabelMiddle.hidden = false
        
        return quoto
    }
    
    // MARK: gesture recognizer functions
    func dragQuoteLabel(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translationInView(self.view)
        let label = self.chosenQuoteLabel
        label.center = CGPointMake(self.quoteLabelPosition.x + translation.x, self.quoteLabelPosition.y + translation.y)
        
        if gesture.state == .Ended {
            self.quoteLabelPosition = CGPointMake(self.quoteLabelPosition.x + translation.x, self.quoteLabelPosition.y + translation.y)

            self.labelSubview.removeConstraints(self.constraints)
            self.topConstraintConstant = self.topConstraintConstant + translation.y
            self.bottomConstraintConstant = self.bottomConstraintConstant + translation.y
            self.trailingConstraintConstant =  self.trailingConstraintConstant + translation.x
            self.leadingConstraintConstant = self.leadingConstraintConstant + translation.x
            self.topConstraint = NSLayoutConstraint(item: chosenQuoteLabel, attribute: .Top, relatedBy: .Equal, toItem: self.labelSubview, attribute: .Top, multiplier: 1, constant: topConstraintConstant)
            self.bottomConstraint = NSLayoutConstraint(item: chosenQuoteLabel, attribute: .Bottom    , relatedBy: .Equal, toItem: self.labelSubview, attribute: .Bottom, multiplier: 1, constant: bottomConstraintConstant)
            self.trailingConstraint = NSLayoutConstraint(item: chosenQuoteLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self.labelSubview, attribute: .Trailing, multiplier: 1, constant: trailingConstraintConstant)
            self.leadingConstraint = NSLayoutConstraint(item: chosenQuoteLabel, attribute: .Leading, relatedBy: .Equal, toItem: self.labelSubview, attribute: .Leading, multiplier: 1, constant: leadingConstraintConstant)
            self.constraints = [topConstraint, bottomConstraint, trailingConstraint, leadingConstraint]
            self.labelSubview.addConstraints(constraints)
        }
    }
    
    func resizeText(pinchGesture: UIPinchGestureRecognizer) {
        let scale = pinchGesture.scale
        self.chosenQuoteLabel.font = chosenQuoteLabel.font.fontWithSize(quoteLabelFontSize * scale)
        
        if pinchGesture.state == .Ended {
            quoteLabelFontSize = quoteLabelFontSize * scale
        }
    }
    
    func changeQuoteFontColor(longPress: UILongPressGestureRecognizer) {
        if longPress.state == .Began {
            if self.isWhite {
                self.chosenQuoteLabel.textColor = UIColor.blackColor()
                self.isWhite = false
            } else {
                self.chosenQuoteLabel.textColor = UIColor.whiteColor()
                self.isWhite = true
            }
        }
    }

    // MARK: rate app functions - to be uncommented once app ID is received.
    func rateMe() {
        let neverRate = NSUserDefaults.standardUserDefaults().boolForKey("neverRate")
        var numLaunches = NSUserDefaults.standardUserDefaults().integerForKey("numLaunches") + 1
        if (!neverRate && (numLaunches == minSessions || numLaunches >= (minSessions + tryAgainSessions + 1))) {
            showRateMe()
            numLaunches = minSessions + 1
        }
        NSUserDefaults.standardUserDefaults().setInteger(numLaunches, forKey: "numLaunches")
    }
    
    func showRateMe() {
        let alert = UIAlertController(title: "Rate Us", message: "Thanks for using Quoto Factory", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Rate Quoto Factory", style: UIAlertActionStyle.Default, handler: { alertAction in
            UIApplication.sharedApplication().openURL(NSURL(string : "https://itunes.apple.com/uk/app/quoto-factory/id1100309467?ls=1&mt=8")!)
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "neverRate")
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Never", style: UIAlertActionStyle.Default, handler: { alertAction in
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "neverRate")
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Maybe Later", style: UIAlertActionStyle.Default, handler: { alertAction in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: IBActions
    @IBAction func actionQuoto(sender: UIBarButtonItem) {
        let image = self.generateQuoto()
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        controller.completionWithItemsHandler = { activity, completed, items, error -> Void in
            if completed {
                self.rateMe()
            }
        
        }
        // if iPhone
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Phone) {
            // go on..
        } else {
            // for iPad
            if controller.respondsToSelector(Selector("popoverPresentationController")) {
                controller.popoverPresentationController!.barButtonItem = self.actionButton;
            }
        }
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func restartQuoto(sender: UIBarButtonItem) {
        self.chosenImageView.image = UIImage(named: "Placeholder.png")
        self.chosenQuoteLabel.text = ""
        self.newQuoto = nil
    }
    
    @IBAction func pickImageFromCamera(sender: UIBarButtonItem) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = .Camera
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func pickFromAlbum(sender: UIBarButtonItem) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = .PhotoLibrary
        self.presentViewController(controller, animated: true, completion: nil)
    }

    @IBAction func chooseQuote(sender: UIButton) {
        self.performSegueWithIdentifier("segueToQuoteVC", sender: self)
    }
}

