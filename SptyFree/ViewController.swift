//
//  ViewController.swift
//  SptyFree
//
//  Created by Marvel Alvarez Rojas on 04/08/2018.
//  Copyright © 2018 Marvel Alvarez Rojas. All rights reserved.
//

import UIKit
import Alamofire

struct playlistS {
    let name: String!
    let img: UIImage!
    
}
struct playlistY {
    let vidurl: String
    let nameY: String!
    let imgY: UIImage!
}

class MainViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate, UISearchBarDelegate{
    
    var playlistSArr = [playlistS]()
    var tempplaysearch = [playlistS]()
    var playlistYArr = [playlistY]()
    var tempplaylistY = [playlistY]()
    
    var searchActive = false
    private var searchingWorkItem: DispatchWorkItem?
    
    @IBOutlet weak var collectionViewY: UICollectionView!
    @IBOutlet weak var SearchbarOulet: UISearchBar!
    @IBOutlet private weak var collectionViewS: UICollectionView!
    
//    var loadS:DPBasicLoading
//    var loadY:DPBasicLoading
    // typealias JSONString = <String: Any>
    
    
    //"https://api.spotify.com/v1/search?query=mana&type=playlist&offset=0&limit=20"
    //"http://streamsquid.com/php/i_songsearch.php?qs=mana&rc=US"
    
    //var SearchResult = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ///
        SearchbarOulet.delegate = self
        //// set up collection view layout
        let ancho = (view.frame.size.width - 20) / 3
        let layout = collectionViewS.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: ancho, height: ancho)
        
        
        
    }
    //// hide keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !searchActive{
            self.SearchbarOulet.resignFirstResponder()
        }
    }
    //////////////// searchBar
    
    
    func searchBarSearchButtonClicked(_ SearchbarOulet: UISearchBar) {
        searchActive = false
        self.SearchbarOulet.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ SearchbarOulet: UISearchBar) {
        searchActive = false
        self.SearchbarOulet.resignFirstResponder()
    }
    func searchBar(_ SearchbarOulet: UISearchBar, textDidChange searchText: String) {
        
        //DispatchQueue.main.suspend()
        
        
        DispatchQueue.main.async {
            self.searchActive = true
            if (!searchText.isEmpty){
                self.loadS.startLoading(text: "Loading..")
                
                self.tempplaysearch = [playlistS]()
                self.tempplaylistY = [playlistY]()
                print("buscando")
                var criterio:String = SearchbarOulet.text!
                
                criterio = criterio.replacingOccurrences(of: "   ", with: "%20")
                criterio = criterio.replacingOccurrences(of: "  ", with: "%20")
                criterio = criterio.replacingOccurrences(of: " ", with: "%20")
                let searchurl = "http://streamsquid.com/php/i_songsearch.php?qs=\(criterio)&rc=US"
                
                self.CallAlamoF(url: searchurl)
                
            }
            
            
        }
        
    }
    
    //////////////// collectonView
    
    func  collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if( collectionView == self.collectionViewS){
            
            if searchActive{
                loadS.startLoading(text: "loading..")
                return tempplaysearch.count
            }
        return playlistSArr.count
        }
        if(searchActive){
            loadY.startLoading(text: "loading..")
            return tempplaylistY.count
        }
        return playlistYArr.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if collectionView == self.collectionViewS{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! yaCollectionViewCell
            let data1 = self.playlistSArr[indexPath.row]
          
            cell.celltext.text = data1.name
            cell.cellImg.image = data1.img
            cell.cellImg.makeRounded()
            return cell
        }
        let cellY = collectionViewY.dequeueReusableCell(withReuseIdentifier: "item1", for: indexPath) as! YCollectionViewCell
        let data1 = self.playlistYArr[indexPath.row]
        cellY.labelY.text = data1.nameY
        cellY.imageY.image = data1.imgY
        self.HideActivityIndicator()
        return cellY
    }
    
    //////////////// method for retieve data
    func CallAlamoF(url : String) {
        
        Alamofire.request(url).responseJSON{ response in
            if let JSON_Data = response.result.value as? Dictionary<String, Any>{
        
                let viditems = JSON_Data["items"] as! NSArray
                for val in viditems {
                    let vidtitle = val as? Dictionary<String, Any>
                    if vidtitle != nil, let url = vidtitle?["id"] as? String{                                    
                        let snipet = vidtitle!["snippet"] as? Dictionary<String, Any>
                        let namey = snipet!["title"] as! String
                        let imgarr = snipet!["thumbnails"] as? Dictionary<String, Any>
                        let imglist = imgarr!["high"] as? Dictionary<String, Any>
                        let imgurl = URL(string: (imglist!["url"] as? String)!)
                        if let imgdata1 = try? Data(contentsOf: imgurl!){
                            let img = UIImage(data: imgdata1)
                            self.tempplaylistY.append(playlistY.init(vidurl: url, nameY: namey, imgY: img))
                        }
                    }
                }
                self.playlistYArr = self.tempplaylistY
                self.collectionViewY!.reloadData()
                
                let SpotifyItems:Dictionary = JSON_Data["spotify_items"] as! Dictionary<String, Any>
                let PlayList:Dictionary = SpotifyItems["playlists"] as! Dictionary<String, Any>
                let SearchResult = PlayList["items"] as! NSArray
                for i in 0..<SearchResult.count{
                    let itemslist = SearchResult[i] as? Dictionary<String, Any>
                    let name = itemslist!["name"] as! String
                    let imageslist = itemslist!["images"] as! NSArray
                    let urll = imageslist[0] as! Dictionary<String, Any> // revisar
                    let url = URL(string: urll["url"] as! String)
                    if let imgdata1 = try? Data(contentsOf: url!){
                        let img = UIImage(data: imgdata1)
                        self.tempplaysearch.append(playlistS.init(name: name, img: img))
                    }
                    
                }
                self.playlistSArr = self.tempplaysearch
                self.loadY.endLoading()
                self.loadS.endLoading()
                self.collectionViewS!.reloadData()
            }
        }
    }
    
    var actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    var container: UIView = UIView()
    
    func  ShowActivityIndicator() {
        let uiView = self.view
        
        container.frame = (uiView?.frame)!
        container.center = (uiView?.center)!
        container.backgroundColor = UIColor( white: 0.2, alpha: 0.5)
        
        let loadingView: UIView = UIView()
        loadingView.frame = CGRect(x: 0, y: 4, width: 80, height: 80)
        loadingView.center = (uiView?.center)!
        loadingView.backgroundColor = UIColor(white: 0.5, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        
        actInd.frame = CGRect(x: 0, y: 5, width: 40, height: 40)
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        actInd.center = CGPoint(x: loadingView.frame.size.width / 2,y: loadingView.frame.size.height / 2);
        loadingView.addSubview(actInd)
        container.addSubview(loadingView)
        uiView?.addSubview(container)
        actInd.startAnimating()
        
    }
    
    func  HideActivityIndicator(){
        
        actInd.stopAnimating()
        container.removeFromSuperview()
    }
}

extension UIImageView {
    
    func makeRounded() {
        let radius = self.frame.width/2.0
        self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
}
