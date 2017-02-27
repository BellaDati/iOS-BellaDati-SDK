//
//  Y_Axis.swift
//  BellaDatiSDK
//
//  Created by Martin Trgina on 2/17/17.
//  Copyright © 2017 BellaDati Inc. All rights reserved.
//

import Foundation

public class Y_Axis {
    
    public var color:String?
    public var gridcolor:String?
    public var steps:Double?
    public var hideGrid:Bool?
    public var min:Double?
    public var max:Double?
    public var labels = [(text:String(),value:Double(),color:String())]
    public var legend = (text:String(),style:String())
    
    public init(){
        
    }
    
}
