//
//  ViewController.swift
//  RxMapKit
//
//  Created by 350116542@qq.com on 01/31/2021.
//  Copyright (c) 2021 350116542@qq.com. All rights reserved.
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
    let reusableIdentifier: String = "MapAnnotationView"
    
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
        bindViewModel()

        locationButton.rx.tap
            .map { [weak self] in !self?.locationButton.isSelected ?? false }
            .bind(to: locationButton.rx.isSelected)
            .disposed(by: disposeBag)

        let track = locationButton.rx.observe(Bool.self, "selected")
            .filter { $0 != nil }
            .map { $0! }
            .publish()
        
        _ = track.filter { $0 }
            .take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.locationManager.requestWhenInUseAuthorization()
            })
        
        _ = track.bind(to: mapView.rx.showsUserLocation.asObserver())
        
        _ = track.map { $0 ? .follow : .none }
            .bind(to: mapView.rx.userTrackingModeToAnimate)
        
        track.connect()
            .disposed(by: disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.addMapObjects()
        }
    }
    
    private func addMapObjects() {
        let center = CLLocationCoordinate2D(latitude: 23.16, longitude: 113.23)
        let place0 = CLLocationCoordinate2D(latitude: 22.95, longitude: 113.36)

        mapView.register(MapAnnotationView.self, forAnnotationViewWithReuseIdentifier: "MapAnnotationView")
        
        do {
            mapView.rx.handleViewForAnnotation { (mapView, annotation) in
                guard let anotation = annotation as? Annotation,
                      let view = mapView.dequeueReusableAnnotationView(withIdentifier: anotation.reusableIdentifier) as? MapAnnotationView else { return nil }
                view.image = UIImage(named: "map_markNormal")
                view.canShowCallout = true
                view.isDraggable = true
                return view
            }
            
            mapView.addAnnotations([
                Annotation(coordinate: center, title: "1"),
                Annotation(coordinate: place0, title: "2")
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
        actionButton1.rx.tap.map { false }
            .bind(to: mapView.rx.isZoomEnabled)
            .disposed(by: disposeBag)
    }

}

extension ViewController {
    func bindViewModel() {
        mapView.rx.regionWillChange
            .subscribe(onNext: {
                print("Will region change: isAnimated \($0.isAnimated)")
            })
            .disposed(by: disposeBag)
        
        mapView.rx.regionDidChange
            .subscribe(onNext: { print("Did region change: \($0.region) isAnimated \($0.isAnimated)") })
            .disposed(by: disposeBag)
        
        mapView.rx.willStartLoadingMap
            .subscribe(onNext: { print("Will start loading map") })
            .disposed(by: disposeBag)
        
        mapView.rx.didFinishLoadingMap
            .subscribe(onNext: { print("Did finish loading map") })
            .disposed(by: disposeBag)
        
        mapView.rx.didFailLoadingMap
            .subscribe(onNext: { print("Did fail loading map with error: \($0)") })
            .disposed(by: disposeBag)
        
        mapView.rx.willStartRenderingMap
            .subscribe(onNext: { print("Will start rendering map") })
            .disposed(by: disposeBag)
        
        mapView.rx.didFinishRenderingMap
            .subscribe(onNext: { print("Did finish rendering map: fully rendered \($0.isFullyRendered)") })
            .disposed(by: disposeBag)

        mapView.rx.didAddAnnotationViews
            .subscribe(onNext: { views in
//                for v in views {
//                    print("Did add annotation views: \(v.annotation!.title! ?? "unknown")")
//                    v.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
//                    UIView.animate(withDuration: 0.4) { v.transform = CGAffineTransform.identity }
//                }
            })
            .disposed(by: disposeBag)
        
        mapView.rx.didSelectAnnotationView
            .subscribe(onNext: { view in
                print("Did selected: \(view.annotation!.title! ?? "")")
//                view.image = #imageLiteral(resourceName: "marker_selected")
//                view.backgroundColor = .purple
            })
            .disposed(by: disposeBag)

        mapView.rx.didDeselectAnnotationView
            .subscribe(onNext: { view in
                print("Did deselected: \(view.annotation!.title! ?? "")")
////                view.image = #imageLiteral(resourceName: "marker_normal")
//                view.backgroundColor = .clear
            })
            .disposed(by: disposeBag)
        
        mapView.rx.willStartLocatingUser
            .subscribe(onNext: { print("Will start locating user") })
            .disposed(by: disposeBag)
        
        mapView.rx.didStopLocatingUser.asDriver()
            .drive(onNext: { print("Did stop locating user") })
            .disposed(by: disposeBag)
        
        mapView.rx.didUpdateUserLocation
            .subscribe(onNext: { location in
                print("Did update user location \(location)")
            })
            .disposed(by: disposeBag)
        
        mapView.rx.userLocation
            .subscribe(onNext: { print("Did update user location: \($0.location?.description ?? "")") })
            .disposed(by: disposeBag)
        
        mapView.rx.showsUserLocation.asObservable()
            .subscribe(onNext: { print("Shows user location: \($0)") })
            .disposed(by: disposeBag)

        mapView.rx.didFailToLocateUser.asDriver()
            .drive(onNext: { print("Did fail to locate user: \($0)") })
            .disposed(by: disposeBag)
        
        mapView.rx.didFailToLocateUser
            .subscribe(onNext: { error in
                print("Did fail to locate user: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
        
        mapView.rx.dragStateOfAnnotationView
            .subscribe(onNext: { (view, newState, oldState) in
                print("Drag state did changed: \(view.annotation!.title! ?? "unknown"), \(newState.rawValue) <- \(oldState.rawValue)")
            })
            .disposed(by: disposeBag)
        
        mapView.rx.didAddRenderers.subscribe(onNext: { renderers in
                for r in renderers { print("Did add renderer: \(r.overlay.title! ?? "unknown")") }
            })
            .disposed(by: disposeBag)
    }
}
