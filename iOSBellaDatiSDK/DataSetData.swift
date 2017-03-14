//
//  DataSetData.swift
//  BellaDatiSDK
//
//  Created by Martin Trgina on 3/11/17.
//  Copyright © 2017 BellaDati Inc. All rights reserved.
//

import Foundation

/* DataSetData is subclass of DataSetDetail. It overrides some of key methods of DataSetDetail */

public class DataSetData{
    
    public var rows:[[String:String]]?
    public var offset:Int?
    public var size:Int?
    public var id:Int?
    public var name:String?
    public var owner:String?
    public var localizations:[String:String]?
    public var description: String?
    public var lastChange: String?
    
    
    public init() {
      
    }
    
    
    /* Downloads DataSetInfo and Data for Attributes and Indicators. Including Row unique number*/
    
    public func downloadData(id:Int,filter:String?,offset:String? = nil,size:String? = nil,order:String? = nil,completion:(() -> ())? = nil) {
        
        var paramsarray = [NSURLQueryItem]()
        
        if let filter = filter {
            
            paramsarray.append(NSURLQueryItem(name: "filter",value: filter))
            
        }

        
        if let offset = offset {
            
            paramsarray.append(NSURLQueryItem(name: "offset",value: offset))
            
        }
        
        if let size = size {
            
            paramsarray.append(NSURLQueryItem(name: "size",value: size))
            
        }
        
        if let order = order {
            
            paramsarray.append(NSURLQueryItem(name: "order",value: order))
            
        }
        
        


        
        
        
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
            
            APIClient.sharedInstance.getData(service: APIClient.APIService.DATASETS,id:String(id),urlSuffix: ["data"],params: paramsarray){(getData) in
                
                do{
                    
                    let jsonObject = try JSONSerialization.jsonObject(with: getData! as Data, options: .allowFragments)
                    let jsonstring = NSString(data: getData! as Data, encoding: String.Encoding.utf8.rawValue) as String?
                    print("DatasetDetailWithData:" , jsonstring ?? "nil")
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
    
    
    func readJSONObject(object:[String:AnyObject]) {
        
        typealias LocalizationsArray = [String:String]
        typealias DataRows = [[String:AnyObject]]
        
        /* Getting dataSet must have values */
        
        guard let dataset = object["dataSet"] as? [String:AnyObject] else {return}
        
        guard let id = dataset["id"] as? String,
            
            let name = dataset["name"] as? String,
            let owner = dataset["owner"] as? String,
            let lastChange = dataset["lastChange"] as? String
            else {return}
        
        
        //Setting DatasetData values
        
        self.id = Int(id)!
        self.name = name
        self.owner = owner
        self.lastChange = lastChange
        
        //For these values BellaDati could return null in JSON
        
        if let description = dataset["description"] as? String {
            
            self.description = description
        }
        
        
        
        if let dataSetLocalizations = dataset["localization"] as? LocalizationsArray {
            
            
            var localizations = [String:String]()
            
            for localization in dataSetLocalizations {
                
                localizations.updateValue(localization.1, forKey: localization.0)
                
                
            }
            
            
            self.localizations = localizations
            
        }
        
        guard let data = object["data"] as? DataRows else {return}
        
        //Inicialize datarows object and fill the object with code:value dictionary
        
        rows = [[String:String]]()
        var singlerow = [String:String]()
        
        for row in data {

            
            for code in row{
                
                if let rowId = row[code.key] as? Int {
                    
                    singlerow.updateValue(String(rowId), forKey: code.key)
                }
                
                if let codename = row[code.key] as? String {
                    
                    singlerow.updateValue(codename, forKey: code.key)
                    
                    
                }
                
            }
            
            rows?.append(singlerow)
        }
    }
    
    
    /*Builds JSON for filter query. For codeop,dateop and typeop values please see BellaDati API doc 
     http://support.belladati.com/techdoc/Types+and+enumerations#Typesandenumerations-Filteroperationtype  */
    
    
    public func prepareFilter (code:String,codeop:String,codevalue:String,typevalues:[String],typeop:String,dateop:String) -> String {
        
        
        let filterObject: [String:[String:[String:Any]] = ["drilldown":[
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

    
    
    
    /* This is alternative function. In case api would return also datasetDetail info not only dataset info
    override func readJSONObject(object:[String:AnyObject]) {
        
        var attributeObject:Attribute
        var indicatorObject:Indicator
        var reportObject:ReportDetail
        
        
        
        
        /* TypeAliases for parsed JSON Dictionaries */
        
        typealias AttributesArray = [[String:AnyObject]]
        typealias IndicatorsArray = [[String:AnyObject]]
        typealias ReportArray =     [[String:AnyObject]]
        typealias DataRows = [[String:AnyObject]]
        typealias LocalizationsArray = [String:String]
        
        
        
        /* Getting DatasetDetail must have values */
        
        guard let dataset = object["dataSet"] as? [String:AnyObject] else {return}
        
        guard let id = dataset["id"] as? String,
            
            let name = dataset["name"] as? String,
            let owner = dataset["owner"] as? String,
            let lastChange = dataset["lastChange"] as? String
            else {return}
        
        
        //Setting DatasetDetailObject
        
        self.id = Int(id)!
        self.name = name
        self.owner = owner
        self.lastChange = lastChange
        
        //For these values BellaDati could return null in JSON
        
        if let description = dataset["description"] as? String {
            
            self.description = description
        }
        
        
        
        if let dataSetLocalizations = dataset["localization"] as? LocalizationsArray {
            
            
            var localizations = [String:String]()
            
            for localization in dataSetLocalizations {
                
                localizations.updateValue(localization.1, forKey: localization.0)
                
                
            }
            
            
            self.localizations = localizations
            
        }
        
        /*Trying to load rows UID,IndicatorCode,AttributeCode*/
        
        guard let data = object["data"] as? DataRows else {return}
        
        for row in data {
        
        /*Trying to load Attributes JSON property object values*/
        
        guard let attributes = dataset["attributes"] as? AttributesArray else {return}
        
        self.attributes = [Attribute]() // here we inicialize empty array of Attribute objects
        
        for attribute in attributes {
            
            guard let id = attribute["id"] as? String,
                let name = attribute["name"] as? String,
                let code = attribute["code"] as? String,
                let type = attribute["type"] as? String else {continue}
            
            attributeObject = Attribute(id: id, name: name, code: code, type: type)
            
            //Here value from row is being saved into attributeValues

            
            if let rowid = row["UID"] as? Int {
            
            if let value = row[code] as? String {
                
            attributeObject.attributeValues?.append((value,String(),rowid))
                
            }
            }
            
            
            self.attributes?.append(attributeObject)
        }
        
        
        /*Trying to load Indicators JSON property object values*/
        
        guard let indicators = dataset["indicators"] as? IndicatorsArray else {return}
        
        self.indicators = [Indicator]() // here we inicialize empty array of Indicator objects
        
        for indicator in indicators {
            
            guard let id = indicator["id"] as? String,
                let name = indicator["name"] as? String,
                let code = indicator["code"] as? String,
                let type = indicator["type"] as? String else {continue}
            
            indicatorObject = Indicator(id: id, name: name, code: code, type: type)
            
            // Here comes value of Indicator with rowindex
            
            
            if let rowid = row["UID"] as? Int {
                
                if let value = row[code] as? String {
                    
                    indicatorObject.values?.append((rowid,Int(value)!))
                    
                }
            }

            
            self.indicators?.append(indicatorObject)
        }
        }
        
        /*Trying to load Reports JSON property object values*/
        
        guard let reports = dataset["reports"] as? ReportArray else {return}
        
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

*/
    
    
}
