//
//  RecordsCreateController.swift
//  PureMVCSwift Demo
//
//  Created by Stephan Schulz on 06.10.14.
//  Copyright (c) 2014 Stephan Schulz. All rights reserved.
//

import ActionSheetPicker_3_0

var kAddInputCell : String = "RecordsAddInputCell"
var kAddSelectCell : String = "RecordsAddSelectCell"
var kGenreCell : String = "RecordsGenreCell"

var kLanguageInterpret : String = "Interpret"
var kLanguageAlbum : String = "Album"
var kLanguageGenres : String = "Genres"
var kLanguageYear : String = "Year"

var kLanguageEnterInterpret = "Enter Interpret Name"
var kLanguageEnterAlbum = "Enter Album Name"
var kLanguageSelectYear = "Select Year"
var kLanguageSelectGenres = "Select Genres"

class RecordsAddController : UITableViewController, UITextFieldDelegate, RecordsGenreDelegate
{

    var years : Array<String> = []
    var genres : Array<String> = []
    var genresSelected : Array<String> = []
    
    var txtInterpret: UITextField?
    var txtAlbum: UITextField?
    var txtYear: UILabel?
    var txtGenre: UILabel?
    
    private var _lastTextfield: UITextField?
    
    @IBOutlet weak var btnDone: UIBarButtonItem!

    override func viewDidLoad()
    {
        
        super.viewDidLoad()
        
        setupYears()
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        
        super.viewDidAppear( animated )
        
        focusTextfield()
        
    }
    
    override func viewDidLayoutSubviews()
    {
        validateTextfields()
        updateTextfields()
    }
    
    func setupYears ()
    {
        
        for index in 1900...2099
        {
            
            let year = String( format: "%i", index )
            
            years.append( year )
            
        }
        
    }
    
    func focusTextfield ()
    {
        
        if ( txtInterpret!.text!.isEmpty )
        {
            txtInterpret?.becomeFirstResponder()
        }
        
    }
    
    func validateTextfields()
    {
        self.btnDone.isEnabled = !txtInterpret!.text!.isEmpty && !txtAlbum!.text!.isEmpty && genres.count > 0 && txtYear?.tag > 0
    }
    
    func updateTextfields ()
    {
        
        txtGenre?.text = genresSelected.count > 0 ? genresSelected.combine( ", " ) : kLanguageSelectGenres
        txtGenre?.textColor = genresSelected.count > 0 ? UIColor.black() : UIColor( rgba: COLOR_LIGHT_GRAY )
        txtYear?.textColor = txtYear?.tag > 0 ? UIColor.black() : UIColor( rgba: COLOR_LIGHT_GRAY )
        
    }
    
    func close ()
    {
        
        self.view.endEditing( true )
        
        self.dismiss( animated: true , completion: nil )
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField.returnKeyType == UIReturnKeyType.next
        {
            
            let current = self.tableView.indexPath( for: textField.superview?.superview as! UITableViewCell )
            let next = tableView.cellForRow( at: IndexPath( row: (current! as NSIndexPath).row + 1 , section: 0 ))

            ( next as! RecordsAddInputCell ).txtInput.becomeFirstResponder()
            
        }
        else if  textField.returnKeyType == UIReturnKeyType.done
        {
            textField.resignFirstResponder()
        }
        return true;
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        
        delay( EPSILON )
        {
            self.validateTextfields()
        }
        
        _lastTextfield = textField
        
        return true
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool
    {
        
        validateTextfields()
        
        return true
        
    }
    
    @IBAction func onCancelTouched(_ sender: AnyObject)
    {
        close()
    }
    
    @IBAction func onDoneTouched(_ sender: AnyObject)
    {
        
        let record = RecordVO( interpret: txtInterpret?.text , album: txtAlbum?.text , year: txtYear?.text , genres: txtGenre?.text )
        
        ApplicationFacade.getInstance().sendNotification( EVENT_RECORD_WILL_ADD , body: record )
        
        close()
        
    }
    
    func onYearSelected ( _ selectedIndex: NSNumber! , origin: AnyObject! )
    {
        
        txtYear?.text = years[ selectedIndex.intValue ]
        txtYear?.tag = 1
        
        validateTextfields()
        updateTextfields()
        
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        var cell : UITableViewCell?
        
        switch (indexPath as NSIndexPath).row
        {
        case 0, 1:
            
            let c = tableView.dequeueReusableCell( withIdentifier: kAddInputCell , for: indexPath ) as! RecordsAddInputCell
            
            c.txtInput.delegate = self
            
            switch (indexPath as NSIndexPath).row
            {
                case 0:
                    
                    c.txtTitle.text = kLanguageInterpret
                    c.txtInput.placeholder = kLanguageEnterInterpret
                    
                    txtInterpret = c.txtInput
                    
                case 1:
                    
                    c.txtTitle.text = kLanguageAlbum
                    c.txtInput.placeholder = kLanguageEnterAlbum
                    c.txtInput.returnKeyType = UIReturnKeyType.done
                    
                    txtAlbum = c.txtInput

                default :()
                
            }
            
            cell = c
            
        case 2, 3:
            
            let c = tableView.dequeueReusableCell( withIdentifier: kAddSelectCell , for: indexPath ) as! RecordsAddSelectCell
            
            switch (indexPath as NSIndexPath).row
            {
                case 2:
                    
                    c.txtTitle.text = kLanguageYear
                    c.txtSelect.text = kLanguageSelectYear
                    
                    txtYear = c.txtSelect
                    
                case 3:
                    
                    c.txtTitle.text = kLanguageGenres
                    c.txtSelect.text = kLanguageSelectGenres
                    c.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                    
                    txtGenre = c.txtSelect
                    
                default :()
                }
            
            cell = c

        default: ()
            
        }
        
        return cell!
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        switch (indexPath as NSIndexPath).row
        {
            case 2:
                
                _lastTextfield?.resignFirstResponder()
                
                ActionSheetStringPicker.show( withTitle: kLanguageSelectYear , rows: years , initialSelection: 115 , target: self , successAction: "onYearSelected:origin:" , cancelAction: nil , origin: txtYear )
                
            case 3:
            
                performSegue( withIdentifier: SEGUE_ADD_GENRES , sender: self )
                
            default: ()
            }

    }
    
    // MARK: - Segues
    
    override func prepare( for segue: UIStoryboardSegue, sender: AnyObject? )
    {
        if segue.identifier == SEGUE_ADD_GENRES
        {

            let genreController = segue.destinationViewController as! RecordsAddGenreController
            genreController.delegate = self
            
        }
    }
}
