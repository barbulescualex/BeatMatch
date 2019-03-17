import UIKit
import AVFoundation
import MetalKit

public class Visualizer : UIView {
    private var engine : AVAudioEngine
    
    private var metalView : MTKView!
    private var metalDevice : MTLDevice!
    private var metalQueue : MTLCommandQueue!
    
    let circle = UIView()
    
    public required init(engine: AVAudioEngine) {
        self.engine = engine
        super.init(frame: .zero)
        setupView()
        //setupMetal()
        setupEngineTap()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    fileprivate func setupView(){
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        
        addSubview(circle)
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.backgroundColor = .white
        circle.layer.cornerRadius = 50
        circle.clipsToBounds = true
        circle.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        circle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        circle.widthAnchor.constraint(equalToConstant: 100).isActive = true
        circle.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    fileprivate func setupMetal(){
        //metalView
        metalView = MTKView()
        metalView.backgroundColor = .clear
        metalView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(metalView)
        metalView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        metalView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        metalView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        metalView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        metalView.delegate = self
        
        //metalDevice
        metalDevice = MTLCreateSystemDefaultDevice()
        metalView.device = metalDevice
        metalView.isPaused = true
        metalView.enableSetNeedsDisplay = true
        
        //metalQueue
        metalQueue = metalDevice.makeCommandQueue()!
    }
    
    public func setupEngineTap(){
        engine.mainMixerNode.installTap(onBus: 0, bufferSize: 1024, format: nil) { (buffer, time) in
            let volume = CGFloat(self.getVolume(from: buffer, bufferSize: 1024)) + 1
            self.aniamteCircle(volume: volume)
        }
    }
    
    fileprivate func aniamteCircle(volume: CGFloat){
        DispatchQueue.main.async {
            if volume > 1.1 {
                print(volume)
                self.circle.transform = CGAffineTransform.identity
                self.circle.transform = CGAffineTransform(scaleX: volume , y: volume)
            } else {
                self.circle.transform = CGAffineTransform.identity
            }
        }
    }
    
    fileprivate func getVolume(from buffer: AVAudioPCMBuffer, bufferSize: Int) -> Float {
        guard let channelData = buffer.floatChannelData?[0] else {
            return 0
        }
        
        let channelDataArray = Array(UnsafeBufferPointer(start:channelData, count: bufferSize))
        
        var outEnvelope = [Float]()
        var envelopeState:Float = 0
        let envConstantAtk:Float = 0.16
        let envConstantDec:Float = 0.003
        
        for sample in channelDataArray {
            let rectified = abs(sample)
            
            if envelopeState < rectified {
                envelopeState += envConstantAtk * (rectified - envelopeState)
            } else {
                envelopeState += envConstantDec * (rectified - envelopeState)
            }
            outEnvelope.append(envelopeState)
        }
        
        // 0.007 is the low pass filter to prevent
        // getting the noise entering from the microphone
        if let maxVolume = outEnvelope.max(),
            maxVolume > Float(0.015) {
            return maxVolume
        } else {
            return 0.0
        }
    }
}

extension Visualizer : MTKViewDelegate {
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    
    public func draw(in view: MTKView) {
        guard let commandBuffer = metalQueue.makeCommandBuffer() else {return}
        guard let renderDescriptor = view.currentRenderPassDescriptor else {return}
        
        renderDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0)
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderDescriptor) else {return}
        
        
        
        renderEncoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
}

