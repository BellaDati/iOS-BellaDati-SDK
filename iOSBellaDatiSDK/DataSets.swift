//
//  DataSets.swift
//  oAuth
//
//  Created by Martin Trgina on 10/19/16.
//  Copyright © 2016 BellaDati Inc. All rights reserved.
//


/*Datasets class serialize JSON onject received from BellaDati into Swift object*/

import Foundation

/* Uploads data from default Apps bundle --- only for testing now */





public class DataSets{
    
    public var dataSetDetails:[DataSetDetail]?
    public var offset:Int?
    public var size:Int?
    public var filter:String?
    
    public init () {
        
    }
    
    /* Only for testing now */
    
    func downloadSavedDataSets() {
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

    
    public func downloadListOfDatasets(filter:String?,offset:String?,size:String?,completion:((_ error:NSError?) -> ())? = nil) {
        
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
            
            APIClient.sharedInstance.getData(service: APIClient.APIService.DATASETS,params:paramsarray){(getData,getError) in
                
                do{
                    
                    let jsonObject = try JSONSerialization.jsonObject(with: getData! as Data, options: .allowFragments)
                    let jsonstring = NSString(data: getData! as Data, encoding: String.Encoding.utf8.rawValue) as String?
                    print("Datasets:" , jsonstring ?? "nil")
                    if let dictionary = jsonObject as? [String:AnyObject] {
                        self.readJSONObject (object: dictionary)
                        print("Setting JSON")
                    }
                    
                    
                    if let completionHandler = completion{
                        completionHandler(getError)
                                            }
                    
                } catch {
                    if let completionHandler = completion{
                        completionHandler(getError)
                        
                    }
                }
                
            }
        }
        
        
    }

    
    
    /* readJSONObject function maps DataSets JSON Object into the DataSets Swift object. BellaDati JSON response object does
     not always contains all JSON object parameters. Objects produced by readJSONObject therefor include sometimes Optional types
     and before unwrapping the values inside. Developer should use  if let or guard statements to check for nil values.*/
    
    func readJSONObject(object:[String:AnyObject]) {
        
        var datasetObject:DataSetDetail
        
        
        
        
        /* TypeAliases for parsed JSON Dictionaries */
        
        typealias DataSetsArray = [[String:AnyObject]]
        typealias LocalizationsArray = [String:String]
        
        
        
        guard let dataSets = object["dataSets"] as? DataSetsArray else {return}
        
        self.dataSetDetails = [DataSetDetail]() // here we inicialize empty array of DataSet objects
        
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
        
        for dataSet in dataSets {
            
            guard let id = dataSet["id"] as? String,
            
            let name = dataSet["name"] as? String,
                let owner = dataSet["owner"] as? String,
                let lastChange = dataSet["lastChange"] as? String
            else {return}
            
            let description = dataSet["description"] as? String
            
            
            // getting values of localization objects. If there are no such objects it continues with for dataSet cycle
            
            
            
            guard let dataSetLocalizations = dataSet["localization"] as? LocalizationsArray else {
                
                datasetObject = DataSetDetail(id:Int(id)!, name: name, owner: owner, localizations:nil, description:description, lastChange: lastChange)
                self.dataSetDetails?.append(datasetObject)
                
                
                continue }
            
            var localizations = [String:String]()
            
            for localization in dataSetLocalizations {
            
                localizations.updateValue(localization.1, forKey: localization.0)
                
                
                }
                
            
                
                datasetObject = DataSetDetail(id: Int(id)!, name: name, owner: owner, localizations:localizations, description:description, lastChange: lastChange)
                self.dataSetDetails?.append(datasetObject)
                
                
                
            }
            
        
        
            
            
            
            
        }
    
    /* uploadAttributeValueImage func calls async task. It uploads image to Attribute value in dataset using BellaDati REST API call /api/dataSets/:id/attributes/:code/:value/image. Once async upload is
     finished, completion handler of type (() -> ())? is called. By default this parameter is nil. It means callee does not have to use it.*/
    
	public func uploadAttributeValueImage(datasetid:Int,attributecode:String,attributevalue:String,fileName:String,imagedata:Data,completion: (() -> ())? = nil){
		
		var urlSuffix = [String]()
		
		urlSuffix.append("attributes")
		urlSuffix.append(attributecode)
		urlSuffix.append(attributevalue)
		urlSuffix.append("image")
		
		if !APIClient.sharedInstance.hasAccessTokenSaved() {
			APIClient.sharedInstance.authenticateWithBellaDati { error in
				print("handlin stuff")
				
				if let error {
					print(error)
				}
				
				// TODO: completion should take a Bool? Retry this after initial load?
				completion?()
			}
		} else {
			APIClient.sharedInstance.postData(service: .DATASETS, id: String(datasetid), urlSuffix: urlSuffix, httpBodyData: imagedata) { (_, _) in
				completion?()
			}
		}
		
	}

    
    
    /*
     
     filterByID function takes array of dataset IDs of type Int. If these IDs exist in the DataSetDetail objects array
     Than it returns Optional Array of DataSetDetail objects filtered by such IDs. If applyfilter parameter is set to nil it returns all available DataSetDetail objects
     
     */
    
    public func filterByID (applyfilter:[Int]?) -> [DataSetDetail?]{
        
        var filteredDataSetsByIDs = [DataSetDetail?]()
        
        guard let datasetsIDsFilter = applyfilter,
            let dataSets = self.dataSetDetails
            else {return self.dataSetDetails!}
        
        
        for datasetId in datasetsIDsFilter{
        
        for datasetDetail in dataSets {
            
            
                
                if datasetDetail.id == datasetId {
                    
                    filteredDataSetsByIDs.append(datasetDetail)
                    
                }
                
            }
            
        }
        return filteredDataSetsByIDs
        
    }

    
    
    /*hasDataSetsUploaded just checks if dataSets array is not empty. In other words did we already uploaded some DataSet into the DataSet object.*/
    
    public func hasDataSetsDownloaded() -> Bool{
        
        if self.dataSetDetails != nil
        {
            return true
        }
        return false
    }
    
    /* isEmpty method checks if dataSets array is not empty. For instance when BellaDati user account contains no datasets yet. Than after successful download dataSets array is not nil. But does not contain DataSetDetail objects. Same situation can be caused by settin urlparam to 0 or filter to non exiting dataset name etc.
     */
    
    public func isEmpty() -> Bool {
        
        if let dataSets = self.dataSetDetails{
            
            if dataSets.count == 0 {
                return true
            }
            }
        
        return false 
        }
        
    
    
    
        
    }

    
    
    
    
