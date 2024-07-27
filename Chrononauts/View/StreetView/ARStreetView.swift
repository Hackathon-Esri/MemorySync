//
//  ARViewController.swift
//  Chrononauts
//
//  Created by FredyCamas on 7/26/24.
//

import SwiftUI
import ARKit
import Combine
import CoreLocation

class ARStreetView: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate, ARSessionDelegate {
    var sceneView: ARSCNView!
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var panorama: Panorama // Single panorama instance
    
    var images: [PanoImages] {
        return panorama.panoImages
    }
    
    init(panorama: Panorama) {
        self.panorama = panorama
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupARScene()
        startLocationServices()
        configureARSession()
        addHorizontalPicker()
        addMapIconButton()
    }

    func addMapIconButton() {
        let mapIconButton = UIButton(type: .system)
        mapIconButton.setImage(UIImage(systemName: "map"), for: .normal)
        mapIconButton.tintColor = .black
        mapIconButton.addTarget(self, action: #selector(showAerialView), for: .touchUpInside)
        
        mapIconButton.frame = CGRect(x: self.view.frame.width - 80, y: 40, width: 100, height: 100)
        self.view.addSubview(mapIconButton)
        
        print("Map icon button added")
    }

        
    @objc func showAerialView() {
        print("Map icon button pressed")
        let aerialView = AerialView(panorama: panorama)
        let hostingController = UIHostingController(rootView: aerialView)
        
        // Check if self.navigationController is not nil
        if let navigationController = self.navigationController {
            navigationController.pushViewController(hostingController, animated: true)
            print("AerialView pushed onto navigation stack")
        } else {
            print("No navigation controller found")
        }
    }

    
    func setupARScene() {
        sceneView = ARSCNView(frame: self.view.frame)
        self.view.addSubview(sceneView)
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.scene = SCNScene()
    }
    
    func addHorizontalPicker() {
        let horizontalPicker = UIHostingController(rootView: HorizontalPickerView(images: images, onImageSelected: { image in
            self.replaceBuildingWithPhoto(identifier: image?.name)
        }))
        
        self.addChild(horizontalPicker)
        horizontalPicker.view.frame = CGRect(x: 0, y: self.view.frame.height - 150, width: self.view.frame.width, height: 100)
        self.view.addSubview(horizontalPicker.view)
        horizontalPicker.didMove(toParent: self)
    }

    func startLocationServices() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            print("Location services not authorized")
        }
    }
    
    func configureARSession() {
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("ARKit is not available on this device.")
        }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
    }
    
    func removePanoramicImageNode() {
        if let existingNode = sceneView.scene.rootNode.childNode(withName: "panoramicImage", recursively: true) {
            existingNode.removeFromParentNode()
        }
    }
    
    func replaceBuildingWithPhoto(identifier: String?) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let identifier = identifier, let originalImage = UIImage(named: identifier) {
                guard let mirroredImage = self.mirrorImage(originalImage) else { return }

                DispatchQueue.main.async {
                    // Remove all existing panoramic image nodes
                    self.removePanoramicImageNode()
                    
                    // Add the new panoramic image node
                    let sphere = SCNSphere(radius: 10)
                    let sphereMaterial = SCNMaterial()
                    sphereMaterial.diffuse.contents = mirroredImage
                    sphereMaterial.isDoubleSided = true
                    sphere.materials = [sphereMaterial]

                    let sphereNode = SCNNode(geometry: sphere)
                    sphereNode.position = SCNVector3(0, 0, 0)
                    sphereNode.name = "panoramicImage"
                    self.sceneView.scene.rootNode.addChildNode(sphereNode)
                }
            } else {
                DispatchQueue.main.async {
                    // No image selected; remove all panoramic image nodes and show the AR camera
                    self.removePanoramicImageNode()
                }
            }
        }
    }
    
  
    
    func mirrorImage(_ image: UIImage) -> UIImage? {
        UIGraphicsBeginImageContext(image.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        context.translateBy(x: image.size.width, y: image.size.height)
        context.scaleBy(x: -1.0, y: -1.0)

        context.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        let mirroredImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return mirroredImage
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        print("AR session failed with error: \(error.localizedDescription)")
        sceneView.session.run(sceneView.session.configuration!, options: [.resetTracking, .removeExistingAnchors])
    }
}

