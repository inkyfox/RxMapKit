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
            .bind(to: locationButton.rx.isSelected)
            .disposed(by: disposeBag)

        let track = locationButton.rx.observe(Bool.self, "selected")
            .filter { $0 != nil }.map { $0! }.publish()
        _ = track.filter { $0 }.take(1)
            .subscribe(onNext: { [weak self] _ in self?.locationManager.requestWhenInUseAuthorization() })
        _ = track.bind(to: mapView.rx.showsUserLocation.asObserver())
        _ = track.map { $0 ? .follow : .none }.bind(to: mapView.rx.userTrackingModeToAnimate)
        track.connect().disposed(by: disposeBag)
        
        mapView.rx.regionWillChange.asDriver()
            .drive(onNext: { print("Will region change: isAnimated \($0.isAnimated)") })
            .disposed(by: disposeBag)
        
        mapView.rx.regionDidChange.asDriver()
            .drive(onNext: { print("Did region change: \($0.region) isAnimated \($0.isAnimated)") })
            .disposed(by: disposeBag)
        
        mapView.rx.willStartLoadingMap.asDriver()
            .drive(onNext: { print("Will start loading map") })
            .disposed(by: disposeBag)
        
        mapView.rx.didFinishLoadingMap.asDriver()
            .drive(onNext: { print("Did finish loading map") })
            .disposed(by: disposeBag)
        
        mapView.rx.didFailLoadingMap.asDriver()
            .drive(onNext: { print("Did fail loading map with error: \($0)") })
            .disposed(by: disposeBag)
        
        mapView.rx.willStartRenderingMap.asDriver()
            .drive(onNext: { print("Will start rendering map") })
            .disposed(by: disposeBag)
        
        mapView.rx.didFinishRenderingMap.asDriver()
            .drive(onNext: { print("Did finish rendering map: fully rendered \($0.isFullyRendered)") })
            .disposed(by: disposeBag)

        mapView.rx.didAddAnnotationViews.asDriver()
            .drive(onNext: { views in
                for v in views {
                    print("Did add annotation views: \(v.annotation!.title! ?? "unknown")")
                    v.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                    UIView.animate(withDuration: 0.4) { v.transform = CGAffineTransform.identity }
                }
            })
            .disposed(by: disposeBag)
        
        mapView.rx.didSelectAnnotationView.asDriver()
            .drive(onNext: { view in
                print("Did selected: \(view.annotation!.title! ?? "")")
                view.image = #imageLiteral(resourceName: "marker_selected")
            })
            .disposed(by: disposeBag)

        mapView.rx.didDeselectAnnotationView.asDriver()
            .drive(onNext: { view in
                print("Did deselected: \(view.annotation!.title! ?? "")")
                view.image = #imageLiteral(resourceName: "marker_normal")
            })
            .disposed(by: disposeBag)
        
        mapView.rx.willStartLocatingUser.asDriver()
            .drive(onNext: { print("Will start locating user") })
            .disposed(by: disposeBag)
        
        mapView.rx.didStopLocatingUser.asDriver()
            .drive(onNext: { print("Did stop locating user") })
            .disposed(by: disposeBag)
        
        //mapView.rx.didUpdateUserLocation.asDriver()
        mapView.rx.userLocation.asDriver()
            .drive(onNext: { print("Did update user location: \($0.location?.description ?? "")") })
            .disposed(by: disposeBag)
        
        mapView.rx.showsUserLocation.asObservable()
            .subscribe(onNext: { print("Shows user location: \($0)") })
            .disposed(by: disposeBag)

        mapView.rx.didFailToLocateUser.asDriver()
            .drive(onNext: { print("Did fail to locate user: \($0)") })            .disposed(by: disposeBag)
        
        mapView.rx.dragStateOfAnnotationView.asDriver()
            .drive(onNext: { (view, newState, oldState) in
                print("Drag state did changed: \(view.annotation!.title! ?? "unknown"), \(newState.rawValue) <- \(oldState.rawValue)")
            })
            .disposed(by: disposeBag)
        
        mapView.rx.didAddRenderers.asDriver()
            .drive(onNext: { renderers in
                for r in renderers { print("Did add renderer: \(r.overlay.title! ?? "unknown")") }
            })
            .disposed(by: disposeBag)
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.addMapObjects()
        }
    }
    
    private func addMapObjects() {
        let center = CLLocationCoordinate2D(latitude: 33.3659424, longitude: 126.3476852)
        let place0 = CLLocationCoordinate2D(latitude: 33.4108625, longitude: 126.391319)
        
        do {
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
            mapView.addAnnotations([
                Annotation(coordinate: center, title: "Hello, RxSwift"),
                Annotation(coordinate: place0, title: "Hello, MapKit"),
                ])
        }
        
        do {
            mapView.rx.handleRendererForOverlay { (mapView, overlay) in
                if overlay is MKCircle {
                    let renderer = MKCircleRenderer(overlay: overlay)
                    renderer.strokeColor = UIColor.green.withAlphaComponent(0.8)
                    renderer.lineWidth = 4
                    renderer.fillColor = UIColor.green.withAlphaComponent(0.3)
                    return renderer
                } else {
                    return MKOverlayRenderer(overlay: overlay)
                }
            }
            let circle = MKCircle(center: center, radius: 2000)
            circle.title = "Circle"
            mapView.addOverlays([circle])
        }

        Observable.just(MKMapCamera(lookingAtCenter: center, fromDistance: 50000, pitch: 30, heading: 45))
            .bind(to: mapView.rx.cameraToAnimate)
            .disposed(by: disposeBag)
        
        //actionButton0.rx.tap.map { .satellite }.bind(to: mapView.rx.mapType).disposed(by: disposeBag)
        actionButton1.rx.tap.map { false }.bind(to: mapView.rx.isZoomEnabled).disposed(by: disposeBag)
    }

}

