//
//  ViewController.swift
//  RxMapKit
//
//  Created by indy on 2016. 10. 17..
//  Copyright © 2016년 Gen X Hippies Company. All rights reserved.
//

import UIKit
import MapKit
import RxMapKit
import RxCocoa
import RxSwift

class Annotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String? = nil
    let reusableIdentifier: String = "annotaion"
    
    init(coordinate: CLLocationCoordinate2D, title: String) {
        self.coordinate = coordinate
        self.title = title
    }
}

prefix func !(b: Bool?) -> Bool? { return b != nil ? !b! : nil }

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var actionButton0: UIButton!
    @IBOutlet weak var actionButton1: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    
    let disposeBag = DisposeBag()
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        locationButton.rx.tap
            .map { [weak self] in !self?.locationButton.isSelected ?? false }
            .bindTo(locationButton.rx.selected)
            .addDisposableTo(disposeBag)

        let track = locationButton.rx.observe(Bool.self, "selected")
            .filter { $0 != nil }.map { $0! }.publish()
        _ = track.filter { $0 }.take(1)
            .subscribe(onNext: { [weak self] _ in self?.locationManager.requestWhenInUseAuthorization() })
        _ = track.bindTo(mapView.rx.showsUserLocation.asObserver())
        _ = track.map { $0 ? .follow : .none }.bindTo(mapView.rx.userTrackingModeToAnimate)
        track.connect().addDisposableTo(disposeBag)
        
        mapView.rx.regionWillChange.asDriver()
            .drive(onNext: { print("Will region change: isAnimated \($0.isAnimated)") })
            .addDisposableTo(disposeBag)
        
        mapView.rx.regionWillChange.asDriver()
            .drive(onNext: { print("Did region change: isAnimated \($0.isAnimated)") })
            .addDisposableTo(disposeBag)
        
        mapView.rx.willStartLoadingMap.asDriver()
            .drive(onNext: { print("Will start loading map") })
            .addDisposableTo(disposeBag)
        
        mapView.rx.didFinishLoadingMap.asDriver()
            .drive(onNext: { print("Did finish loading map") })
            .addDisposableTo(disposeBag)
        
        mapView.rx.didFailLoadingMap.asDriver()
            .drive(onNext: { print("Did fail loading map with error: \($0)") })
            .addDisposableTo(disposeBag)
        
        mapView.rx.willStartRenderingMap.asDriver()
            .drive(onNext: { print("Will start rendering map") })
            .addDisposableTo(disposeBag)
        
        mapView.rx.didFinishRenderingMap.asDriver()
            .drive(onNext: { print("Did finish rendering map: fully rendered \($0.isFullyRendered)") })
            .addDisposableTo(disposeBag)
        
        mapView.rx.handleViewForAnnotation { (mapView, annotation) in
            if let _ = annotation as? MKUserLocation {
                return nil
            } else if let a = annotation as? Annotation {
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: a.reusableIdentifier) ??
                    MKAnnotationView(annotation: annotation, reuseIdentifier: a.reusableIdentifier)
                view.image = #imageLiteral(resourceName: "marker_normal")
                view.canShowCallout = true
                view.isDraggable = true
                return view
            } else {
                return nil
            }
        }
        
        mapView.rx.didAddAnnotationViews.asDriver()
            .drive(onNext: { views in
                print("Did add \(views.count) annotation views")
                for v in views {
                    v.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                    UIView.animate(withDuration: 0.4) { v.transform = CGAffineTransform.identity }
                }
            })
            .addDisposableTo(disposeBag)
        
        mapView.rx.didSelectAnnotationView.asDriver()
            .drive(onNext: { view in
                print("Did selected: \(view.annotation!.title)")
                view.image = #imageLiteral(resourceName: "marker_selected")
            })
            .addDisposableTo(disposeBag)

        mapView.rx.didDeselectAnnotationView.asDriver()
            .drive(onNext: { view in
                print("Did deselected: \(view.annotation!.title)")
                view.image = #imageLiteral(resourceName: "marker_normal")
            })
            .addDisposableTo(disposeBag)
        
        mapView.rx.willStartLocatingUser.asDriver()
            .drive(onNext: { print("Will start locating user") })
            .addDisposableTo(disposeBag)
        
        mapView.rx.didStopLocatingUser.asDriver()
            .drive(onNext: { print("Did stop locating user") })
            .addDisposableTo(disposeBag)
        
        //mapView.rx.didUpdateUserLocation.asDriver()
        mapView.rx.userLocation.asDriver()
            .drive(onNext: { print("Did update user location: \($0.location)") })
            .addDisposableTo(disposeBag)
        
        mapView.rx.showsUserLocation.asObservable()
            .subscribe(onNext: { print("Shows user location: \($0)") })
            .addDisposableTo(disposeBag)

        mapView.rx.didFailToLocateUser.asDriver()
            .drive(onNext: { print("Did fail to locate user: \($0)") })
            .addDisposableTo(disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let center = CLLocationCoordinate2D(latitude: 33.3659424, longitude: 126.3476852)
        let place0 = CLLocationCoordinate2D(latitude: 33.4108625, longitude: 126.391319)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.mapView.addAnnotations([
                Annotation(coordinate: center, title: "Hello, RxSwift"),
                Annotation(coordinate: place0, title: "Hello, MapKit"),
                ])
        }
    }
    

}

