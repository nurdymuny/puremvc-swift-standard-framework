//
//  MasterViewController.swift
//  asdfsdfasdf
//
//  Created by Stephan Schulz on 06.10.14.
//  Copyright (c) 2014 Stephan Schulz. All rights reserved.
//

import UIKit

var kOverviewCell : String = "RecordsOverviewCell"

class RecordsOverviewController : UITableViewController
{

    var detailViewController: RecordsDetailController? = nil

    var records : Array<RecordVO>?
    {
        didSet
        {
            
            if ( oldValue != nil )
            {
                
                self.tableView.beginUpdates()
                
                for ( index, record ) in (oldValue!).enumerated()
                {
                    
                    let recordWasRemoved = !self.records!.contains( record )
                    
                    if ( recordWasRemoved )
                    {
                        self.tableView.deleteRows( at: [ IndexPath( row: index , section: 0 ) ], with: .fade )
                    }
                    
                }
                
                for ( index, record ) in (self.records!).enumerated()
                {
                    
                    let recordWasAdded = !oldValue!.contains( record )
                    
                    if ( recordWasAdded )
                    {
                        self.tableView.insertRows( at: [ IndexPath( row: index , section: 0 ) ], with: .fade )
                    }
                    
                }

                self.tableView.endUpdates()

            }
            else
            {
                self.tableView.reloadData()
            }
            
        }
        
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        if UIDevice.current().userInterfaceIdiom == .pad
        {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad()
    {
        
        super.viewDidLoad()
        
        setupNavigationBar()
        
    }
    
    override func viewWillAppear( _ animated: Bool )
    {
        
        super.viewWillAppear( animated )
        
        setupForiPad()
        
    }
    
    func setupNavigationBar ()
    {
        
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: "didPressAdd:" )
        self.navigationItem.rightBarButtonItem = addButton
        
    }
    
    func setupForiPad ()
    {
        
        if UIDevice.current().userInterfaceIdiom == .pad
        {
            self.tableView.selectRow( at: IndexPath( row: 0 , section: 0 ) , animated: false, scrollPosition: UITableViewScrollPosition.top )
            self.performSegue( withIdentifier: SEGUE_OVERVIEW_DETAIL , sender: self )
        }

    }
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?)
    {

        if segue.identifier == SEGUE_OVERVIEW_DETAIL
        {
            
            detailViewController = ( segue.destinationViewController as! UINavigationController ).topViewController as? RecordsDetailController
            
            showDetailViewController( detailViewController! )
            
        }
    }
    
    func showDetailViewController( _ vc: RecordsDetailController )
    {
        
        if let indexPath = self.tableView.indexPathForSelectedRow
        {
            
            let record = records?[ (indexPath as NSIndexPath).row ]
            
            vc.record = record
            vc.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            vc.navigationItem.leftItemsSupplementBackButton = true
            
        }

    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let count = self.records?.count
        {
            return count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell( withIdentifier: kOverviewCell , for: indexPath) 
        let record = records?[ (indexPath as NSIndexPath).row ]

        cell.textLabel?.text = record?.interpret
        
        return cell
        
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if UIDevice.current().userInterfaceIdiom == .pad
        {
            showDetailViewController( self.detailViewController! )
        }
        else
        {
            performSegue( withIdentifier: SEGUE_OVERVIEW_DETAIL , sender: self )
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            ApplicationFacade.getInstance().sendNotification( EVENT_RECORD_SHOULD_REMOVE , body: self.records?[ (indexPath as NSIndexPath).row ] );
        }
    }

    func didPressAdd( _ sender: AnyObject )
    {
        ApplicationFacade.getInstance().sendNotification( EVENT_RECORD_SHOULD_ADD )
    }
    
    
}

