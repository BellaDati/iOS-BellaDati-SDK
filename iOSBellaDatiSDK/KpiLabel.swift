//
//  KpiLabel.swift
//  BellaDatiSDK
//
//  Created by Martin Trgina on 2/24/17.
//  Copyright © 2017 BellaDati Inc. All rights reserved.
//

import Foundation
import UIKit


public class KpiLabel:View {
    
    public var cleverTitle:String?
    public var name:String?
    public var type:String?
    public var values:[KPILabelValue]?
    
    
    
    public override init(){
        
        
    }
    
    
    public class KPILabelValue {
        
        public var symbol = String()
        public var symbolValue = String()
        public var caption = String()
        public var style = String()
        public var numberValue = String()
        public var color = UIColor.black
        public var backgroundcolor = UIColor.clear
        public var fontweight = String()
        
    
        
        public init(){
            
        }
    }
    
    
    /* Uploads data from default Apps bundle --- only for testing now */
    
    func uploadSavedKpiLabels() {
        
        
        let testBundle = Bundle (for: type(of:self))
        let s = testBundle.url(forResource: "myjson", withExtension: "json")
        let data = NSData(contentsOf: s!)
        let string = try! String(contentsOf:s!, encoding: String.Encoding.utf8)
        print(string)
        
        do{
            
            let jsonObject = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments)
            
            if let dictionary = jsonObject as? [String:AnyObject] {
                readJSONObject (kpilabel: dictionary)
            }
        } catch {
            
        }
    }

    /* Downloads JSON definition of Chart object including Chart data */
    
    public func downloadOnLineKpiLabel(completion:(() -> ())? = nil) {
        
        
        let getData =
            
            {
                APIClient.sharedInstance.getData(service: APIClient.APIService.VIEWS, id: String(self.viewId!), urlSuffix: ["kpi"]){(getData) in
                    
                    do{
                        
                        let jsonObject = try JSONSerialization.jsonObject(with: getData! as Data, options: .allowFragments)
                        
                        if let dictionary = jsonObject as? [String:AnyObject] {
                            self.readJSONObject (kpilabel: dictionary)
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
    
    
    /* input parameter is style item of KpiLabel. It parses color value and backgroundcolor value. It sets
     KpiLable class color and background color values. These are set as UIColor object.*/
    
    public func parseValueStyle (style:String?) -> (color:(red:Int,green:Int,blue:Int),backgroundcolor:(red:Int,green:Int,blue:Int),fontweight:String){
        
        var color = (red:Int(),green:Int(),blue:Int())
        var backgroundcolor = (red:Int(),green:Int(),blue:Int())
        let fontweight = String()
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
                        
                        if colorrgbcharacter != "," && colorrgbcharacter != ";"{
                        
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

    /* reads JSON object and creates final Chart object */
    
    func readJSONObject(kpilabel:[String:AnyObject]) {
        
        
        var kpiLabelValue:KPILabelValue
        
        
        if let cleverTitle = kpilabel["cleverTitle"] as? String { self.cleverTitle = cleverTitle }
        else { self.cleverTitle = ""}
        
        if let name = kpilabel["name"] as? String { self.name = name } else { self.name = ""}
        
        if let type = kpilabel["type"] as? String { self.type = type } else { self.type = ""}
       
    
        
        
        if let kpiLabelValues = kpilabel["values"] as? [[String:AnyObject]] {
            
            
            self.values = [KPILabelValue]()
            
            for kpilabelitem in kpiLabelValues {
                
                kpiLabelValue = KPILabelValue()
                
                if let symbol = kpilabelitem["symbol"] as? String { kpiLabelValue.symbol = symbol}
                if let symbolValue = kpilabelitem["symbolValue"] as? String { kpiLabelValue.symbolValue = symbolValue}
                
                guard let caption = kpilabelitem["caption"] as? String,
                let style = kpilabelitem["style"] as? String,
                    let numberValue = kpilabelitem["numberValue"] as? String else { continue }
                
                kpiLabelValue.caption = caption
                kpiLabelValue.style = style
                kpiLabelValue.numberValue = numberValue
                
                let parsedstylevalues = self.parseValueStyle(style: style)
                
                
                kpiLabelValue.color = UIColor(red: CGFloat(parsedstylevalues.color.red) / 255.0, green: CGFloat(parsedstylevalues.color.green) / 255.0, blue: CGFloat(parsedstylevalues.color.blue) / 255.0, alpha: 1.0)
                
				kpiLabelValue.backgroundcolor = UIColor(red: CGFloat(parsedstylevalues.backgroundcolor.red) / 255.0, green: CGFloat(parsedstylevalues.backgroundcolor.green) / 255.0, blue: CGFloat(parsedstylevalues.backgroundcolor.blue) / 255.0, alpha: 1.0)
				
                kpiLabelValue.fontweight = parsedstylevalues.fontweight
                
                self.values?.append(kpiLabelValue)
                
            }
            
            
        }
        
        
    }
    
    
}
