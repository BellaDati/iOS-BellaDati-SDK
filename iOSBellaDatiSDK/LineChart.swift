//
//  Chart.swift
//  BellaDatiSDK
//
//  Created by Martin Trgina on 2/16/17.
//  Copyright © 2017 BellaDati Inc. All rights reserved.
//

import Foundation

/*Supported charts are: LineChart */

public class LineChart:View{
    
    public var cleverTitle:String?
    public var chartId:String?
    public var bg_color:String?
    public var is_decimal_separator_comma:Int?
    public var is_thousand_separator_disabled:Int?
    public var tooltip = (mouse:String(),shadow:Bool(),stroke:Int(),color:String(),background:String())
    
    
    public var elements:[Element]?
    public var xAxis:X_Axis? // not all chart objects have axis
    public var yAxis:Y_Axis? // not all chart objects have axis
    
    
    
    public class Element {
        
        public typealias Value = (value:Double,tip:String,context:String)
        
       
        
        public var type:String?
        public var text:String?
        public var fontsize:Int?
        public var color:String?
        public var dotstyle = (dotsize:Int(),halosize:Int(),type:String())
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
    
    /* Downloads JSON definition of Chart object including Chart data */
    
    public func downloadOnLineChart(filter:String? = nil,completion:(() -> ())? = nil) {
        
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

    
    
    

    
    /* reads JSON object and creates final Chart object */
    
    func readJSONObject(content:[String:AnyObject]) {
        
        
        var elementObject:Element
        var xAxisObject:X_Axis
        var yAxisObject:Y_Axis
        
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
    
    let text = element["text"] as? String,
    let fontsize = element["font-size"] as? Int,
    let color = element["colour"] as? String
    else {continue} // will leave scope of for element. Than runs it for next element object
    
    elementObject = Element()
    
        elementObject.type = charttype
        elementObject.text = text
        elementObject.fontsize = fontsize
        elementObject.color =  color
    
    
    // getting values of dot-style JSON object. If there are no such objects it will end the elements forloop
    
    
    
        guard let dotstyle = element["dot-style"] as? [String:AnyObject] else { return }
        
        guard let dotsize = dotstyle["dot-size"] as? Int,
            let halosize =  dotstyle["halo-size"] as? Int,
            let dottype = dotstyle["type"] as? String else {return}
    
        elementObject.dotstyle = (dotsize,halosize,dottype)
     
    // getting values of values objects from element object in JSON
        
        guard let values = element["values"] as? [[String:AnyObject]] else { return }
        
        for valueobj in values {
            
        guard let value = valueobj["value"] as? Double,
            let tip = valueobj["tip"] as? String,
            let context = valueobj["context"] as? String else { return }
           
            elementObject.values.append((value,tip,context))
        
        }
        
    
       
    self.elements?.append(elementObject)
    
    }
    
    // X axis JSON data section. !Some charts do not have axis! So xaxis variable use guard. If it can not be set code below guard statement is not going to proceed
        
    
        guard let xaxis = chartcontent["x_axis"] as? [String:AnyObject] else { print("This is " + (self.elements?[0].type)! + "chart.It has got no axis"); return }
        
        xAxisObject = X_Axis() // creating instance of X_Axis object
        
        guard let xcolor = xaxis["colour"] as? String,
            let xgridcolor = xaxis["grid-colour"] as? String else { return }
           
        
        
        guard let xlabels = xaxis["labels"] as? [String:AnyObject] else { return }
            
        guard let xlabelscolor = xlabels["colour"] as? String else { return }
        
        // "labels" json value can be missing in case there are no xlabelsvalues
        
        if let xlabelvalues = xlabels["labels"] as? [String]{
        
            xAxisObject.labels = (xlabelvalues,xlabelscolor)
        } else {
            
            xAxisObject.labels = ([String](),xlabelscolor)
        }
        
        
        
        if let xsteps = xaxis["steps"] as? Double {
            
            xAxisObject.steps = xsteps
        } else {
            xAxisObject.steps = 0.0
        }
        
        // X-Axis object grid is hidden or not info
        
        if let xhidegrid = xaxis["hideGrid"] as? Bool{
            
             xAxisObject.hideGrid = xhidegrid
        } else {
          
            xAxisObject.hideGrid = false

        }
        
        xAxisObject.color = xcolor
        xAxisObject.gridcolor = xgridcolor
        
        // X Axis legend for X_Axis object setup
        
        if let xlegend = chartcontent["x_legend"] as? [String:AnyObject] {
            
            guard let text = xlegend["text"] as? String,
                let style = xlegend["style"] as? String else {return}
            
            xAxisObject.legend = (text,style)
        }
        
        // setting Chart's xAxis reference to recently created X_Axis object
        
    self.xAxis = xAxisObject
    
        // Y axis JSON data section
        
            
      guard let yaxis = chartcontent["y_axis"] as? [String:AnyObject] else { return }
        
        
         yAxisObject = Y_Axis() // creating instance of Y_Axis object
        
        guard let ycolor = yaxis["colour"] as? String,
            let ygridcolor = yaxis["grid-colour"] as? String,
            let ysteps = yaxis["steps"] as? Double,
            let ymin = yaxis["min"] as? Double,
            let ymax = yaxis["max"] as? Double else { return }
        
        
        // Y_Axis object must have properties setup
        
        yAxisObject.color = ycolor
        yAxisObject.gridcolor = ygridcolor
        yAxisObject.steps = ysteps
        yAxisObject.min = ymin
        yAxisObject.max = ymax
        
        
        guard let ylabels = yaxis["labels"] as? [String:AnyObject] else { return }
        
        guard let ylabelscolor = ylabels["colour"] as? String else {return}
        
        
        guard let ylabelvalues = ylabels["labels"] as? [[String:AnyObject]] else { return }
        
        for ylabelvalue in ylabelvalues {
            
            guard let value = ylabelvalue["y"] as? Double,
                let text = ylabelvalue["text"] as? String else { return }
            
            yAxisObject.labels.append((text,value,ylabelscolor))
            
            
        }
        
               
        // Y Axis legend for Y_Axis object setup
        
        if let ylegend = chartcontent["y_legend"] as? [String:AnyObject] {
            
            guard let text = ylegend["text"] as? String,
                let style = ylegend["style"] as? String else {return}
            
            yAxisObject.legend = (text,style)
        }

        // setting Chart's xAxis reference to recently created Y_Axis object
        
        self.yAxis = yAxisObject
        
}

}




