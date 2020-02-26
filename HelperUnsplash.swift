//
//  HelperUnsplash.swift
//  Lomograph
//
//  Created by KIRTAN VAGHELA on 16/04/19.
//  Copyright © 2019 KV. All rights reserved.
//

import UIKit

//use this type alias to identify parameter as reciver side.
typealias unsplashThumbImageUrl = String
typealias unsplashFullImageUrl = String

class HelperUnsplash: NSObject {
    
    static var shared : HelperUnsplash = HelperUnsplash()
    private let unsplashDefaultSearchKeyword = "Nature" //if search keyword is nil
    
    func callAPI(apiUrl:URL,completion: @escaping (NSDictionary?,Error?) -> ()) -> (){
        let task = URLSession.shared.dataTask(with: apiUrl) { (data, response, error) in
            if error != nil {
                completion (nil, error)
                print(error ?? " ")
            } else {
                DispatchQueue.main.async(execute: {
                    do{
                        if data != nil{
                            
                            let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
                            
                            if let parseJSON = json {
                                
                                // print(parseJSON)
                                // Parsed JSON
                                completion (parseJSON,nil)
                                // completion(_responseData:parseJSON,Error:error)
                                
                            }
                            else {
                                // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                                let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                                
                                #if DEBUG
                                print("Error could not parse JSON: \(String(describing: jsonStr))")
                                #endif
                            }
                        }else{
                            print(error?.localizedDescription ?? " ")
                            completion (nil, error!)
                        }
                        
                    }catch let error as NSError{
                        
                        print(error.localizedDescription)
                        completion (nil, error)
                    }
                })
            }
        }
        task.resume()
    }
    
    func getUnsplashImages(searchKeyword:String,apiKey:String,completion: @escaping (_ arrThumbImageURL:[unsplashThumbImageUrl]?,_ arrFullImageURL:[unsplashFullImageUrl]?,_ error:Error?)-> Void) {
        var query = ""
        
        if !searchKeyword.isEmpty && searchKeyword.first! != " " {
            query = searchKeyword
        }else{
            query = unsplashDefaultSearchKeyword
        }
        query = (query).replacingOccurrences(of: " ", with: "+")
        
        var arrThumbImagesUrl = [String]()
        var arrFullImagesUrl = [String]()
        let url = "https://api.unsplash.com/search/photos?client_id=\(unsplashAPIKEY)&query=\(query)&per_page=100"
        
        self.callAPI(apiUrl: URL (string: url)!) { (response, error) in
            if response != nil && error == nil{
                if let responseData = response!["results"] as? Array<Dictionary<String, AnyObject>>{
                    for index in 0..<responseData.count{
                        let urlDict = responseData[index]["urls"]
                        let thumbURL = urlDict!.value(forKey: "thumb")
                        let FullURL = urlDict?.value(forKey:"full")
                        arrThumbImagesUrl.append(thumbURL! as! String)
                        arrFullImagesUrl.append(FullURL! as! String)
                    }
                    if arrThumbImagesUrl.count > 0{
                        completion (arrThumbImagesUrl, arrFullImagesUrl, nil)
                    }else{
                        completion (arrThumbImagesUrl, arrFullImagesUrl, nil)
                    }
                }else{
                    completion (nil, nil, error)
                }
            }else{
                completion (nil, nil, error)
            }
        }
    }
}
