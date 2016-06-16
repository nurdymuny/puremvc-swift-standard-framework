//
//  RecordProxy.swift
//  PureMVCSwift Demo
//
//  Created by Stephan Schulz on 06.10.14.
//  Copyright (c) 2014 Stephan Schulz. All rights reserved.
//

import SwiftyJSON

class RecordProxy : Proxy
{
    
    override class func NAME () -> String
    {
        return "RecordProxy"
    }
    
    var records : Array<RecordVO>
    {
        get
        {
            return self.data as! Array<RecordVO>
        }
        set
        {
            self.data = newValue
        }
    }
    
    var genres : Array<String> = []
    
    var interprets : Array<String>
    {
        get
        {
            
            var array : Array<String> = []
            
            for record in records
            {
                array.append( record.interpret! )
            }
            
            return array;
        }
    }
    
    override func initializeProxy()
    {

        var error: NSError?
        
        let bundle = Bundle.main()
        let path = bundle.pathForResource( "data" , ofType: "json" )
        let data: Data?
        
        do
        {
            data = try Data( contentsOf: URL(fileURLWithPath: path!) , options: NSData.ReadingOptions.dataReadingUncached )
        }
        catch let error1 as NSError
        {
            error = error1
            data = nil
        }
        
        let json = JSON( data: data! )
        var records : Array<RecordVO> = []
     
        for record in json[ "records" ].array!
        {
            records.append( RecordVO.initWithData( record ))
        }
        
        for genre in json[ "genres" ].array!
        {
            genres.append( genre.string! )
        }

        self.data = records
        
        sortRecordsByInterpret()
        sortGenresByName()
        
    }
    
    func sortRecordsByInterpret ()
    {
        records.sort { $0.interpret?.localizedCaseInsensitiveCompare( $1.interpret! ) == ComparisonResult.orderedAscending }
    }
    
    func sortGenresByName ()
    {
        genres.sort { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
    }
    
    func addRecord ( _ record: RecordVO )
    {
        
        records.append( record )
        
        sortRecordsByInterpret()
        
        ApplicationFacade.getInstance().sendNotification( EVENT_RECORD_DID_ADD , body: record )
        
    }
    
    func removeRecord ( _ record: RecordVO )
    {
        
        records.remove( at: self.records.index( of: record )!)
        
        ApplicationFacade.getInstance().sendNotification( EVENT_RECORD_DID_REMOVE , body: record )
        
    }
    
}
