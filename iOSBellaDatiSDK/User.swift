//
//  User.swift
//  oAuth
//
//  Created by Martin Trgina on 10/17/16.
//  Copyright © 2016 BellaDati Inc. All rights reserved.
//

/* This class serialize User JSON object received from BellaDati */

import Foundation
import UIKit


 public class User {
    
    
    public var id:Int?
    public var username:String?
    public var domain_id:Int?
    public var firstName:String?
    public var lastName:String?
    public var email:String?
    public var active:Bool?
    public var info:String?
    public var firstLogin:String?
    public var lastLogin:String?
    public var phone:String?
    public var timeZone:String?
    public var locale:String?
    public var roles = [Role?]()
    public var group = [Group?]()
    var userphoto:NSData?
    
    public init () {
        
    }
    
    
    public class Role {
        
        public var role:String?
        
        public init(role:String){
            self.role = role
        }
        
    }
    
    public class Group {
        
        public var  id:String?
        public var  name:String?
        
        public init(id:String,name:String){
            self.id = id
            self.name = name
        }
        
    }
    
    
    /* Uploads data from default Apps      bundle --- only for testing*/
    
    public func uploadSavedUser() {
        let s = Bundle.main.url(forResource: "myjson", withExtension: "json")
        let data = NSData(contentsOf: s!)
        let string = try! String(contentsOf: Bundle.main.url(forResource: "myjson", withExtension: "json")!, encoding: String.Encoding.utf8)
        print(string)
        
        do{
            
            let jsonObject = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments)
            
            if let dictionary = jsonObject as? [String:AnyObject] {
                readJSONObject (user: dictionary)
            }
        } catch {
            
        }
    }
    
    
    /* downloadUserDetailByUsername calls async task. It downloads userDetail JSON by using BellaDati REST API call /api/users/username/:username.Once async upload is
     finished completion handler of type (() -> ())? is called. By default this parameter is nil. It means callee does not have to use it. Into the completion handler user can include downloadUserPhoto method to get the user picture */
    
    public func downloadUserDetailByUsername(username:String,completion:(() -> ())? = nil) {
        
        
        
        
        
        let getData =
            
            {
            
            APIClient.sharedInstance.getData(service: APIClient.APIService.USERDETAIL,id: username){(getData) in
            
            do{
                
                let jsonObject = try JSONSerialization.jsonObject(with: getData! as Data, options: .allowFragments)
                let jsonstring = NSString(data: getData! as Data, encoding: String.Encoding.utf8.rawValue) as? String
                print("User:" , jsonstring)
                if let dictionary = jsonObject as? [String:AnyObject] {
                    self.readJSONObject (user: dictionary)
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
    
    /*downloadUserPhoto method download user picture from BellaDati by taking userid parameter. It stores it into the userimage NSData object*/
    
    public func downloadUserPhoto(userid:Int, completion:(() -> ())? = nil){
        
        
        
        let getData =
        
            {
                APIClient.sharedInstance.getData(service: APIClient.APIService.USER,id: String(userid),urlSuffix: ["image"]){(getData) in
                    
                    self.userphoto = getData
                    
                    if let completionHandler = completion{
                        completionHandler()
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
    
    /* getUserPhoto converts userphoto:NSData object into the UIImage. So it can be used directly in iOS gui. When
       userphoto value is empty. It return new UIImage object as empty placeholder*/
    
    public func getUserPhoto() -> UIImage{
        
        guard let useruireadyimage = UIImage(data: userphoto! as Data) else {print("userphoto value is nil.Please upload picture"); return UIImage()}
        
        return useruireadyimage
    }


   
    /* readJSONObject function maps importForms JSON Object into the ImportForms Swift object. BellaDati JSON response object does
     not always contains all JSON object parameters. Objects produced by readJSONObject therefor include sometimes Optional types
     and before unwrapping the values inside. Developer should use  if let or guard statements to check for nil values.*/
    
    func readJSONObject(user:[String:AnyObject]) {
        
        
        
        /* TypeAliases for parsed JSON Dictionaries */
        
        typealias RolesArray = [[String:String]]
        typealias GroupsArray = [[String:String]]
        
        
        
        
        
        // Followign values have to be provided everytime otherwise User object values will be empty Optionals
        
       
            
            guard let id = user["id"] as? String,
                let username = user["username"] as? String,
        let domain_id = user["domain_id"] as? String,
        let firstName = user["firstName"] as? String,
        let lastName = user["lastName"] as? String,
        let active = user["active"] as? Bool,
        let locale = user ["locale"] as? String
                else {
                    return }
        
        
        //Setting User object
        
        self.id = Int(id)
        self.username = username
        self.domain_id = Int(domain_id)
        self.firstName = firstName
        self.lastName = lastName
        self.active = active
        self.locale = locale
        
        //For these values BellaDati can return null in JSON
        
        if let email = user["email"] as? String {
         self.email =  email
        }
        if let info = user["info"] as? String {
         self.info = info
        }
        if let phone = user["phone"] as? String {
        self.phone = phone
        }
        if let timeZone = user ["timeZone"] as? String {
        self.timeZone = timeZone
        }
        
        // In BellaDati if lastLogin and firstLogin are empty, than JSON does not includes these properties. We must check it
        
        if  let firstLogin = user["firstLogin"] as? String, let lastLogin = user ["lastLogin"] as? String {
        
        self.firstLogin = firstLogin
        self.lastLogin = lastLogin
        
        }
        
        
            
        
            
            guard let roles = user["roles"] as? RolesArray else {return}
            

            for role in roles{
                
                guard let userrole = role["role"]
                  else { continue}
                
                
                // if items json object field is empty will continue to process next json element object
                
                var roleObject = Role(role: userrole)
                    self.roles.append(roleObject)
                    
        }
        
        
        guard let groups = user["groups"] as? GroupsArray else {return}
            
        
        for group in groups{
            
            guard let id = group["id"],
                let name = group["name"]
                else { continue}
            
            
            // if items json object field is empty will continue to process next json element object

            var groupObject = Group(id: id, name: name)
            self.group.append(groupObject)
            
        }

        
        
        
    }
    
    /*hasUserDownloaded just checks if User object has been filled by data from JSON object. In other words did we already uploaded some User profile into the User object.*/
    
    public func hasUserDownloaded() -> Bool{
        
        if self.id != nil
        {
            return true
        }
        return false
    }
    
    
    /*Returns true if user is active. Returns false if it is not or in case, that User object has not been filled by JSON user object*/ 
    
    public func isActive() -> Bool {
        
        if self.hasUserDownloaded() == true {
            if self.active == true {
                return true
            } else {
                return false
            }
        } else {
           return false
        }
    }
    
    
    


    
    
    
    
}
