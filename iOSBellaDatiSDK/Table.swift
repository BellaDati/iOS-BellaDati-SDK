//
//  Table.swift
//  BellaDatiSDK
//
//  Created by Martin Trgina on 2/16/17.
//  Copyright © 2017 BellaDati Inc. All rights reserved.
//

import Foundation
import UIKit

public class Table:View {
    
    public var rowsCount = 0
    public var columnsCount = 0 //not provided by BellaDati JSON.Must be calculated
    public var header = [Row]()
    public var body = [Row]()
    
    
    
    public override init(){
    
    }
    
    public class Cell {
        
        public var drillDownLevel = 0
        public var index = 0 // Position of cell in the row
        public var rowspan = 1 // Through how many rows cell is spanning |  |.Default is 1
        public var colspan = 1 // Through how many cols cell is spanning  -.Default is 1. Colspan never happens to Cells in body [] of the table. But both colspan and rowspan can happen to Cells in the header []
        public var value  = String("")
        public var type = "cell" // value for regular cells
        public var style = String() // style available for cells of type="cell" otherwise empty String object
        public var color = UIColor()
        public var backgroundcolor = UIColor()
        
        public init(){
            
        }
        
        
        /* Value of cell returned in JSON can be  also &nbsp; or link information for web based application. We do not need these for native tables. This method will produce only clean value information such as 유효전력량 */
        
        public func cleanCellValue(value:String) -> String {
            
            var valuecharfield =  [Character]()
            
            var valuetoclean = value
            
            if value == "&nbsp;" {
                
                valuetoclean = ""
            }
            
            if valuetoclean.hasPrefix("<a class=\"tableDrillDown\""){
                
                var stop = false
                
                for (index,character) in valuetoclean.characters.enumerated() {
                    
                    
                    
                    if character == ">" && stop == false {
                        
                        
                        
                        let range = valuetoclean.startIndex..<valuetoclean.index(valuetoclean.startIndex, offsetBy: (index+5))
                        
                        valuetoclean.removeSubrange(range)
                        print(valuetoclean)
                        stop  = true
                        
                    }
                }
                
                
            }
            
        return valuetoclean
        }
        
    }
    
    
    
    public class Row {
        
        var row = [Cell]()
        
        public init(){
            
        }
        
    }
    
    /* Uploads data from default Apps bundle --- only for testing now */
    
    public func uploadSavedTabels() {
        
        
        let testBundle = Bundle (for: type(of:self))
        let s = testBundle.url(forResource: "myjson", withExtension: "json")
        let data = NSData(contentsOf: s!)
        let string = try! String(contentsOf:s!, encoding: String.Encoding.utf8)
        print(string)
        
        do{
            
            let jsonObject = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments)
            
            if let dictionary = jsonObject as? [String:AnyObject] {
                readJSONObject (table: dictionary)
            
            }
        } catch {
            
        }
    }
    
    /* Downloads JSON definition of Chart object including Chart data */
    
    public func downloadOnLineTabel(completion:(() -> ())? = nil) {
        
        
        let getData =
            
            {
                APIClient.sharedInstance.getData(service: APIClient.APIService.VIEWS, id: String(self.viewId!), urlSuffix: ["table","json"]){(getData) in
                    
                    do{
                        
                        let jsonObject = try JSONSerialization.jsonObject(with: getData! as Data, options: .allowFragments)
                        
                        if let dictionary = jsonObject as? [String:AnyObject] {
                            self.readJSONObject (table: dictionary)
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
    
    /* input parameter is style item of Cell. It parses color value and backgroundcolor value. It sets
     Cell class color and background color values. These are set as UIColor object.*/
    
    public func parseValueStyle (style:String?) -> (color:(red:Int,green:Int,blue:Int),backgroundcolor:(red:Int,green:Int,blue:Int),fontweight:String){
        
        var color = (red:Int(),green:Int(),blue:Int())
        var backgroundcolor = (red:Int(),green:Int(),blue:Int())
        var fontweight = String()
        var charfield =  [Character]()
        
        for character in (style?.characters)! {
            if character != " " && character != "(" && character != ")" && character != "#" {
                
                charfield.append(character)
                
                print (String(character))
                
            }
            
            if character == ";" {
                
                
                print (String(describing: charfield))
                print (String(charfield))
                if String(charfield).hasPrefix("color:rgb") == true {
                    
                    var colorrgbcharfield = [Character]()
                    
                    var colorrgb = String(charfield)
                    
                    let range = colorrgb.startIndex..<colorrgb.index(colorrgb.startIndex, offsetBy: 9)
                    
                    
                    colorrgb.removeSubrange(range)
                    
                    
                    
                    var whichcolorindex = 0
                    
                    for colorrgbcharacter in colorrgb.characters {
                        
                        if colorrgbcharacter != "," && colorrgbcharacter != "!"{
                            
                            colorrgbcharfield.append(colorrgbcharacter)
                            
                        } else {
                            
                            switch whichcolorindex{
                                
                            case 0: color.red = Int(String(colorrgbcharfield))!
                            case 1: color.green = Int(String(colorrgbcharfield))!
                            case 2: color.blue = Int(String(colorrgbcharfield))!
                            default: break
                                
                            }
                            
                            print(colorrgbcharfield)
                            colorrgbcharfield = [Character]()
                            whichcolorindex += 1
                        }
                        
                        
                        
                    }
                    
                    print ("Colorvalues:"+"\(color.red)"+","+"\(color.green)"+","+"\(color.blue)")
                    
                    
                }
                
                if String(charfield).hasPrefix("color:") == true && String(charfield).hasPrefix("color:rgb") == false {
                    
                    var colorhex = String(charfield)
                    
                    let range = colorhex.startIndex..<colorhex.index(colorhex.startIndex, offsetBy: 6)
                    
                    
                    colorhex.removeSubrange(range)
                    
                    let redcolorcode:String = String(colorhex[colorhex.startIndex]) + String(colorhex[colorhex.index(colorhex.startIndex, offsetBy:1)])
                    
                    color.red = Int(redcolorcode,radix:16)!
                    
                    let greencolorcode = String(colorhex[colorhex.index(colorhex.startIndex, offsetBy:2)]) + String(colorhex[colorhex.index(colorhex.startIndex, offsetBy:3)])
                    
                    color.green = Int(greencolorcode,radix:16)!
                    
                    let bluecolorcode = String(colorhex[colorhex.index(colorhex.startIndex, offsetBy:4)]) + String(colorhex[colorhex.index(colorhex.startIndex, offsetBy:5)])
                    
                    color.blue = Int(bluecolorcode,radix:16)!
                    
                    print ("Colorvalues:"+"\(color.red)"+","+"\(color.green)"+","+"\(color.blue)")
                    
                    
                }
                if String(charfield).hasPrefix("background-color:rgb") == true {
                    
                    var bgcolorrgb = String(charfield)
                    
                    var bgcolorrgbcharfield = [Character]()
                    
                    
                    let range = bgcolorrgb.startIndex..<bgcolorrgb.index(bgcolorrgb.startIndex, offsetBy: 20)
                    
                    
                    bgcolorrgb.removeSubrange(range)
                    
                    var whichcolorindex = 0
                    
                    for bgcolorrgbcharacter in bgcolorrgb.characters {
                        
                        if bgcolorrgbcharacter != "," && bgcolorrgbcharacter != ";"{
                            
                            bgcolorrgbcharfield.append(bgcolorrgbcharacter)
                            
                        } else {
                            
                            switch whichcolorindex{
                                
                            case 0: backgroundcolor.red = Int(String(bgcolorrgbcharfield))!
                            case 1: backgroundcolor.green = Int(String(bgcolorrgbcharfield))!
                            case 2: backgroundcolor.green = Int(String(bgcolorrgbcharfield))!
                            default: break
                                
                            }
                            
                            
                            bgcolorrgbcharfield = [Character]()
                            whichcolorindex += 1
                        }
                        
                        
                        
                    }
                    
                    print ("Colorvalues:"+"\(color.red)"+","+"\(color.green)"+","+"\(color.blue)")
                    
                    
                    
                }
                if String(charfield).hasPrefix("background-color:") == true && String(charfield).hasPrefix("background-color:rgb") == false {
                    
                    var bgcolorhex = String(charfield)
                    
                    
                    
                    let range = bgcolorhex.startIndex..<bgcolorhex.index(bgcolorhex.startIndex, offsetBy: 17)
                    
                    
                    bgcolorhex.removeSubrange(range)
                    
                    let redcolorcode = String(bgcolorhex[bgcolorhex.startIndex]) + String(bgcolorhex[bgcolorhex.index(bgcolorhex.startIndex, offsetBy:1)])
                    
                    backgroundcolor.red = Int(redcolorcode,radix:16)!
                    
                    let greencolorcode = String(bgcolorhex[bgcolorhex.index(bgcolorhex.startIndex, offsetBy:2)]) + String(bgcolorhex[bgcolorhex.index(bgcolorhex.startIndex, offsetBy:3)])
                    
                    backgroundcolor.green = Int(greencolorcode,radix:16)!
                    
                    let bluecolorcode = String(bgcolorhex[bgcolorhex.index(bgcolorhex.startIndex, offsetBy:4)]) + String(bgcolorhex[bgcolorhex.index(bgcolorhex.startIndex, offsetBy:5)])
                    
                    backgroundcolor.blue = Int(bluecolorcode,radix:16)!
                    
                    print ("Colorvalues:"+"\(backgroundcolor.red)"+","+"\(backgroundcolor.green)"+","+"\(backgroundcolor.blue)")
                    
                    
                }
                if String(charfield).hasPrefix("font-weight:") == true {
                    
                    var fontweight = String(charfield)
                    let range = fontweight.startIndex..<fontweight.index(fontweight.startIndex, offsetBy: 12)
                    
                    fontweight.remove(at: fontweight.index(before:fontweight.endIndex))
                    fontweight = String(describing: fontweight.removeSubrange(range))
                    
                }
                
                charfield = [Character]()
                
            }
            
        }

        return (color,backgroundcolor,fontweight)
    }
    
    
    

    
    /* reads JSON object and creates final Table object */
    
    func readJSONObject(table:[String:AnyObject]) {
        
        guard let rowsCount = table["rowsCount"] as? Int,
              let name = table["name"] as? String else {return}
        
        self.rowsCount = rowsCount
        self.viewName  = name
        
        
        if let header = table["header"] as? [[[String:AnyObject]]] {
            
            for row in header {
                
                let rowobject = Row()
                
                for cell in row {
                    
                    let cellobject = Cell()
                    
                    if let index = cell["i"] as? Int { cellobject.index = index }
                    if let ddLevel = cell["ddLevel"] as? Int { cellobject.drillDownLevel = ddLevel }
                    if let rowspan = cell["rowspan"] as? Int { cellobject.rowspan = rowspan }
                    if let colspan = cell["colspan"] as? Int { cellobject.colspan = colspan }
                    if let value = cell["value"] as? String { cellobject.value = cellobject.cleanCellValue(value:value) }
                    if let type = cell["type"] as? String { cellobject.type = type }
                    if let style = cell["style"] as? String {
                        
                        cellobject.style = style
                        
                        let parsedstylevalues = self.parseValueStyle(style: style)
                        
                        
                        cellobject.color = UIColor(red: CGFloat(parsedstylevalues.color.red/255) , green: CGFloat(parsedstylevalues.color.green/255), blue:CGFloat(parsedstylevalues.color.blue/255) , alpha: 1.0)
                        
                        cellobject.backgroundcolor = UIColor(red: CGFloat(parsedstylevalues.backgroundcolor.red/255) , green: CGFloat(parsedstylevalues.backgroundcolor.green/255), blue:CGFloat(parsedstylevalues.backgroundcolor.blue/255) , alpha: 1.0)
                    
                    
                    }
                    
                    rowobject.row.append(cellobject)
                    
                        }
                  self.header.append(rowobject)
                }
                
            }
            
        
        
        if let body = table["body"] as? [[[String:AnyObject]]] {
        
            for row in body {
                
                let rowobject = Row()
                
                for cell in row {
                    
                    let cellobject = Cell()
                    
                    if let index = cell["i"] as? Int { cellobject.index = index }
                    if let ddLevel = cell["ddLevel"] as? Int { cellobject.drillDownLevel = ddLevel }
                    if let rowspan = cell["rowspan"] as? Int { cellobject.rowspan = rowspan }
                    if let colspan = cell["colspan"] as? Int { cellobject.colspan = colspan }
                    if let value = cell["value"] as? String { cellobject.value = cellobject.cleanCellValue(value:value) }
                    if let type = cell["type"] as? String { cellobject.type = type }
                    if let style = cell["style"] as? String {
                        
                        cellobject.style = style
                        
                        let parsedstylevalues = self.parseValueStyle(style: style)
                        
                        
                        cellobject.color = UIColor(red: CGFloat(parsedstylevalues.color.red/255) , green: CGFloat(parsedstylevalues.color.green/255), blue:CGFloat(parsedstylevalues.color.blue/255) , alpha: 1.0)
                        
                        cellobject.backgroundcolor = UIColor(red: CGFloat(parsedstylevalues.backgroundcolor.red/255) , green: CGFloat(parsedstylevalues.backgroundcolor.green/255), blue:CGFloat(parsedstylevalues.backgroundcolor.blue/255) , alpha: 1.0)
                        
                        
                        
                        
                    }
                    
                    rowobject.row.append(cellobject)
                    
                }
                self.body.append(rowobject)
            }
            
           }
    
    
    }
    
}
