//
//  Domain.swift
//  BellaDatiSDK
//
//  Created by Martin Trgina on 3/12/17.
//  Copyright © 2017 BellaDati Inc. All rights reserved.
//

import Foundation

public class Domain {
    
    public var id:String?
    public var name:String?
    public var description:String?
    public var active:Bool?
    public var dateFormat:String?
    public var timeFormat:String?
    public var timeZone:String?
    public var parameters:[String:String]?
    
    
    public init() {
      
    }
    
    
    
    func uploadSavedDomainInfo() {
        
        
        let testBundle = Bundle (for: type(of:self))
        let s = testBundle.url(forResource: "myjson", withExtension: "json")
        let data = NSData(contentsOf: s!)
        let string = try! String(contentsOf:s!, encoding: String.Encoding.utf8)
        print(string)
        
        do{
            
            let jsonObject = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments)
            
            if let dictionary = jsonObject as? [String:AnyObject] {
                readJSONObject (domain: dictionary)
            }
        } catch {
            
        }
    }
    
    /* In case user using this method is authenticated as single domain admin. Function will
     build array with information about single domain. In case user is BellaDati global admin, array will include information about all domains.*/
    
    public func downloadInfo(domainId: String, completion: ((NSError?) -> ())? = nil) {
		
		let getData = {
			APIClient.sharedInstance.getData(service: .DOMAIN, id: domainId) { (getData, getError) in
				guard let data = getData as Data? else {
					completion?(getError)
					return
				}
				
				do {
					let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
					guard let dictionary = jsonObject as? [String : AnyObject] else {
						completion?(NSError(domain: "BellaDatiDeserializationErrorDomain", code: 0, userInfo: [
							NSLocalizedFailureReasonErrorKey: "Failed to deserialize response."
							]))
						return
					}
					
					self.readJSONObject(domain: dictionary)
					completion?(nil)
				} catch {
					completion?(error as NSError)
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
    
    func readJSONObject(domain:[String:AnyObject]){
        
        guard let id = domain["id"] as? String,
              let name = domain["name"] as? String,
              let active = domain["active"] as? Bool else {return}
        
        if let description = domain["description"] as? String {
            
            self.description = description
        } else {
            
            self.description = ""
        }
        
        if let timezone = domain["timeZone"] as? String {
            
            self.timeZone = timezone
        } else {
            
            self.timeZone = ""
        }
        
        self.id = id
        self.name = name
        self.active = active
        self.dateFormat = domain["dateFormat"] as? String
        self.timeFormat = domain["timeFormat"] as? String

        if let parameters = domain["parameters"] as? [[String:String]]{
            
            self.parameters = [String:String]()
            
            for items in parameters {
                
              _ = self.parameters?.updateValue(items.values.first!,forKey: items.keys.first!)
                    
                
                
            }
            
        }
        
        
    }
 
}
