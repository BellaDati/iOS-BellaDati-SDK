//
//  View.swift
//  oAuth
//
//  Created by Martin Trgina on 10/27/16.
//  Copyright © 2016 BellaDati Inc. All rights reserved.
//

import Foundation

public class View {
    
    public var viewId:String?
    public var viewType:String?
    public var viewName:String?
    public var localizations:[String:String]?
    public var isFavourite:Bool?
    public var dateTimeDefinition:DateTimeDefinition?
    public var drillDownFilter:[Attribute]? //...is using Attribute Object from getDataSetDetail
    
    public init(){
        
    }
    
    
    public class DateTimeDefinition{
        
        public var timeSupported:Bool = false
        public var dateSupported:Bool = false
        public var timeInterval:TimeInterval? = TimeInterval()
        public var dateInterval:DateInterval? = DateInterval()
        
        public class TimeInterval {
            
            public var aggregationType:String?
            public var aggregated:Bool?
            public var interval = (from:(hour:String(),minute:String(),second:String()),to:(hour:String(),minute:String(),second:String()),type:String())
            
            
        }
        
        public class DateInterval {
            
            public var aggregationType:String?
            public var aggregated:Bool?
            public var interval = (from:(month:String(),year:String(),day:String()),to:(month:String(),year:String(),day:String()),type:String())
        
                    }
        
        
    }
    
    
    /*Builds JSON for filter query. For codeop,dateop and typeop values please see BellaDati API doc
     http://support.belladati.com/techdoc/Types+and+enumerations#Typesandenumerations-Filteroperationtype  */
    
    
    public func prepareFilter (code:String,codeop:String,codevalue:String,typevalues:[String],typeop:String,dateop:String) -> String {
        
        
        let filterObject: [String:[String:Any]] = ["drilldown":[
            code:["op": codeop, "value": codevalue],
            "L_TYPE":["op": typeop, "values": typevalues],
            "L_DATE":["op": dateop]
            ]]
        
        let prettyPrinted = false
        
        let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
        
        
        if JSONSerialization.isValidJSONObject(filterObject) {
            
            do{
                let data = try JSONSerialization.data(withJSONObject: filterObject, options: options)
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    return string as String
                }
            }catch {
                
                print("error")
                //Access error here
            }
            
        }
        return ""
        
    }

    /* Not yet finished */
    
    public func prepareTimeDefinition(dateInterval from:String?, to:String?, dItype:String?, dIaggregationType:String?, timeInterval: (from:(hour:String?,minute:String?,second:String?), to: (hour:String?,minute:String?,second:String?)),tItype:String? ){
        
    }
        
    
    
       
    
    
        
    
    
 
    
}
