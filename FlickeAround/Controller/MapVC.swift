//
//  ViewController.swift
//  FlickeAround
//
//  Created by ibrahim on 4/16/19.
//  Copyright © 2019 ibrahim. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import AlamofireImage

class MapVC: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullupViewHightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pullupView: UIView!
    
    let regionRaduis: Double = 1000
    let screenSize = UIScreen.main.bounds
    var spinner: UIActivityIndicatorView?
    var progressLabel: UILabel?
    var collectionView: UICollectionView?
    var flowLayout = UICollectionViewFlowLayout()
    
    var locationManger = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
    var nameArrary = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManger.delegate = self
        addDoubleTap()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        pullupView.addSubview(collectionView!)
        registerForPreviewing(with: self, sourceView: collectionView!)
        
    }
    
    @IBAction func centerMap(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse{
            centerMapOnUserLocation()
        }
    }
    
    func addDoubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender: )))
        doubleTap.delegate = self
        doubleTap.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(doubleTap)
    }
    
    
    func swipDown(){
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        pullupView.addGestureRecognizer(swipe)
    }
    
    func animateViewUp(){
        pullupViewHightConstraint.constant = 350
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func animateViewDown(){
        pullupViewHightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        cancelAllSession()
    }
    
    func addSpinner(){
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2), y: 150)
        spinner?.style = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    
    func addprogressLabel(){
        progressLabel = UILabel()
        progressLabel?.frame = CGRect(x: (screenSize.width / 2) - 125, y: 190, width: 250, height: 50)
        progressLabel?.font = UIFont(name: "Avenir Next", size: 16)
        progressLabel?.textColor = #colorLiteral(red: 0.07843137255, green: 0.07843137255, blue: 0.07843137255, alpha: 1)
        progressLabel?.text = ""
        progressLabel?.textAlignment = .center
        collectionView?.addSubview(progressLabel!)
    }
    
    func removeSpinner(){
        if spinner != nil {
            spinner!.removeFromSuperview()
        }
    }
    
    func removeProgressLbl() {
        if progressLabel != nil {
            progressLabel?.removeFromSuperview()
        }
    }
    

    func retrieveUrls(forAnnotation annotation: DropablePin, handler: @escaping (_ status: Bool) -> ()) {
        Alamofire.request(flickrUrl(forApiKey: apiKey, withAnnotation: annotation, andNumberOfPhotos: 40)).responseJSON { (response) in
            guard let json = response.result.value as? Dictionary<String, AnyObject> else { return }
            let photosDict = json["photos"] as! Dictionary<String, AnyObject>
            let photosDictArray = photosDict["photo"] as! [Dictionary<String, AnyObject>]
            for photo in photosDictArray {
                let postUrl = "https://live.staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_z_d.jpg"
                let title = photo["title"]
                self.imageUrlArray.append(postUrl)
                self.nameArrary.append(title as! String)
                
            }
            handler(true)
        }
    }
    
    func retriveImages (handelr: @escaping(_ status: Bool)->()){
        for url in imageUrlArray{
            Alamofire.request(url).responseImage { (response) in
                
                guard let image  = response.result.value else {return}
                self.imageArray.append(image)
                self.progressLabel?.text = "\(self.imageArray.count)/40 IMAGES DOWNLOADED"
                if self.imageArray.count == self.imageUrlArray.count{
                    handelr(true)
                }
            }
        }
    }
    
    func cancelAllSession(){
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionData, upkoadedData, downloadedData) in
            sessionData.forEach({ $0.cancel() })
            downloadedData.forEach({ $0 .cancel() })
        }
    }
    
    

}

    

extension MapVC: MKMapViewDelegate {
    
    func centerMapOnUserLocation(){
        guard let location = locationManger.location?.coordinate else{return}
        let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionRaduis, longitudinalMeters: regionRaduis)
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 1, green: 0.6941176471, blue: 0.07058823529, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    
     //ADD PIN -> MAPVIEW
    @objc func dropPin(sender: UITapGestureRecognizer){
        removePin()
        removeSpinner()
        removeProgressLbl()
        cancelAllSession()
        
        imageUrlArray = []
        imageArray = []
        nameArrary = []
        collectionView?.reloadData()
        
        addSpinner()
        addprogressLabel()
        animateViewUp()
        swipDown()
        
        let touthPoint = sender.location(in: mapView)
        let tochcCordinate = mapView.convert(touthPoint, toCoordinateFrom: mapView)
        let annotation = DropablePin(coordinate: tochcCordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        
        let locationRegion = MKCoordinateRegion(center: tochcCordinate, latitudinalMeters: regionRaduis, longitudinalMeters: regionRaduis)
        mapView.setRegion(locationRegion, animated: true)
        
        retrieveUrls(forAnnotation: annotation) { (finshed) in
            if finshed {
                self.retriveImages(handelr: { (finshed) in
                    if finshed{
                        self.removeSpinner()
                        self.removeProgressLbl()
                        self.collectionView?.reloadData()
                    }
                })
            }
        }
    }

    // REMOVE PIN -> MAPVIEW
    func removePin(){
        for annotation in mapView.annotations{
            mapView.removeAnnotation(annotation)
        }
    }

    
}

extension MapVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            centerMapOnUserLocation()
        }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        func configureLocationAuthorization(){
            switch authorizationStatus {
            case .authorizedWhenInUse:
                centerMapOnUserLocation()
            case .authorizedAlways:
                centerMapOnUserLocation()
            case .notDetermined:
                locationManger.requestWhenInUseAuthorization()
            default:
                break
            }
        }
    }
    
}


extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let image = imageArray[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell
        let imageView = UIImageView(image: image)
        cell!.addSubview(imageView)
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let popVc = storyboard?.instantiateViewController(withIdentifier: "PopVc") as? PopVc else { return }
        popVc.initData(forImage: imageArray[indexPath.row])
        popVc.initName(forImageName: nameArrary[indexPath.row])
        present(popVc, animated: true, completion: nil)
    }
   
}

extension MapVC: UIViewControllerPreviewingDelegate{
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView?.indexPathForItem(at: location), let cell = collectionView?.cellForItem(at: indexPath) else { return nil }
        guard let popVc = storyboard?.instantiateViewController(withIdentifier: "PopVc") as? PopVc else { return nil }
        popVc.initData(forImage: imageArray[indexPath.row])
        previewingContext.sourceRect = cell.contentView.frame
        return popVc
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
        
    }
    
    
    
}
















