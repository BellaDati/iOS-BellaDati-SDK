//
//  PieChart.swift
//  BellaDatiSDK
//
//  Created by Martin Trgina on 3/11/17.
//  Copyright © 2017 BellaDati Inc. All rights reserved.
//

import Foundation

import Foundation

/*Supported charts are: LineChart */

public class PieChart:View{
    
    public var cleverTitle:String?
    public var chartId:String?
    public var bg_color:String?
    public var is_decimal_separator_comma:Int?
    public var is_thousand_separator_disabled:Int?
    public var tooltip = (mouse:String(),shadow:Bool(),stroke:Int(),color:String(),background:String())
    
    
    public var elements:[Element]?
    
    
    
    public class Element {
        
        public typealias Value = (value:Double,tip:String,context:String,highlight:String,label:String)
        
        
        
        public var type:String?
        public var fontsize:Int?
        public var colors:[String]?
        public var startangle:Int?
        public var values = [Value]()
        
        public init(){
            
        }
        
    }
    
    
    
    
    /* Uploads data from default Apps bundle --- only for testing now */
    
    func uploadSavedCharts() {
        
        
        let testBundle = Bundle (for: type(of:self))
        let s = testBundle.url(forResource: "myjson", withExtension: "json")
        let data = NSData(contentsOf: s!)
        let string = try! String(contentsOf:s!, encoding: String.Encoding.utf8)
        print(string)
        
        do{
            
            let jsonObject = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments)
            
            if let dictionary = jsonObject as? [String:AnyObject] {
                readJSONObject (content: dictionary)
            }
        } catch {
            
        }
    }
    
    /* Downloads JSON definition of Chart object including Chart data. NSError object in func
       signature contains Network Connection related error or server response error code, domain and localized message.If there is no error. NSError object is empty optional. This param can be for instance used to notify UI components about result of the function. */
    
    public func downloadOnLineChart(filter:String? = nil,completion:((_ error:NSError?) -> ())? = nil) {
        
        var paramsarray = [NSURLQueryItem]()
        
        if let filter = filter {
            
            paramsarray.append(NSURLQueryItem(name: "filter",value: filter))
            
        }

        
        let getData =
            
            {
                APIClient.sharedInstance.getData(service: APIClient.APIService.VIEWS, id: String(self.viewId!), urlSuffix: ["chart"],params: paramsarray){(getData,getError) in
                    
                    do{
                        
                        let jsonObject = try JSONSerialization.jsonObject(with: getData! as Data, options: .allowFragments)
                        
                        if let dictionary = jsonObject as? [String:AnyObject] {
                            self.readJSONObject (content: dictionary)
                        }
                        
                        
                        if let completionHandler = completion{
                            completionHandler(getError)
                        } else {
                            
                                                }
                        
                    } catch {
                        if let completionHandler = completion{
                            completionHandler(getError)
                    
                        }

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
    
    
    
    
    
    
    /* reads JSON object and creates final Chart object */
    
    func readJSONObject(content:[String:AnyObject]) {
        
        
        var elementObject:Element
        
        
        if let cleverTitle = content["cleverTitle"] as? String {
            
            self.cleverTitle = cleverTitle
        }
        
        guard let chartcontent = content["content"] as? [String:AnyObject] else {return}
        guard let chartid = chartcontent["chartId"] as? String
            //let bgcolor = chartcontent["bg_colour"] as? String
            else {
                return }
        
        //Fill values into the Chart object
        
        if let bgcolor = chartcontent["bg_colour"] as? String {
            
            self.bg_color = bgcolor
        } else {
            
            self.bg_color = "#ffffff"
        }
        
        
        if let is_decimal_separator_comma = chartcontent["is_decimal_separator_comma"] as? Int {
            self.is_decimal_separator_comma = is_decimal_separator_comma
        } else {
            self.is_decimal_separator_comma = 0
            
        }
        
        if let is_thousand_separator_disabled = chartcontent["is_thousand_separator_disabled"] as? Int {
            self.is_thousand_separator_disabled = is_thousand_separator_disabled
        } else {
            self.is_thousand_separator_disabled = 0
        }
        
        
        
        self.chartId = chartid
        
        
        
        guard let tooltip = chartcontent["tooltip"] as? [String:AnyObject] else {return}
        guard let mouse = tooltip["mouse"] as? String,
            let shadow = tooltip["shadow"] as? Bool,
            let stroke = tooltip["stroke"] as? Int,
            let color = tooltip["colour"] as? String,
            let background = tooltip["background"] as? String else {return}
        
        //Fill values into the tooltip object
        
        self.tooltip.mouse = mouse
        self.tooltip.shadow = shadow
        self.tooltip.stroke = stroke
        self.tooltip.color = color
        self.tooltip.background = background
        
        
        guard let elements = chartcontent["elements"] as? [[String:AnyObject]] else { print("No elements");return }
        
        self.elements = [Element]() // here we inicialize empty array of Element objects
        
        
        //elements array in JSON can have more elements in case of combined chart. It can be also empty
        
        for element in elements {
            
            guard let charttype = element["type"] as? String,
                
                let startangle = element["start-angle"] as? Int,
                let fontsize = element["font-size"] as? Int else {continue} // will leave scope of for element. Than runs it for next element object
            
            guard let colours = element["colours"] as? [String] else {continue}
                
            
            
            elementObject = Element()
            
            elementObject.type = charttype
            elementObject.startangle = startangle
            elementObject.fontsize = fontsize
            elementObject.colors =  colours
            
            
            
            
            // getting values of values objects from element object in JSON
            
            guard let values = element["values"] as? [[String:AnyObject]] else { return }
            
            for valueobj in values {
                
                guard let value = valueobj["value"] as? Double,
                    let tip = valueobj["tip"] as? String,
                    let context = valueobj["context"] as? String,
                    let label = valueobj["label"] as? String,
                    let highlight = valueobj["highlight"] as? String else { return }
                
                elementObject.values.append((value,tip,context,highlight,label))
                
            }
            
            
            
            self.elements?.append(elementObject)
            
        }
        
        
        
    }
    
}
