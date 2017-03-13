//
//  DataSetDetail.swift
//  oAuth
//
//  Created by Martin Trgina on 10/20/16.
//  Copyright © 2016 BellaDati Inc. All rights reserved.
//

import Foundation

public class DataSetDetail{
    
       public var id:Int
       public var name:String?
       public var owner:String?
       public var localizations:[String:String]?
       public var description: String?
       public var lastChange: String?
       public var attributes: [Attribute]?
       public var indicators:[Indicator]?
       //public var data:[Integer:RowData]?
       public var reports:[ReportDetail]?
       public var timeSupported: Bool?
       public var dateSupported: Bool?
    
    public init(id:Int,name:String? = nil,owner:String? = nil,localizations:[String:String]? = nil,description:String? = nil,lastChange:String? = nil)
    
    {
        
        self.id = id
        self.name = name
        self.owner = owner
        self.localizations = localizations
        self.description = description
        self.lastChange = lastChange
        
    }

    
    
        
    /* Definition of Indicator object properties from DataSetDetail JSON object received from BellaDati */
    
    public class Indicator {
        
        public var id:String
        public var name:String
        public var code:String
        public var type:String
        
        public init (id:String,name:String,code:String,type:String){
            
            self.id = id
            self.name = name
            self.code = code
            self.type = type
        }
        
    }
    
    
    /*Definition of DataSetRow datatype. 1 row has unique id and has multiple attributes and multiple indicators
        
        public class RowData {
            
            public var attribute:(String,String)
            public var indicator:(String,Integer)
            
        }*/

        
        
    
    
    /*Only for testing now */
    
    func downloadSavedDataSetDetail() {
        let s = Bundle.main.url(forResource: "3rdjson", withExtension: "json")
        let data = NSData(contentsOf: s!)
        let string = try! String(contentsOf: Bundle.main.url(forResource: "myjson", withExtension: "json")!, encoding: String.Encoding.utf8)
        print(string)
        
        do{
            
            let jsonObject = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments)
            
            if let dictionary = jsonObject as? [String:AnyObject] {
                readJSONObject (object: dictionary)
            }
        } catch {
            
        }
    }

    public func downloadDataSetDetail(id:Int,completion:(() -> ())? = nil) {
        
        
        let loadInitialData =
            
            {
                APIClient.sharedInstance.authenticateWithBellaDati(){(error) -> Void in
                    print("handlin stuff")
                    if let receivedError = error
                    {
                        print(receivedError)
                    }
                }
        }
        
        if (!APIClient.sharedInstance.hasAccessTokenSaved()){
            
            loadInitialData()
            
        } else {
            
            APIClient.sharedInstance.getData(service: APIClient.APIService.DATASETS,id:String(id)){(getData) in
                
                do{
                    
                    let jsonObject = try JSONSerialization.jsonObject(with: getData! as Data, options: .allowFragments)
                    let jsonstring = NSString(data: getData! as Data, encoding: String.Encoding.utf8.rawValue) as String?
                    print("Datasets:" , jsonstring ?? "nil")
                    if let dictionary = jsonObject as? [String:AnyObject] {
                        self.readJSONObject (object: dictionary)
                        print("Setting JSON")
                    }
                    
                    
                    if let completionHandler = completion{
                        completionHandler()
                    }
                    
                } catch {
                    
                }
                
            }
        }
        
        
    }

    
    
    /* readJSONObject function maps DataSetDetail JSON Object into the DataSetDetail Swift object. BellaDati JSON response object does
     not always contains all JSON object parameters. Objects produced by readJSONObject therefor include sometimes Optional types
     and before unwrapping the values inside. Developer should use  if let or guard statements to check for nil values.*/
    
    func readJSONObject(object:[String:AnyObject]) {
        
        var attributeObject:Attribute
        var indicatorObject:Indicator
        var reportObject:ReportDetail
        
        
        
        
        /* TypeAliases for parsed JSON Dictionaries */
        
        typealias AttributesArray = [[String:AnyObject]]
        typealias IndicatorsArray = [[String:AnyObject]]
        typealias ReportArray =     [[String:AnyObject]]
        typealias LocalizationsArray = [String:String]
        
        
        
        /* Getting DatasetDetail must have values */
            
            guard let id = object["id"] as? String,
                
                let name = object["name"] as? String,
                let owner = object["owner"] as? String,
                let lastChange = object["lastChange"] as? String
                else {return}
        
        
        //Setting DatasetDetailObject
        
        self.id = Int(id)!
        self.name = name
        self.owner = owner
        self.lastChange = lastChange
        
        //For these values BellaDati could return null in JSON
        
        if let description = object["description"] as? String {
            
            self.description = description
        }
        
            
            
        if let dataSetLocalizations = object["localization"] as? LocalizationsArray {
            
            
            var localizations = [String:String]()
            
            for localization in dataSetLocalizations {
                
                localizations.updateValue(localization.1, forKey: localization.0)
                
                
            }

        
            self.localizations = localizations
        
        }
            
        
        /*Trying to load Attributes JSON property object values*/
        
        guard let attributes = object["attributes"] as? AttributesArray else {return}
        
        self.attributes = [Attribute]() // here we inicialize empty array of Attribute objects
        
        for attribute in attributes {
            
            guard let id = attribute["id"] as? String,
            let name = attribute["name"] as? String,
            let code = attribute["code"] as? String,
                let type = attribute["type"] as? String else {continue}
            
            attributeObject = Attribute(id: id, name: name, code: code, type: type)
            self.attributes?.append(attributeObject)
        }
        
        
        /*Trying to load Indicators JSON property object values*/
        
        guard let indicators = object["indicators"] as? IndicatorsArray else {return}
        
        self.indicators = [Indicator]() // here we inicialize empty array of Indicator objects
        
        for indicator in indicators {
            
            guard let id = indicator["id"] as? String,
                let name = indicator["name"] as? String,
                let code = indicator["code"] as? String,
                let type = indicator["type"] as? String else {continue}
            
            indicatorObject = Indicator(id: id, name: name, code: code, type: type)
            self.indicators?.append(indicatorObject)
        }
        
        /*Trying to load Reports JSON property object values*/
        
        guard let reports = object["reports"] as? ReportArray else {return}
        
        self.reports = [ReportDetail]() // here we inicialize empty array of ReportDetail objects
        
        for report in reports {
            
            guard let id = report["id"] as? String,
                let name = report["name"] as? String,
                let owner = report["owner"] as? String,
                let lastChange = report["lastChange"] as? String else {continue}
            
            if let description = report["description"] as? String {
                
                reportObject = ReportDetail(id: Int(id)!, name: name,owner: owner, description: description, lastChange: lastChange)
                self.reports?.append(reportObject)
            } else {

            
            reportObject = ReportDetail(id: Int(id)!, name: name, owner: owner, description: nil,lastChange: lastChange)
            self.reports?.append(reportObject)
            }
        }


        
        
        
            
            
        }
    
    
    
    /* downloadDataSetDetailWith fills properties of all DataSetDetail objects according defined id's */
    
    func downloadDataSetDetailWith(id:[Int]){
        
    }

    
    
    
    
}
