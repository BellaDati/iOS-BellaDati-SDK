//
//  APIClient.swift
//  iOSBellaDatiSDK
//
//  Created by Martin Trgina on 8/25/16.
//  Copyright © 2016 BellaDati Inc. All rights reserved.
//



import Foundation

/**
 
 - This class makes API requests. It connects to BellaDati API. Important notes about BellaDati API follow
 
 - The API service calls have service names and values mashed up in slesh delimited string. Example /api/import/forms/:id = /api/service/service/number
 
 - Copyright © 2016 BellaDati Inc. All rights reserved.
 
 */

public class APIClient {
    
    
    private var baseURL = "/belladati/api" // /belladati/api /api
    private var relativeAccessTokenURL = "/belladati/oauth/accessToken" // /belladati/oauth/accessToken /oauth/accessToken
    private var oauth_consumer_key = "apikey" //apikey frameworkforms
    private var scheme:String = "http" //BellaDati server protocol
    private var host:String = "BellaDatiMac.local" //BellaDati server address
    private var port:NSNumber = 443 //BellaDati server port
    private var x_auth_username: String = "yourusername@belladati.com" //BellaDati server username
    private var x_auth_password: String = "yourpassword" //BellaDati server user password
    
    private var oauth_timestamp = String(Int(NSDate().timeIntervalSince1970))
    private var oauth_nonce = NSUUID().uuidString
    private let encoding = String.Encoding.utf8
    private var oauthHandler: OAuth1a!
    private let session =  URLSession(configuration: URLSessionConfiguration.ephemeral)
    private var o_authtoken: String?
    
    /// Locale the APIClient loads everything in. The client automatically appends
    /// the locale identifier as the lang parameter to all requests. If you want
    /// to force a different locale, change this parameter.
    public var locale: Locale = Locale.autoupdatingCurrent
    
    let  settings = UserDefaults.standard
    var  OAuthTokenCompletionHandler:((_ error:NSError?,String?) -> Void)?
    
    
    /** 
     - We have only one BellaDati API to interact with. APIClient is available as sigleton trough sharedInstance constant
     - From your app you can get access to methods of APIClient class by using APIClient.sharedInstance
     */
    
    public static let sharedInstance = APIClient()
    
    private init() {
        
        if let savedAcessToken = settings.object(forKey: "AccessToken") as? String {
            
            o_authtoken = savedAcessToken
            
            print("APIClient Singletone Message: I have found access token stored on device:\(o_authtoken ?? "nil").Let's build requests!")
            
        } else {
            
            print("APIClient Singletone Message: Access Token Value is not yet stored on device.Call my authenticateWithBellaDati func")
        }
        
    }
    
    /**
     
     - Before calling authenticateWithBellaDati func user has to setup credentials important for authentication process
     - authenticateWithBellaDati function will use these credentials
     
     */
    
    
    public func setAPIClient(scheme:String,host:String,port:NSNumber,base_url: String,relativeAccessTokenUrl:String, oauth_consumer_key: String, x_auth_username: String,x_auth_password: String){
        
        self.scheme = scheme
        self.host = host
        self.port = port
        self.relativeAccessTokenURL = relativeAccessTokenUrl
        self.oauth_consumer_key = oauth_consumer_key
        self.x_auth_username = x_auth_username
        self.x_auth_password = x_auth_password
        self.baseURL = base_url
        
    }
    
    
    
    
    
    
    /**
     - authenticateWithBellaDati function takes belladati constructs the OAuth 1.0 x_Auth type of request using parameters. The output is new oAuthAcessToken. Run this method prior
     to using other APIClient methods. 
     - authenticateWithBellaDati function is using APIClient private authentication credentials
     - use setAuthenticationCredentials function to setup values of credentials prior to calling authenticateWithBellaDati
     - authenticateWithBellaDati can be called by user, but it is also called by function of framework classes (only in case when client is not yet authenticated with BellaDati
     - for instance in function downloadListOfReports in Reports.swift class func will call authenticateWithBellaDati. Prior to that call you should call setApiClient somewhere in your application to set the right credentials
     
     */
    
    public func authenticateWithBellaDati(completionBlock: ((NSError?) -> Void)?) {
        
        print("authenticateWithBellaDati:Starting...")
        
        //Compose the complete accessTokenURL including Query part
        
        let completeAccessTokenUrl = NSURLComponents()
        completeAccessTokenUrl.scheme = scheme
        completeAccessTokenUrl.host = host
        completeAccessTokenUrl.port = port
        completeAccessTokenUrl.path = relativeAccessTokenURL
        
        
        completeAccessTokenUrl.queryItems = [NSURLQueryItem(name: "oauth_consumer_key",value: "\(oauth_consumer_key)") as URLQueryItem,
                                             NSURLQueryItem(name: "oauth_nonce",value: "\(oauth_nonce)") as URLQueryItem,
                                             NSURLQueryItem(name: "oauth_timestamp",value: "\(oauth_timestamp)") as URLQueryItem,
                                             NSURLQueryItem(name: "x_auth_username",value: "\(x_auth_username)") as URLQueryItem,
                                             NSURLQueryItem(name: "x_auth_password",value: "\(x_auth_password)") as URLQueryItem]
        
        
        
        //Create URL Request object
        
        let request = NSMutableURLRequest(url:completeAccessTokenUrl.url!)
        
        print("The request is:\(request)")
        
        request.httpMethod = "GET"
        
        //Prepare new nounce and timestamp
        
        oauth_timestamp = String(Int(NSDate().timeIntervalSince1970))
        oauth_nonce = NSUUID().uuidString
        
        // Ask NSURLSessionObject for NSSessionTask Object. Once task is finished run responseDataProcessor function
        
        
        
        let startAutheticationTask = session.dataTask(with: request as URLRequest) {(data:Data?,response:URLResponse?,networkError:Error?) in
            // If there is some kind of network connection problem, we will return controll to the APIClient class
            if networkError != nil {
                
                
                if let completionHandler = completionBlock {
                    let connectionError = NSError(domain: "Network Error", code: networkError!._code, userInfo: [NSLocalizedDescriptionKey : self.handleNetworkConnectivityError(error: networkError! as NSError)])
                    
                    
                    
                    
                    completionHandler(connectionError)
                }
                
                
                return
            }
            
            guard let bodyData = data, let responseBody = String(data: bodyData, encoding: self.encoding) else {
                // Either data is nil, or we can't use this encoding for reading
                // the data into string.
                completionBlock?(NSError(domain: NSCocoaErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Received invalid data."]))
                return
            }
            
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            
            
            /*In case of response code 200 parse accessToken from received data and create new oAuthHandler updated with new accessToken value */
            
            if (statusCode == 200){
                
                self.o_authtoken = self.parseAccessToken(oauthTokenAndSecret: data as NSData?)
                
                self.settings.set(self.o_authtoken, forKey: "AccessToken")
                
                print("authenticateWithBellaDati message: Access Token \(self.o_authtoken ?? "nil") has been stored on device into NSUserDefaults")
                
                self.oauthHandler = OAuth1a(oauthConsumerKey: self.oauth_consumer_key, oauthToken: self.o_authtoken!)
            }
            
            /* If we have token already. Handler will receive nil. No errors. Otherwise*/
            
            if self.hasOAuthToken()
            {
                if let completionHandler = completionBlock
                {
                    completionHandler(nil)
                }
            }
            else {
                if let completionHandler = completionBlock {
                    let responseError = self.handleErrorResponse(code: statusCode, and: responseBody as NSString)
                    let oauthError = NSError(domain: "BellaDati REST API", code: statusCode, userInfo: [NSLocalizedDescriptionKey : responseError])
                    
                    
                    
                    
                    completionHandler(oauthError)
                }
            }
        }
        
        
        
        
        //NSSessionTask objects are born suspended. resume it
        
        startAutheticationTask.resume()
        
        
    }
    
    /** hasOAuthToken check if o_authtoken var in instance of APIClient class already has value of token */
    
    public func hasOAuthToken() -> Bool{
        
        if let token = self.o_authtoken
        {
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: "hasOAuthToken")
            return !token.isEmpty
        }
        return false
    }
    
    
    /** hasAccessTokenSaved check if AccessTokenValue is saved in NSUserDefault. If yes we do not have to call authenticateWithBellaDati */
    
    public func hasAccessTokenSaved() -> Bool{
        
        if let token = settings.object(forKey: "AccessToken") as? String {
            print("APIClient Message:I have found access token stored on device:\(token).You can build requests!")
            return !token.isEmpty
        }
        
        //print("APIClient Message:Access Token Value is not yet stored on device.Ask me to authenticateWithBellaDati")
        return false
    }
    
    
    
    /** parseAccessToken parses oAuthAccessToken from joined accessToken&accessToken string that we received as response from BellaDati service */
    
    func parseAccessToken(oauthTokenAndSecret:NSData?) -> String {
        
        
        
        let oauthTokenAndSecret = NSString(data: oauthTokenAndSecret! as Data, encoding: self.encoding.rawValue)!.components(separatedBy: "&")
        let accessToken = (oauthTokenAndSecret[0].components(separatedBy:"="))[1]
        print("BellaDati Service Access Token is:"+" "+accessToken)
        
        return String(accessToken)
    }
    
    /** Currently only xAuth is supported.OAuth Token secret is not used in current Authentication process */
    
    func parseAccessTokenSecret(oauthTokenAndSecret:NSData?) -> String {
        
        let oauthTokenAndSecret = NSString(data: oauthTokenAndSecret! as Data, encoding: self.encoding.rawValue)!.components(separatedBy: "&")
        let accessTokenSecret = (oauthTokenAndSecret[1].components(separatedBy:"=")[1])
        print("BellaDati Service Access Token Secret is:"+" "+accessTokenSecret)
        return accessTokenSecret
    }
    
    
    /// This function does actual API Request. It calls OAuth signing and verification
    /// of response data.
    ///
    /// - Parameters:
    ///   - service: decides which API service we use, for instance /api/reports
    ///   - method: GET or POST method.
    ///   - id: id
    ///   - urlSuffix: includes URL that leads to right service resources. Example:
    ///					/api/reports service is defined in APIService parameter and
    ///					urlSuffix adds comments component to form /api/reports/comments
    ///					service call
    func apiRequest(service: APIService, method: APIMethod, id: String!, urlSuffix: [String]?, urlQueryParams: [NSURLQueryItem] = [], httpBodyData: Data? = nil, multipartformParams: [String : String]? = nil, callback: ((_ responseData: NSData?, _ resposeError: NSError?) -> Void)?) {
        // Compose the base URL
        var restServiceURL = URLComponents()
        restServiceURL.scheme = self.scheme
        restServiceURL.host = self.host
        restServiceURL.port = self.port.intValue
        restServiceURL.path = self.baseURL + "/" + service.toString()
        
        if id != nil && !id.isEmpty {
            restServiceURL.path.append("/" + id)
        }
        
        // urlSuffix array contains components that we use to build final URL.
        // For example api/users/:id/status should be final call. So "status"
        // will be stored in urlSuffix. While "users" is service take from
        // service param and ":id" is take from id param
        
        if let suffixComponents = urlSuffix, !suffixComponents.isEmpty {
            print("URLSuffix: \(suffixComponents)")
            restServiceURL.path.append("/" + suffixComponents.joined(separator: "/"))
            print("URLComponents: \(restServiceURL)")
        }
        
        
        // Add a language parameter.
        var queryItems = urlQueryParams as [URLQueryItem]
        
        // We need to add the locale language code.
        if let language = self.locale.languageCode {
            queryItems.append(URLQueryItem(name: "lang", value: language))
        }
        
        restServiceURL.queryItems = queryItems
        print("REQUEST URL (query items):" + restServiceURL.description)
        
        guard let url = restServiceURL.url else {
            print("**** Invalid URL: \(restServiceURL)")
            callback?(nil, NSError(domain: NSCocoaErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL."]))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.toString()
        request.httpShouldHandleCookies = false
        
        // Here JSON data serialized into the NSObject are set into the HTTBody.
        // Actual implementation is done in classes, that post some data/pictures
        // for example ReportDetail.swift, DataSets.swift etc.
        if var fullData = httpBodyData {
            // In case we are sending picture attached to an value of the attribute
            // using DATASETS service. We are using forms with binary content multipart/form-data
            
            if (service == APIService.DATASETS && method == APIMethod.POST) || (service == APIService.REPORTS && method == APIMethod.POST) {
                
                if urlSuffix?.first != "comments" {
                    let boundary = generateBoundaryString()
                    fullData = photoDataToFormData(data: httpBodyData!,boundary:boundary,fileName:(multipartformParams?["filename"]!)!,viewName:(multipartformParams?["viewName"]!)!)
                    
                    request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                    request.addValue(String(describing: httpBodyData?.count), forHTTPHeaderField: "Content-Length")
                    
                    print("Done with file")
                }
            }
            
            request.httpBody = fullData
        }
        
        // In case we are dealing with forms we have to add value to the request
        // - for IPORTFORMS
        if service == APIService.IMPORTFORMS && method == APIMethod.POST {
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }
        
        // In case we are dealing with forms we have to add value to the request
        // - for REPORTS sending comments
        if service == APIService.REPORTS, method == APIMethod.POST, urlSuffix?.first == "comments" {
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }
        
        
        self.apiRequest(with: request, callback: callback)
    }
    
    /// This function performs an actual API Request. It calls OAuth signing and
    /// verification of response data.
    ///
    /// - Parameters:
    ///   - url: URL to perform the request with.
    ///   - method: GET or POST method.
    ///	  - httpBodyData: optionally, HTTP body of the request.
    public func apiRequest(with originalRequest: URLRequest, callback: ((_ responseData: NSData?, _ resposeError: NSError?) -> Void)?) {
        guard let oAuthToken = self.o_authtoken else {
            callback?(nil, NSError(domain: NSCocoaErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Not authenticated."]))
            return
        }
        
        var request = originalRequest
        
        self.oauthHandler = OAuth1a(oauthConsumerKey: self.oauth_consumer_key, oauthToken: oAuthToken)
        self.oauthHandler.signRequest(request: &request)
        
        // Now we can make the request. Ask URLSession for URLSessionDataTask object.
        // Once task is finished run the closure and set data for callback closure.
        
        print ("Preparing to send request")
        
        let apiRequestTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if let error = error {
                let connectionError = NSError(domain: "Network Error", code: error._code, userInfo: [
                    NSLocalizedDescriptionKey: self.handleNetworkConnectivityError(error: error as NSError)
                    ])
                
                callback?(data as NSData?, connectionError)
                return
            }
            
            
            // Here we implemented some of the error codes, that BellaDati returns
            // during the HTTP response-request process
            guard let bodyData = data, let responseBody = String(data: bodyData, encoding: self.encoding), let httpResponse = response as? HTTPURLResponse else {
                // Either data is nil, or we can't use this encoding for reading
                // the data into string.
                callback?(data as NSData?, NSError(domain: NSCocoaErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Received invalid data."]))
                return
            }
            
            
            let statusCode = httpResponse.statusCode
            switch statusCode {
            case 200:
                // Request response code 200 means success. Error object is kept
                // as empty Optional.
                callback?(bodyData as NSData, error as NSError?)
                print("Response:" , String(data: bodyData, encoding: .utf8) ?? "nil")
            case 400 ..< 500:
                let responsemsg = self.handleErrorResponse(code: statusCode, and: responseBody as NSString)
                let apiServiceError = NSError(domain: "Api Service Error", code: statusCode, userInfo: [NSLocalizedDescriptionKey : "Unable to receive data - " + responsemsg])
                callback?(bodyData as NSData, apiServiceError as NSError)
            default:
                let responsemsg  = self.handleErrorResponse(code: statusCode, and: responseBody as NSString)
                let apiServiceError = NSError(domain: "Api Service Error", code: statusCode, userInfo: [NSLocalizedDescriptionKey : "Unable to receive data - " + responsemsg])
                callback?(bodyData as NSData, apiServiceError as NSError)
                print("Server error: \(statusCode)")
            }
        }
        
        apiRequestTask.resume()
    }
    
    
    /**
     
     urlSuffix: has nil as default value. So we do not have to provide nil parameters. For instance when we would be calling only root service like /api/reports
     id: for example call /api/reports/:id includes number and id of the report. However some calls do not include id. So id is by default nil
     
     */
    
    public func getData(service: APIService, id: String! = nil, urlSuffix: [String]? = nil, params: [NSURLQueryItem]! = [],callback: ((_ data:NSData?,_ error:NSError?) -> ())?) {
        self.apiRequest(service: service, method: APIMethod.GET, id: id, urlSuffix: urlSuffix, urlQueryParams:params) {(responseData, responseError) -> Void in
            if let error = responseError  {
                print(error)
                callback?(nil, error)
            } else {
                callback?(responseData, responseError)
            }
        }
    }
    
    
    
    func processGETData (service:APIService,id:String!,urlSuffix: NSArray!,params: [NSURLQueryItem]!=[],responseData:NSData!)  {
        
        
        /*if service == APIService.IMPORTFORMS {
         
         var forms = ImportForms()
         forms.uploadLiveData(responseData)
         
         var i = forms.filterByID(nil)![3]?.name
         print("Id is\(i!)")
         }*/
        
        
        
    }
    
    
    
    
    public func postData(service: APIService, id: String! = nil, urlSuffix: [String]? = nil, params: [NSURLQueryItem]!=[], httpBodyData:Data? = nil, multipartFormParams:[String:String]? = nil, callback: ((NSData?) -> ())?){
        
        
        self.apiRequest(service: service, method: APIMethod.POST, id: id, urlSuffix: urlSuffix, urlQueryParams: params,httpBodyData: httpBodyData,multipartformParams: multipartFormParams) {(responseData, resposeError) -> Void in
            
            if (resposeError != nil) {
                print(resposeError!.description)
            }
                
            else {
                
                if let completionHandler = callback {
                    
                    completionHandler(responseData)
                    
                    
                }
            }
            
        }
        
    }
    
    
    
    func processPOSTData (service:APIService,id:String!,urlSuffix: [String]? = nil,params: [NSURLQueryItem]!=[],responseData:NSData!){
        
        
        //Let's do something with data here
        
    }
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
    
    
    /* Boundry string generator is used for photoDataToFormData  func */
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    /* Method to get picture data and assemble it's data as an URL form */
    
    func photoDataToFormData(data:Data,boundary:String,fileName:String,viewName:String) -> Data {
        var fullData = Data()
        
        // 1 - Boundary should start with --
        let lineOne = "--" + boundary + "\r\n"
        fullData.append(lineOne.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        // 2
        let lineTwo = "Content-Disposition: form-data; name=\"file\"; filename=\"" + fileName + "\"\r\n"
        
        fullData.append(lineTwo.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        
        // 3
        let lineThree = "Content-Type: image/jpg\r\n\r\n"
        fullData.append(lineThree.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        // 4
        fullData.append(data)
        
        // 5
        let lineFive = "\r\n"
        fullData.append(lineFive.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        // 6 - The end. Notice -- at the start and at the end
        let lineSix = "--" + boundary + "\r\n"
        fullData.append(lineSix.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        let lineSeven = "Content-Disposition: form-data; name=\"name\"\r\n\r\n"
        
        fullData.append(lineSeven.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        let lineEight = "\(viewName)\r\n"
        
        fullData.append(lineEight.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        
        let lineNine = "--" + boundary + "--\r\n"
        fullData.append(lineNine.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        print(String(data:fullData,encoding:String.Encoding.utf8) ?? "nil")
        return fullData
    }
    
    
    
    /** BellaDati REST API is using GET and POST methods*/
    
    public enum  APIMethod {
        case GET,POST
        
        func toString() -> String {
            
            var method: String!
            
            switch self {
                
            case .GET: method = "GET"
            case .POST: method = "POST"
            }
            
            return method
        }
    }
    
    /** BellaDati list of API services */
    
    public enum APIService {
        
        case IMPORTFORMS
        case USERDETAIL
        case USER
        case DOMAIN
        case DATASETS
        case REPORTS
        case VIEWS
        
        
        func toString() -> String {
            let service: String
            switch self {
            case .IMPORTFORMS:
                service = "import/forms"
            case .USERDETAIL:
                service = "users/username"
            case .USER:
                service = "users"
            case .DOMAIN:
                service = "domains"
            case .DATASETS:
                service = "dataSets"
            case .REPORTS:
                service = "reports"
            case .VIEWS:
                service = "reports/views"
            }
            
            return service
        }
        
        
    }
    
    
    
    
    /* List of BADOAUTHREQUEST errors. These are received in BODY of the response from BellaDati service */
    
    struct BadOAuthRequest {
        
        
        static var USER_NOT_FOUND = "oauth_problem=user_not_found"
        static var USER_LOGIN_FAILD = "oauth_problem=user_login_failed"
        static var INVALID_CONSUMER_KEY = "oauth_problem=invalid_consumer"
        static var TOO_MANY_LOGIN_FAILURES = "oauth_problem=too_many_login_failures"
        
    }
    
    /* List of APIService error codes. These are received from BellaDati service */
    
    struct APIServiceError {
        
        
        static var BADINPUTPARAMETER = 400
        static var BADOREXPIREDTOKEN = 401
        static var BADOAUTHREQUEST = 403
        static var FILEFOLDERNOTFOUND = 404
        static var UNEXPECTEREQUESTMETHOD = 405
        static var SERVERERROR = 500
        static var APPTOOMANYREQUESTS = 503
        
        
    }
    
    /*Not yet implemented into the handleNetworkConnectivity method*/
    
    struct networkConnectivityErrors {
        
        static var NETWORKCONNECTIONLOST = -1005
        static var NOTCONNECTEDTOINTERNET = -1009
        static var CANNOTFINDHOST = -1003
        static var CANNOTCONNECTTOHOST = -1004
        static var DATANOTALLOWED = -1020
        static var ROAMINGOFF = -1018
        static var TIMEOUT = -1001
        
        
    }
    
    
    
    
    /** handleErrorResponse function handle error response codes send by BellaDati service */
    
    public func handleErrorResponse (code: Int, and body:NSString) -> String{
        
        var errorMessage: String? = nil
        
        // BADOAUTHREQUEST response body is analyzed for particular errors
        
        let investigateBadOAuthRequest =  {(body:NSString) in
            
            let noencodingbody = body.removingPercentEncoding!
            var comment: [String] = noencodingbody.components(separatedBy: "=")
            if noencodingbody.contains(BadOAuthRequest.USER_NOT_FOUND) {
                
                errorMessage = "Wrong user name:\(comment[2])"
                print("Wrong user name:\(comment[2])")
                
            }
            if noencodingbody.contains(BadOAuthRequest.USER_LOGIN_FAILD){
                
                errorMessage = "Wrong password"
                print("Wrong password")
                
            }
            if noencodingbody.contains(BadOAuthRequest.INVALID_CONSUMER_KEY){
                errorMessage = "Authentication failure"
                print("Invalid consumer key")
                
            }
            
            if noencodingbody.contains(BadOAuthRequest.TOO_MANY_LOGIN_FAILURES){
                errorMessage = "Too many login failures"
                print("Too many login failures")
                
            }
            
        }
        
        
        
        
        // Here we are handling all server response errors produced by client
        
        if (code >= APIServiceError.BADINPUTPARAMETER && code < APIServiceError.SERVERERROR ){
            
            switch (code) {
            case APIServiceError.BADINPUTPARAMETER: print ("Client error:"+"\(code)"+" \(body)");errorMessage = "Unable to receive data"
            case APIServiceError.BADOREXPIREDTOKEN: print ("Client error:"+"\(code)"+" \(body)");errorMessage = "Unable to receive data"
            case APIServiceError.FILEFOLDERNOTFOUND: print ("Client error:"+"\(code)"+" \(body)");errorMessage = "Unable to receive data"
            case APIServiceError.UNEXPECTEREQUESTMETHOD: print ("Client error:"+"\(code)"+" \(body)");errorMessage = "Unable to receive data"
            case APIServiceError.BADOAUTHREQUEST: investigateBadOAuthRequest(body)
                
            case APIServiceError.APPTOOMANYREQUESTS: print ("Your app is sending too many requests");errorMessage = "Unable to receive data"
                
            default:errorMessage = "Unable to receive data"
                
            }
            
            // Here we are handling all server response errors produced by server
            
            if (code >= APIServiceError.SERVERERROR ){
                switch (code) {
                case APIServiceError.APPTOOMANYREQUESTS: print ("Your app is sending too many requests");errorMessage = "Unable to receive data"
                default:errorMessage = "Unable to receive data"; print ("Server error:"+"\(code)")
                }
                
            }
            
        }
        
        if errorMessage == nil {
            errorMessage = ""
        }
        
        return errorMessage!
    }
    
    /** handleNetworkConnectivity method uses extension of NSError to produce string of exception */
    
    public func handleNetworkConnectivityError(error:NSError) -> String {
        if error.isNetworkConnectionError() {
            return "Network Connectivity Issue"
        } else {
            return "Unkown network issue."
        }
    }
}

/* Small extension of NSError class to identify network connectivity issues. It is extension. Outside of the APIClient scope */

extension NSError {
    func isNetworkConnectionError() -> Bool {
        let networkErrors = [NSURLErrorNetworkConnectionLost, NSURLErrorNotConnectedToInternet,NSURLErrorCannotFindHost,NSURLErrorCannotConnectToHost,NSURLErrorDataNotAllowed,NSURLErrorInternationalRoamingOff,NSURLErrorTimedOut]
        
        if self.domain == NSURLErrorDomain && networkErrors.contains(self.code) {
            return true
        }
        return false
    }
}


