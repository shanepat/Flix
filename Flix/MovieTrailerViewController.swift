//
//  MovieTrailerViewController.swift
//  Flix
//
//  Created by Shane Patra on 2/21/21.
//

import UIKit
import WebKit

class MovieTrailerViewController: UIViewController, WKUIDelegate {
    
    var webView: WKWebView!
    
    override func loadView() {
        // hndling only webconfigoration here
        let webConfiguration = WKWebViewConfiguration()
        self.webView = WKWebView(frame: .zero, configuration: webConfiguration)
        self.webView.uiDelegate = self
        self.view = self.webView
        
    }
    
    @IBOutlet weak var TrailerPlayer: WKWebView!
    
    var movie : [String:Any]!
    
    struct RecoverKey {
        static var videoURL = "someString"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getRecoveryVideoUrl { [self] (url) in
            
            guard let url = url else {return}
            print(url)// unwarps url safely
            guard let myURL = URL(string: url) else {
                print("url could not be casted")
                return
            }
            let myRequest = URLRequest(url: myURL)
            // runs this on the main qeue because its a view operation
            DispatchQueue.main.async {
                self.webView.load(myRequest)
            }
        }
    }
    
    //This function will only finish when there is a recovery key or if the network request fails
    func getRecoveryVideoUrl(completion : @escaping (_ url : String?) -> ()){
        let urlID = movie["id"] as! Double
        let StringID = String(format: "%.0f", urlID)
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(StringID)/videos?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&language=en-US")
        guard let requestUrl = url else { fatalError() }
        // Create URL Request
        var request = URLRequest(url: requestUrl)
        // Specify HTTP Method to use
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { [self] (data, response, error) in
            if error != nil {
                completion(nil)
                return
            }
            do {
                if let DataDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    // Get value by key
                    let GetVideos = DataDictionary["results"] as! [[String:Any]]
                    let index = GetVideos[0]
                    let key = index["key"] as! String
                    let finalKey = "https://www.youtube.com/watch?v=\(key)"
                    RecoverKey.videoURL = finalKey
                    
                    completion(finalKey)
                    return
                    
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
}
