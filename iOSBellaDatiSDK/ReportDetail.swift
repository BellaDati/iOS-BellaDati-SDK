//
//  ReportDetail.swift
//  oAuth
//
//  Created by Martin Trgina on 10/20/16.
//  Copyright © 2016 BellaDati Inc. All rights reserved.
//

import Foundation

public class ReportDetail {
    
    public var id:Int
    public var name:String
    public var description:String?
    public var localizations:[String:String]?
    public var owner:String
    public var lastChange:String
    public var views:[View]?
    public var dataSet:DataSetDetail?
    public var reportThumbnail:NSData?
    public var viewIDnewPictureView:String? //used for response from uploadImage
    public var comments:Comment?
    
    public init(id:Int,name:String? = nil,owner:String? = nil,localizations:[String:String]? = nil,description:String? = nil,lastChange:String? = nil)
        
    {
        
        self.id = id
        self.name = name!
        self.owner = owner!
        self.localizations = localizations
        self.description = description
        self.lastChange = lastChange!
        
        
        

        
    }
    
    /*Not yet fully implemented  */
    
    public class Comment {
        
        /*var id:String
        var authorId:String
        var author:String
        var text:String
        var when:String*/
        
    }
    
    
    /* Downloads ReportDetail of Report*/
    
    public func downloadReportDetail(completion:((_ error:NSError?) -> ())? = nil) {
        
        
        
        
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
            
            APIClient.sharedInstance.getData(service: APIClient.APIService.REPORTS,id:String(id)){(getData,getError) in
                
                do{
                    
                    let jsonObject = try JSONSerialization.jsonObject(with: getData! as Data, options: .allowFragments)
                    let jsonstring = NSString(data: getData! as Data, encoding: String.Encoding.utf8.rawValue) as String?
                    print("Report detail:" , jsonstring ?? "nil")
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

    /* Post comments to report */
    
    public func uploadComment(reportid:Int, comment:String, completion: (() -> ())? = nil){
        
        
        let readyComment = "text="+comment
        let commentData = readyComment.data(using: String.Encoding.utf8)!
        
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
            
            APIClient.sharedInstance.postData(service: .REPORTS, id: String(reportid), urlSuffix: ["comments"], httpBodyData: commentData){ responseData, error in
                
                do {
                    
                    let jsonObject = try JSONSerialization.jsonObject(with: responseData! as Data, options: .allowFragments)
                    let jsonstring = NSString(data: responseData! as Data, encoding: String.Encoding.utf8.rawValue) as String?
                    print("Comment detail:" , jsonstring ?? "nil")
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
    
    
    public func deleteComment(id:Int){
        
    }
    
   
    
    
    
        /* uploadImage func calls async task. It uploads image to Report using BellaDati REST API call /api/reports/:id/images. Once async upload is
         finished, completion handler of type (() -> ())? is called. By default this parameter is nil. It means callee does not have to use it.*/
        
    public func uploadImage(reportid:Int,imageViewName:String,filename:String,width:Int? = nil,height:Int? = nil,imagedata:Data,completion: (() -> ())? = nil){
            
            
            
            var paramsarray = [NSURLQueryItem]()
            
            if let width = width {
                
                paramsarray.append(NSURLQueryItem(name: "width",value: String(width)))
                
            }
            
            if let height = height {
                
                paramsarray.append(NSURLQueryItem(name: "height",value: String(height)))
                
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
                
                APIClient.sharedInstance.postData(service: APIClient.APIService.REPORTS,id:String(reportid),urlSuffix: ["images"],params:paramsarray,httpBodyData:imagedata,multipartFormParams: ["filename":filename,"viewName":imageViewName]){ (responseData, _) in
                   
                    do{
                        
                        let jsonObject = try JSONSerialization.jsonObject(with: responseData! as Data, options: .allowFragments)
                        let jsonstring = NSString(data: responseData! as Data, encoding: String.Encoding.utf8.rawValue) as String?
                        print("Report detail:" , jsonstring ?? "nil")
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
        
    

    
    /* getThumbnail will download thumbnail picture of the report */
    
    public func getThumbnail (reportid:Int,completion:(() -> ())? = nil){
        
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
            
            APIClient.sharedInstance.getData(service: APIClient.APIService.REPORTS,id: String(reportid),urlSuffix: ["thumbnail"]){(getData,getError) in
                
                self.reportThumbnail = getData
                
                if let completionHandler = completion{
                    completionHandler()
                }
                
                
            }
        }

        
    }
    
    /* readJSONObject function maps reportDetail JSON Object into the ReportDetail Swift object. BellaDati JSON response object does
     not always contains all JSON object parameters(for instance value is sometimes values property according of op property value). Objects produced by readJSONObject therefor include sometimes Optional types
     and before unwrapping the values inside. Developer should use  if let or guard statements to check for nil values.*/
    
    func readJSONObject(object:[String:AnyObject]) {
        
        
     
        
        /* TypeAliases for parsed JSON Dictionaries */
        
        typealias ViewsArray = [[String:AnyObject]]
        typealias DataSetArray = [String:AnyObject]
        typealias LocalizationsArray = [String:String]
        typealias DateTimeDefinitionArray = [String:AnyObject]
        typealias FilterArray = [String:AnyObject]
        
        
        
        /* This JSON param is used only when downloading comments*/
        
        if let comments = object["comments"] as? [[String:String]] {
            
            for comment in comments {
                
                var id = comment["id"]
                var authorId = comment["authorId"]
                var author = comment["author"]
                var text = comment["text"]
                var when = comment["when"]
                
            }
            
        }
        
        
        /*This JSON param is returned only when we are using method uploadImage */
        
        if let viewIDnewPictureView = object["viewId"] as? String {
            self.viewIDnewPictureView = viewIDnewPictureView
        }
        
        /* Getting ReportDetail must have values */
        
        guard let id = object["id"] as? Int,
            
            let name = object["name"] as? String,
            let owner = object["owner"] as? String,
            let lastChange = object["lastChange"] as? String
            else {return}
        
        
        //Setting DatasetDetailObject
        
        self.id = id
        self.name = name
        self.owner = owner
        self.lastChange = lastChange
        
        
        //For these values BellaDati could return null in JSON
        
        if let description = object["description"] as? String {
            
            self.description = description
        }
        
        
        
        if let reportLocalizations = object["localization"] as? LocalizationsArray {
            
            
            var localizations = [String:String]()
            
            for localization in reportLocalizations {
                
                localizations.updateValue(localization.1, forKey: localization.0)
                
                
            }
            
            
            self.localizations = localizations
            
        }
        
        
        /*Trying to load dataSet JSON property object values*/
        
        guard let dataSet = object["dataSet"] as? DataSetArray else {return}
        
        var datasetid:String?
        var datasetname:String?
        var datasetowner:String?
        var datasetlastChange:String?
        var datasettimeSupported:Bool?
        var datasetdateSupported:Bool?
        var datasetdescription:String?
        var datasetdrilldownAttributes:[[String:String]]?
        
        for dataSetProperty in dataSet {
            
            
            
            switch dataSetProperty.key {
                
            case "id": if let id = dataSetProperty.value as? String { datasetid = id }
            case "name": if let name = dataSetProperty.value as? String {datasetname = name}
            case "owner" : if let owner = dataSetProperty.value as? String { datasetowner = owner}
            case "lastChange" : if let lastChange = dataSetProperty.value as? String {datasetlastChange = lastChange}
            case "timeSupported" : if let timeSupported = dataSetProperty.value as? Bool {datasettimeSupported = timeSupported}
            case "dateSupported" : if let dateSupported =  dataSetProperty.value as? Bool {datasetdateSupported = dateSupported }
            case "description" : if let description = dataSetProperty.value as? String {datasetdescription = description}
            case "drilldownAttributes" : if let drilldownAttributes = dataSetProperty.value as? [[String:String]] {datasetdrilldownAttributes = drilldownAttributes}
                
            default: continue
                
            }
            
        
        }
        
        self.dataSet = DataSetDetail(id: Int(datasetid!)!, name: datasetname, owner: datasetowner, localizations: nil, description: datasetdescription, lastChange: datasetlastChange)
        self.dataSet?.timeSupported = datasettimeSupported
        self.dataSet?.dateSupported = datasetdateSupported
        self.dataSet?.attributes = [Attribute]()
        
        if datasetdrilldownAttributes != nil {
        
        for attribute in datasetdrilldownAttributes!{
            print(attribute["id"] ?? "nil")
        self.dataSet?.attributes?.append(Attribute(id: attribute["id"], name: attribute["name"], code: attribute["code"]!, type: attribute["type"]))
            
            }
        }
        
        print (self.dataSet?.attributes?[0].name ?? "nil")
        
        /*Trying to load View's JSON property object values*/
        
        guard let viewsObjects = object["views"] as? ViewsArray else {return}
        
        self.views = [View]() // here we inicialize empty array of View objects
       
        
        /* View Objects */
        
        var drillDownFilterObject:[Attribute]
        var dateTimeDefinitionObject:View.DateTimeDefinition
        var viewObject:View

        
        for view in viewsObjects {
            
            viewObject = View()
            
            guard let id = view["id"] as? String,
                let type = view["type"] as? String,
                let name = view["name"] as? String,
                let isFavourite = view["isFavourite"] as? Bool else {continue}
            
            /*Add guard statement values into View object */
            
            viewObject.viewId = id
            
            
            
            viewObject.viewType = type
            viewObject.viewName = name
            viewObject.isFavourite = isFavourite
            
            var localizations = [String:String]() // localizations of view
            
            print (view["type"] ?? "nil")
            
            if let viewLocalizations = view["localization"] as? LocalizationsArray {
                
                
                
                
                for localization in viewLocalizations {
                    
                    localizations.updateValue(localization.value, forKey: localization.key)
                    
                    
                }

            viewObject.localizations = localizations
                    }
        
            
        /*Trying to load View's dateTimeDefinition JSON property object values*/
        
        if let dateTimeDefinition = view["dateTimeDefinition"] as? DateTimeDefinitionArray {
            
            dateTimeDefinitionObject = View.DateTimeDefinition()
            
            var dttimeInterval:[String:AnyObject]?
            var dtdateInterval:[String:AnyObject]?
        
            for dateTimeProperty in dateTimeDefinition {
            
                switch dateTimeProperty.key {
                    
                case "timeSupported": if let timeSupported = dateTimeProperty.value as? Bool {dateTimeDefinitionObject.timeSupported = timeSupported}
                case "dateSupported": if let dateSupported = dateTimeProperty.value as? Bool {dateTimeDefinitionObject.dateSupported = dateSupported}
                case "timeInterval": if let timeInterval =  dateTimeProperty.value as? [String:AnyObject] {dttimeInterval = timeInterval}
                case "dateInterval": if let dateInterval = dateTimeProperty.value as?[String:AnyObject]{dtdateInterval = dateInterval}
                default: continue
                
                }
            }
                 // Serializing DateTimeDefinition's timeInterval property
                
                if dttimeInterval != nil {
                    
                    var tiinterval:[String:AnyObject]?
                    
                    for dttimeIntervalProperty in dttimeInterval!{
                        
                        switch dttimeIntervalProperty.key {
                            
                        case "aggregationType": if let aggregationType = dttimeIntervalProperty.value as? String {dateTimeDefinitionObject.timeInterval?.aggregationType = aggregationType}
                        case "aggregated": if let aggregated = dttimeIntervalProperty.value as? Bool {dateTimeDefinitionObject.timeInterval?.aggregated = aggregated }
                        case "interval": if let interval = dttimeIntervalProperty.value as? [String:AnyObject] { tiinterval = interval }
                        default: continue
                            
                        }
                        
                    }
                    
                    if tiinterval != nil {
                        
                        for titintervalproperty in tiinterval!{
                            
                            
                            print (titintervalproperty.value)
                            
                            switch titintervalproperty.key{
                                
                            case "from": if let from = titintervalproperty.value as? [String:String] {
                                
                                if from["hour"] != nil{
                                  dateTimeDefinitionObject.timeInterval?.interval.from.hour = from["hour"]!
                                }
                                
                                if from["minute"] != nil{
                                    dateTimeDefinitionObject.timeInterval?.interval.from.minute = from["minute"]!
                                }
                                
                                if from["second"] != nil{
                                    dateTimeDefinitionObject.timeInterval?.interval.from.second = from["second"]!
                                }

                                                                }
                            case "to": if let to = titintervalproperty.value as? [String:String] {
                                
                                if to["hour"] != nil{
                                    dateTimeDefinitionObject.timeInterval?.interval.to.hour = to["hour"]!
                                }
                                
                                if to["minute"] != nil{
                                    dateTimeDefinitionObject.timeInterval?.interval.to.minute = to["minute"]!
                                }
                                
                                if to["second"] != nil{
                                    dateTimeDefinitionObject.timeInterval?.interval.to.second = to["second"]!
                                }

                                
                                }
                            case "type":if let type = titintervalproperty.value as? String {dateTimeDefinitionObject.timeInterval?.interval.type = type}
                            default: continue
                            }
                        }
                    }
                    
                }
            
            
            // Serializing DateTimeDefinition's dateInterval property
            
            if dtdateInterval != nil {
                
               
                var diinterval:[String:AnyObject]?
                
                for dtdateIntervalProperty in dtdateInterval!{
                    
                    switch dtdateIntervalProperty.key {
                        
                    case "aggregationType": if let aggregationType = dtdateIntervalProperty.value as? String {dateTimeDefinitionObject.dateInterval?.aggregationType = aggregationType}
                    case "aggregated": if let aggregated = dtdateIntervalProperty.value as? Bool { dateTimeDefinitionObject.dateInterval?.aggregated = aggregated }
                    case "interval": if let interval = dtdateIntervalProperty.value as? [String:AnyObject] { diinterval = interval }
                    default: continue
                        
                    }
                    
                }
                
                if diinterval != nil {
                    
                    for ditintervalproperty in diinterval!{
                        
                        
                        switch ditintervalproperty.key{
                            
                        case "from": if let from = ditintervalproperty.value as? [String:String] {
                            
                            if from["day"] != nil{
                                dateTimeDefinitionObject.dateInterval?.interval.from.day = from["day"]!
                            }
                            
                            if from["month"] != nil{
                                dateTimeDefinitionObject.dateInterval?.interval.from.month = from["month"]!
                            }
                            
                            if from["year"] != nil{
                                dateTimeDefinitionObject.dateInterval?.interval.from.year = from["year"]!
                            }

                            }
                            
                            
                            
                        case "to": if let to = ditintervalproperty.value as? [String:String] {
                            
                                if to["day"] != nil{
                                    dateTimeDefinitionObject.dateInterval?.interval.to.day = to["day"]!
                                }
                                
                                if to["month"] != nil{
                                    dateTimeDefinitionObject.dateInterval?.interval.to.month = to["month"]!
                                }
                                
                                if to["year"] != nil{
                                    dateTimeDefinitionObject.dateInterval?.interval.to.year = to["year"]!
                                }

                            }
                        case "type":if let type = ditintervalproperty.value as? String { dateTimeDefinitionObject.dateInterval?.interval.type = type}
                        default: continue
                        }
                                            }
                    

                }
                
            }
            
           print (dateTimeDefinitionObject.dateInterval?.interval ?? "nil") //Test
           viewObject.dateTimeDefinition = dateTimeDefinitionObject //Assigning assembled dateTimeDefinitionObject to viewObject
            }
            
           /* Serializing Views's filter property View of "type" table is not returing JSON "filter" property there fore guard {views!.append(viewObject);continue}*/
            
            guard let filter = view["filter"] as? FilterArray else {views!.append(viewObject);continue}
            
            drillDownFilterObject = [Attribute]()
            
            for filterProperty in filter  {
            print("Working with filter")
            if let drilldown = filterProperty.value as? [String:AnyObject]{
                
                for drilldownProperty in drilldown {
                    
                    let attributeCode = drilldownProperty.key
                    let attribute = Attribute(code:attributeCode)
                    attribute.attributeValues = [(value:String,label:String?,rowindex:Int?)]()
                    
                    if let attributeCodeProperty = drilldownProperty.value as? [String:AnyObject] {
                        
                        for item in attributeCodeProperty {
                            
                            switch item.key {
                                
                                case "op": if let op = item.value as? String {attribute.op = op}
                            case "values": if let values = item.value as? [String] {
                                
                                for value in values {
                                    
                                    attribute.attributeValues?.append((value:value,label:String(),rowindex:nil))
                                    
                                }
                                
                                
                                 }
                            default: continue
                            }
                            
                        }
                        
                        
                    }
                    
                    drillDownFilterObject.append(attribute)
                    
                }
             viewObject.drillDownFilter = drillDownFilterObject //Assigning assembled drillDownFilterObject to viewObject
            }
                
            //Remove this test
                
                for attribute in drillDownFilterObject {
                
                print (attribute.code)
                }
            
                    }
        
            views!.append(viewObject)
                }
        
        
        for item in views! {
            print(item.viewName ?? "nil")
        }
        
        
        
        
    }

        
        
        
        
        
        
    
    
    
}
