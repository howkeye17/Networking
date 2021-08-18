//
//  AlamofireNetworkRequest.swift
//  Networking
//
//  Created by Valera Vasilevich on 4.08.21.
//

import Foundation
import Alamofire

class AlamofireNetworkRequest {
    
    static var onProgress: ((Double) -> ())?
    static var completed: ((String) -> ())?
    
    static func sendRequest(url: String, completion: @escaping (_ courses:[Course])->()) {
        
        guard let url = URL(string: url) else { return }
        
        AF.request(url).validate().responseJSON { (response) in
            
            switch response.result {
            case .success(let value):
                
                guard let courses = Course.getArray(from: value) else { return }
                
                completion(courses)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    static func downloadImage(url: String, completion: @escaping (_ image: UIImage)->()) {
        
        guard let url = URL(string: url) else { return }
        
        AF.request(url).responseData { (responseData) in
            
            switch responseData.result {
            case .success(let data):
                guard let image = UIImage(data: data) else { return }
                completion(image)
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    static func responseData(url: String) {
        
        AF.request(url).responseData { (responseData) in
            
            switch responseData.result {
            case .success(let data):
                guard let string = String(data: data, encoding: .utf8) else { return }
                print(string)
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    static func responseString(url: String) {
        
        AF.request(url).responseString { (responseString) in
            
            switch responseString.result {
            case .success(let string):
                print(string)
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    static func response(url: String) {
        
        AF.request(url).response { (response) in
            
            guard let data = response.data,
                  let string = String(data: data, encoding: .utf8)
            else { return }
            
            print(string)
        }
    }
    
    static func downloadImageWithProgress(url: String, completion: @escaping (_ image: UIImage) -> ()) {
        
        guard let url = URL(string: url) else { return }
        
        AF.request(url).validate().downloadProgress { (progress) in
            
            print("totalUnitCount: \(progress.totalUnitCount)")
            print("completedUnitCount:  \(progress.completedUnitCount)")
            print("fractionCompleted: \(progress.fractionCompleted)")
            print("localizedDescription: \(progress.localizedDescription!)")
            print("------------------------------------------------------")
            
            self.onProgress?(progress.fractionCompleted)
            self.completed?(progress.localizedDescription)
            
        }.response { (response) in
            
            guard let data = response.data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    static func postRequest(url: String, completion: @escaping (_ courses:[Course])->()) {
        
        guard let url = URL(string: url) else { return }
        
        let userData: [String: Any] = ["name" : "Network Request",
                                       "link" : "https://swiftbook.ru/contents/our-first-applications/",
                                       "imageUrl" : "https://swiftbook.ru/wp-content/uploads/2018/03/2-courselogo.jpg",
                                       "numberOfLessons" : 20,
                                       "numberOfTests" : 10]
        
        AF.request(url, method: .post, parameters: userData).responseJSON { (responseJSON) in
            
            guard let statusCode = responseJSON.response?.statusCode else { return }
            
            print("StatusCode", statusCode)
            
            switch responseJSON.result {
            case .success(let value):
                print(value)
                
                guard let jsonObject = value as? [String: Any],
                      let course = Course(json: jsonObject)
                        else { return }
                
                var courses = [Course]()
                courses.append(course)
                
                completion(courses)
                
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    
    static func putRequest(url: String, completion: @escaping (_ courses:[Course])->()) {
        
        guard let url = URL(string: url) else { return }
        
        let userData: [String: Any] = ["name" : "Network Request with Alamofire",
                                       "link" : "https://swiftbook.ru/contents/our-first-applications/",
                                       "imageUrl" : "https://swiftbook.ru/wp-content/uploads/2018/03/2-courselogo.jpg",
                                       "numberOfLessons" : 20,
                                       "numberOfTests" : 10]
        
        AF.request(url, method: .put, parameters: userData).responseJSON { (responseJSON) in
            
            guard let statusCode = responseJSON.response?.statusCode else { return }
            
            print("StatusCode", statusCode)
            
            switch responseJSON.result {
            case .success(let value):
                print(value)
                
                guard let jsonObject = value as? [String: Any],
                      let course = Course(json: jsonObject)
                        else { return }
                
                var courses = [Course]()
                courses.append(course)
                
                completion(courses)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
}
