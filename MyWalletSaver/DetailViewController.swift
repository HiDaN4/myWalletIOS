//
//  DetailViewController.swift
//  WalletTracker
//
//  Created by Dmitry Sokolov on 7/22/15.
//  Copyright (c) 2015 Dmitry Sokolov. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    
    @IBOutlet weak var mainLabel: UILabel?
    
    var textToShow = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mainLabel?.text = self.textToShow

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.hidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
