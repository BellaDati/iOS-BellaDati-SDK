//
//  OAuth1a.swift
//  iOSBellaDatiSDK
//
//  Created by Martin Trgina on 8/23/16.
//  Copyright © 2016 BellaDati Inc. All rights reserved.
//

import Foundation

/// This class was desined to handle the signing of the xAuth request towards
/// the BellaDati. It is not making requests themself. BellaDati is using PLAINTEXT
/// method to sign signature base string. No implementation of o_auth_signature
/// parameter is neccessary (no encoding of signature base string, no encryption
/// using key is neccesary. Each request object is only signed with oAuth header
/// parameters.
struct OAuth1a {
    
    var oauthConsumerKey: String
    var oauthToken: String
	
	init(oauthConsumerKey: String, oauthToken: String){
        self.oauthConsumerKey = oauthConsumerKey
		self.oauthToken = oauthToken
    }
    
    /// Signed signiture in BellaDati is only PLAINTEXT.request string. It contains
	/// for instance http://service.belladati.com/api/reports/:id and Query part
	/// is http:/service.belladati.com/api/reports/:id?width=10,height=10 and
	/// oAuth parameters in request header are in the header
    func signRequest(request: inout URLRequest, urlQueryParameters: [NSURLQueryItem] = []){

		let baseUrl = request.url!.absoluteString
		let oauth_timestamp = String(Int(NSDate().timeIntervalSince1970))
        let oauth_nonce = UUID().uuidString
		
        print("REQUEST URL: " + baseUrl)
        print("TIMESTAMP: " + oauth_timestamp)
        print("NONCE: " + oauth_nonce)
        
        
        // BellaDati implements PLAINTEXT signature. No encoding or encrypting
		// is neccessary by consumer (consumer is our app). In this step we will
		// populate OAuth1Header.class with oauth params. Exact order of parameters
		// is not important!
        var headerParameters = OAuth1Header(name: "OAuth")
        headerParameters.add(key: "oauth_consumer_key", value: self.oauthConsumerKey)
        headerParameters.add(key: "oauth_nonce", value: oauth_nonce)
        headerParameters.add(key: "oauth_timestamp", value: oauth_timestamp )
        headerParameters.add(key: "oauth_token", value: self.oauthToken)
        
        
        // In this step we will add oAuthHeader to the header of each request
		// object that we have from APIClient class
        request.addValue(headerParameters.asString(), forHTTPHeaderField: "Authorization")
    }
    
}



// OAuthHeader struct puts togather correctly the header entry and escapes the values.
struct OAuth1Header {
    
    var hName: String
    var params: [String]
    
    init(name: String) {
        self.params = []
        self.hName = name
    }
    
	mutating func add(key: String, value: String) {
        self.params.append(key + "=\"" + value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! + "\"")//(.URLHostAllowedCharacterSet())! + "\"")
    }
    
    func asString() -> String {
        let hParams = params.joined(separator: ",")
        return hName + " " + hParams
    }
	
}


