//
//  RecordsAddGenreController.swift
//  PureMVCSwift Demo
//
//  Created by Stephan Schulz on 22.09.15.
//  Copyright © 2015 Stephan Schulz. All rights reserved.
//

protocol RecordsGenreDelegate
{
    var genres : Array<String> { get }
    var genresSelected : Array<String> { get set }
}

class RecordsAddGenreController : UITableViewController
{
    
    var delegate : RecordsGenreDelegate?
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return delegate!.genres.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell( withIdentifier: kGenreCell , for: indexPath )
        let genre = delegate!.genres[ (indexPath as NSIndexPath).row ]
        
        cell.textLabel?.text = genre
        cell.accessoryType = delegate!.genresSelected.contains( genre ) ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
        
        return cell
        
    }
    
    override func tableView( _ tableView: UITableView, didSelectRowAt indexPath: IndexPath )
    {
        
        let cell = tableView.cellForRow( at: indexPath )
        let genre = delegate!.genres[ (indexPath as NSIndexPath).row ]
        
        if var d = delegate
        {
            if d.genresSelected.contains( genre )
            {
                
                d.genresSelected.removeObject( genre )
                
                cell?.accessoryType = UITableViewCellAccessoryType.none
                
            }
            else
            {
                
                d.genresSelected.append( genre )
                
                cell?.accessoryType = UITableViewCellAccessoryType.checkmark
                
            }
        }
        
        delegate!.genresSelected.sort { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
        
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        
        super.viewDidDisappear( animated )
        
        delegate = nil
        
    }
}
