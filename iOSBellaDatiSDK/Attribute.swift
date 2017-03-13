//
//  Attribute.swift
//  oAuth
//
//  Created by Martin Trgina on 10/21/16.
//  Copyright © 2016 BellaDati Inc. All rights reserved.
//

import Foundation

public class Attribute {
    
   
        public var id:String?
        public var name:String?
        public var code:String
        public var type:String?
        public var op:String? // Used in getReportDetail JSON serialization
    
    public typealias AttributeValue = (value:String,label:String?,rowindex:Int?)
    public var attributeValues:[AttributeValue]?
        
        
        
       public init (id:String? = nil,name:String? = nil,code:String,type:String? = nil){
            
            self.id = id
            self.name = name
            self.code = code
            self.type = type
            self.attributeValues = [AttributeValue]() // Inicialize empty array of AttributeValues
            
            
    }
    
    
    /* Only for testing now -- test */
    
    func downloadSavedAttributes() {
        let s = Bundle.main.url(forResource: "testjson", withExtension: "json")
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
    
    public func downloadAttributeValues(datasetid:Int?,attributecode:String?,filter:String? = nil,completion:(() -> ())? = nil) {
        
        var urlSuffix = [String]() // "attributes/"+attributecode+"\/values"
        
        var paramsarray = [NSURLQueryItem]()
        
        if let filter = filter {
            
            paramsarray.append(NSURLQueryItem(name: "filter",value: filter))
            
        }

        
        guard let datasetid = datasetid,
            let attributecode = attributecode else { print ("Dataset  value is empty and attributecode value is empty. You have to provide values"); return}
        
        urlSuffix.append("attributes")
        urlSuffix.append(attributecode)
        urlSuffix.append("values")
            
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
            
            APIClient.sharedInstance.getData(service: APIClient.APIService.DATASETS,id:String(datasetid),urlSuffix: urlSuffix,params:paramsarray ){(getData) in
                
                do{
                    
                    let jsonObject = try JSONSerialization.jsonObject(with: getData! as Data, options: .allowFragments)
                    let jsonstring = NSString(data: getData! as Data, encoding: String.Encoding.utf8.rawValue) as String?
                    print("Attributes:" , jsonstring ?? "nil")
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
        
        var attributeValueObject:AttributeValue?
    
        
        
        
        
        /* TypeAliases for parsed JSON Dictionaries */
        
        typealias AttributesArray = [[String:AnyObject]]
        
        
        
        
        
        
        /*Trying to load Attributes JSON property object values*/
        
        guard let attributeValues = object["values"] as? AttributesArray else {return}
        
        self.attributeValues = [AttributeValue]() // here we inicialize empty array of Attribute objects
        
        for attributeValue in attributeValues {
            
            guard let value = attributeValue["value"] as? String,
                let label = attributeValue["label"] as? String
                 else {continue}
            
            attributeValueObject = (value,label,nil)
    
            self.attributeValues?.append(attributeValueObject!)
        }
        
        
        
        
        
    }


    
    
}
