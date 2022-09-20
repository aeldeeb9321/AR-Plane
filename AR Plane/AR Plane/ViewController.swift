//
//  ViewController.swift
//  AR Plane
//
//  Created by Ali Eldeeb on 9/20/22.
//

import UIKit
import ARKit
import RealityKit
import CoreMotion

class ViewController: UIViewController {

    @IBOutlet weak var arView: ARView!
    let configuration = ARWorldTrackingConfiguration()
    var planeEntity: Entity?
    let motionManager = CMMotionManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        self.arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        setupAccelerometer()
    }
    
    func setup(){
        self.arView.automaticallyConfigureSession = true
        self.configuration.environmentTexturing = .automatic
        self.configuration.planeDetection = .horizontal
        self.arView.debugOptions = .showAnchorGeometry
        self.arView.session.run(configuration)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer){
        guard let arView = arView else{return}
        let tapLocation = sender.location(in: arView)
        let results = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
        if let firstResult = results.first{
            let worldPosition = simd_make_float3(firstResult.worldTransform.columns.3)
            planeEntity = try! Entity.load(named: "toy_biplane")
            if let plane = planeEntity{
                placeObject(plane, at: worldPosition)
                playAnimation()
            }
        }
    }

    func placeObject(_ object: Entity, at location: SIMD3<Float>){
        let objectAnchor = AnchorEntity(world: location)
        objectAnchor.addChild(object)
        self.arView.scene.addAnchor(objectAnchor)
    }
    
    func playAnimation(){
        if let planeAnimation = planeEntity?.availableAnimations.first{
            planeEntity?.playAnimation(planeAnimation.repeat(), transitionDuration: 0.5, startsPaused: false)
        }
    }
    
    func setupAccelerometer(){
        if motionManager.isAccelerometerAvailable{
            motionManager.accelerometerUpdateInterval = 1/60 //acceleromater updates will occur 60 times per sec
            motionManager.startAccelerometerUpdates(to: .main) { (accelerometerData, error) in
                if let error = error{
                    print(error.localizedDescription)
                    return
                }
                if let accelData = accelerometerData?.acceleration{
                    self.acceleromaterDidChange(acceleration: accelData)
                }

            }
        }
    }
    
    func acceleromaterDidChange(acceleration: CMAcceleration){
        print(acceleration.x)
        print(acceleration.y)
        print("")
    }
    
}

