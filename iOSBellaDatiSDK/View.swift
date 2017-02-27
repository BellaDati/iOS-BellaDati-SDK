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
    
    
        
    
        
    
    
       
    
    
        
    
    
 
    
}
