//
//  Report.swift
//  oAuth
//
//  Created by Martin Trgina on 10/27/16.
//  Copyright © 2016 BellaDati Inc. All rights reserved.
//

import Foundation

public class Reports {
    
    public var reportDetails:[ReportDetail]?
    public var offset:Int?
    public var size:Int?
    public var filter:String?
    
    public init(){
        
    }
    
    /* Uploads data from default Apps bundle --- only for testing now */
    
    func uploadSavedReport() {
        let s = Bundle.main.url(forResource: "myjson", withExtension: "json")
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
    
    
    /*downloadListOfReports func will authenticate client automatically if APIClient func hasAccessTokenSave returns false.
     Once this async call is finished.It will try to download list of reports available for authenticated user  */
    
    public func downloadListOfReports(filter:String?,offset:String?,size:String?,completion:(() -> ())? = nil) {
        
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
        
        
        
        let getData =
            
            {
                APIClient.sharedInstance.getData(service: APIClient.APIService.REPORTS,params:paramsarray){(getData) in
            
            do{
                
                let jsonObject = try JSONSerialization.jsonObject(with: getData! as Data, options: .allowFragments)
                let jsonstring = NSString(data: getData! as Data, encoding: String.Encoding.utf8.rawValue) as String?
                print("Reports:" , jsonstring ?? "nil")
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
        
        let loadInitialData =
            
            {
                APIClient.sharedInstance.authenticateWithBellaDati(){(error) -> Void in
                    print("handlin stuff")
                    if let receivedError = error
                    {
                        print(receivedError)
                    }
                    
                    getData()
                }
                
                
        }
        
        if (!APIClient.sharedInstance.hasAccessTokenSaved()){
            
            loadInitialData()
            
        } else {
            
            getData()
            
                    }
        
        
    }


    
    
    /* readJSONObject function maps DataSets JSON Object into the DataSets Swift object. BellaDati JSON response object does
     not always contains all JSON object parameters. Objects produced by readJSONObject therefor include sometimes Optional types
     and before unwrapping the values inside. Developer should use  if let or guard statements to check for nil values.*/
    
    func readJSONObject(object:[String:AnyObject]) {
        
        var reportObject:ReportDetail
        
        
        
        
        /* TypeAliases for parsed JSON Dictionaries */
        
        typealias ReportsArray = [[String:AnyObject]]
        typealias LocalizationsArray = [String:String]
        
        
        
        guard let reports = object["reports"] as? ReportsArray else {return}
        
        self.reportDetails = [ReportDetail]() // here we inicialize empty array of ReportDetail objects
        
        //Setting value for filter, offset and size
        
        if let filter = object["filter"] as? String {
            self.filter = filter
        }
        
        if let size = object["size"] as? Int {
            self.size = size
        }
        
        if let offset = object["offset"] as? Int {
            self.offset = offset
        }
        
        for report in reports {
            
            guard let id = report["id"] as? Int,
                
                let name = report["name"] as? String,
                let owner = report["owner"] as? String,
                let lastChange = report["lastChange"] as? String
                else {return}
            
            let description = report["description"] as? String
            
            
            // getting values of localization objects. If there are no such objects it continues with for dataSet cycle
            
            
            
            guard let reportLocalizations = report["localization"] as? LocalizationsArray else {
                
               reportObject = ReportDetail(id:id, name: name, owner: owner, localizations:nil, description:description, lastChange: lastChange)
                self.reportDetails?.append(reportObject)
                
                
                continue }
            
            var localizations = [String:String]()
            
            for localization in reportLocalizations {
                
                localizations.updateValue(localization.1, forKey: localization.0)
                
                
            }
            
            
            
            reportObject = ReportDetail(id: id, name: name, owner: owner, localizations:localizations, description:description, lastChange: lastChange)
            self.reportDetails?.append(reportObject)
            
            
            
        }
        
        
        
        
        
        
        
    }

    
    
    
    
    
    
    
    
}
