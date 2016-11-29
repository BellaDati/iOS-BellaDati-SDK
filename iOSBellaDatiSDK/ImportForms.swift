//
//  JSONParser.swift
//  oAuth
//
//  Created by Martin Trgina on 9/9/16.
//  Copyright © 2016 BellaDati Inc. All rights reserved.
//

import Foundation

public class ImportForms{
    
    
    public init(){
    
    }
    
    /* Stores field of all importForm objects mapped from JSON object*/
    
    public var importForms:[ImportForm?]?
    
    /* ImportForm object definition */
    
    public class ImportForm {
        
        
        public var id:Int
        public var name:String
        public let recordTimestamp:Bool?
        public var elements:[ImportFormElement]?
        
        public init(id:Int,
        name:String,
        recordTimestamp:Bool?,
        elements:[ImportFormElement]?){
            
            self.id = id
            self.name = name
            self.recordTimestamp = recordTimestamp
            self.elements = elements
            
        }
        
    }
    
    /* ImportFormElement object definition */
    
    public class ImportFormElement {
        
        public var id:String
        public var name:String
        public var type:String
        public var mapToDateColumn:Bool?
        public var items:[String]?
        public var value:String?
        
        public init (id:String,
        name:String,
        type:String,
        mapToDateColumn:Bool?,
        items:[String]?,
            value:String?){
        
            self.id = id
            self.name = name
            self.type = type
            self.mapToDateColumn = mapToDateColumn
            self.items = items
            self.value = value
        
        
        }

        
        
    }
    
    
    
    /* Uploads data from default Apps bundle --- only for testing now */
    
    func uploadSavedForms() {
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
    
    
    /* downloadOnLineForms calls async task. It uploads onlineForms using BellaDati REST API.Once async upload is
     finished completion handler of type (() -> ())? is called. By default this parameter is nil. It means callee does not have to use it. Into the completion handler user can include ImportForms
     func such as filterById or filterByName */
    
    public func downloadOnLineForms(completion:(() -> ())? = nil) {
        
        
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
            
            APIClient.sharedInstance.getData(service: APIClient.APIService.IMPORTFORMS){(getData) in
                
                do{
                    
                    let jsonObject = try JSONSerialization.jsonObject(with: getData! as Data, options: .allowFragments)
                    
                    if let dictionary = jsonObject as? [String:AnyObject] {
                        self.readJSONObject (object: dictionary)
                    }
                    
                    
                    if let completionHandler = completion{
                        completionHandler()
                    }
                    
                } catch {
                    
                }
                
            }
        }
        
        
    }
    
    
    /* uploadOnLineForms calls async task. It uploads onlineForms using BellaDati REST API.Once async upload is
     finished completion handler of type (() -> ())? is called. By default this parameter is nil. It means callee does not have to use it.*/
    
    public func uploadOnlineFormValues(formid:Int,completion: (() -> ())? = nil){
        
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
            
            let readyData = self.buildJSONObject(formid: formid)
            APIClient.sharedInstance.postData(service: APIClient.APIService.IMPORTFORMS,id:String(formid),httpBodyData:readyData){(responseData) in
            }
        
        }

    }
    
    
    
    
    
    
    /* readJSONObject function maps importForms JSON Object into the ImportForms Swift object. BellaDati JSON response object does
     not always contains all JSON object parameters. Objects produced by readJSONObject therefor include sometimes Optional types
     and before unwrapping the values inside. Developer should use  if let or guard statements to check for nil values.*/
    
    func readJSONObject(object:[String:AnyObject]) {
        
        var formObject:ImportForm
        var formElementObject:ImportFormElement
        var importFormElements:[ImportFormElement]?
        var importFormElementItems:[String]?
        
        /* TypeAliases for parsed JSON Dictionaries */
        
        typealias ImportFormsArray = [[String:AnyObject]]
        typealias FormElementArray = [[String:AnyObject]]
        typealias FormElementItemArray = [[String:AnyObject]]
        
        
        guard let forms = object["importForms"] as? ImportFormsArray else {return}
        
        importForms = [ImportForm?]()
        
        for form in forms {
            
            guard let id = form["id"] as? Int,
                let name = form["name"] as? String else {return}
            
            let recordTimestamp = form["recordTimestamp"] as? Bool
            
            
            // if elements json field is empty it will continue to process next form object
            
            guard let formElements = form["elements"] as? FormElementArray else {continue}
            
            importFormElements = [ImportFormElement]()
            
            for formElement in formElements{
                
                guard let id = formElement["id"] as? String,
                    let name = formElement["name"] as? String,
                    let type = formElement["type"] as? String else { continue}
                
                let mapToDateColumn = formElement["mapToDateColumn"] as? Bool
                
                // if items json object field is empty will continue to process next json element object
                
                guard let formElementItems = formElement["items"] as? FormElementItemArray else {
                    importFormElementItems = nil
                    formElementObject = ImportFormElement(id: id, name: name, type: type, mapToDateColumn: mapToDateColumn, items: importFormElementItems,value:String())
                    importFormElements?.append(formElementObject)
                    
                    continue }
                
                importFormElementItems = [String]()
                
                for formElementItem in formElementItems {
                    
                    guard let name = formElementItem["name"] as? String else {continue}
                    importFormElementItems?.append(name)
                }
                
                formElementObject = ImportFormElement(id: id, name: name, type: type, mapToDateColumn: mapToDateColumn, items: importFormElementItems,value:String())
                
                importFormElements?.append(formElementObject)
                
                
                
                
            }
            
            formObject = ImportForm(id: id, name: name,recordTimestamp: recordTimestamp, elements: importFormElements)
            
            importForms?.append(formObject)
            
            print (formObject)
            
            
            
            
        }
        
    }
    
    /* Builds JSON Object to be send to BellaDati service. Object is build from ImportFormElement objects and their id and value.Resulting in JSON object of type { "rN5hVdAXBJ" : "John", "wo35CMzcGV" : "Doe"}.Such JSON object represents values for single Form. ----must be corrected
    */
    
    func buildJSONObject (formid:Int) -> Data {
        
        var jsonDictionary = [String:String]()
        var rawData = Data()
        var jsonString = String()
        
        if self.hasImportFormsUploaded() == true {
            
            var importform = self.filterByID(applyfilter: [formid])!
            let formelements = importform[0]?.elements!
            
            for element in formelements! {
                
                jsonDictionary.updateValue(element.value!, forKey: element.id)
            }
            
        }
        
        if JSONSerialization.isValidJSONObject(jsonDictionary) { // True
            do {
                rawData = try JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
                jsonString = "data=" + (String(data: rawData as Data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))! as String)
                rawData = jsonString.data(using: String.Encoding.utf8)! as Data
            } catch {
                // Handle Error
            }
        }
        
        
        return rawData
    }
    
    /*
     
     filterByID function takes array of report IDs of type Int. If these IDs exist in the ImportForms importForms array
     of ImportForm objects. Than it returns Optional Array of ImportForm objects filtered by such IDs. If applyfilter parameter is set to nil it returns all available importForm objects
     
     */
    
    public func filterByID (applyfilter:[Int]?) -> [ImportForm?]?{
        
        var filteredFormsByIDs = [ImportForm?]()
        
        guard let formsIDsFilter = applyfilter,
            let importForms = self.importForms
            else {return self.importForms}
        
        
        for formId in formsIDsFilter {
            
            for importForm in importForms {
                
                if importForm!.id == formId {
                    
                    filteredFormsByIDs.append(importForm!)
                    
                }
                
            }
            
        }
        return filteredFormsByIDs
        
    }
    
    /*
     
     filterByName function takes array of report names of type String. If these IDs exist in the ImportForms
     importForms array of ImportForm objects. Than it returns Optional Array of ImportForm objects filtered by such
     names. If applyfilter parameter is set to nil it returns all available importForm objects
     
     */
    
    public func filterByName (applyfilter:[String]?) -> [ImportForm?]? {
        
        
        
        var filteredFormsByName = [ImportForm?]()
        
        guard let formsNamesFilter = applyfilter,
            let importForms = self.importForms
            else {return self.importForms }
        
        
        for formName in formsNamesFilter {
            
            for importForm in importForms {
                
                if importForm!.name == formName {
                    
                    filteredFormsByName.append(importForm!)
                    
                } else {
                    
                }
                
            }
            
        }
        
        return filteredFormsByName
        
        
    }
    
    
    public func getForm(id:Int) -> ImportForm? {
        
        var readyImportForm:ImportForm?
        
        if let readyImportForms = self.importForms {
            
            for importForm in readyImportForms {
                
                if importForm?.id == id {
                    
                    readyImportForm = importForm
                
            }
            
        }
        }
        
        if  readyImportForm == nil {
            
            print("Form with id \(id) does not exists.Sorry")
            
        }
        
        
    
        return readyImportForm
        
    }
    

    
    
    /*hasImportFormsUploaded just checks if importForms array is not empty. In other words did we already uploaded some forms into the ImportForms object.*/
    
    public func hasImportFormsUploaded() -> Bool{
        
        if self.importForms != nil
        {
            return true
        }
        return false
    }
    
    
    
    
}
