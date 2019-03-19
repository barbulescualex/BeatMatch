import UIKit
import AVFoundation
import MetalKit
import simd

let top = "#include <metal_stdlib>\n"+"#include <simd/simd.h>\n"+"using namespace metal;"
let vertexStruct = "struct Vertex {vector_float4 color; vector_float2 pos;};"
let vertexOutStruct = "struct VertexOut{float4 color; float4 pos [[position]];};"
//let vertexShader = "vertex VertexOut vertexShader(const device Vertex *vertexArray [[buffer(0)]], unsigned int vid [[vertex_id]]){};"
//let fragmentShader = "fragment float4 fragmentShader(VertexOut interpolated [[stage_in]]){};"
//let vertexShader = "vertex void vertexShader(){};"
//let fragmentShader = "fragment void fragmentShader(){};"
let vertexShader = "vertex VertexOut vertexShader(const device Vertex *vertexArray [[buffer(0)]], unsigned int vid [[vertex_id]]){Vertex in = vertexArray[vid];VertexOut out;out.color = in.color;out.pos = float4(in.pos.x, in.pos.y, 0, 1);return out;};"
let fragmentShader = "fragment float4 fragmentShader(VertexOut interpolated [[stage_in]]){return interpolated.color;};"

public class Visualizer : UIView {
    private var engine : AVAudioEngine
    
    private var metalView : MTKView!
    private var metalDevice : MTLDevice!
    private var metalQueue : MTLCommandQueue!
    private var pipelineState: MTLRenderPipelineState!
    private var vertexBuffer: MTLBuffer!
    
    struct Vertex {
        var color : simd_float4
        var pos : simd_float2
    }
    
    let vertices = [Vertex(color: [1, 0, 0, 1], pos: [-1, -1]),
                    Vertex(color: [0, 1, 0, 1], pos: [0, 1]),
                    Vertex(color: [0, 0, 1, 1], pos: [1, -1])]
    
    public required init(engine: AVAudioEngine) {
        self.engine = engine
        super.init(frame: .zero)
        setupView()
        setupMetal()
        setupEngineTap()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    fileprivate func setupView(){
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
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
//        metalView.isPaused = true
//        metalView.enableSetNeedsDisplay = true
        
        //metalQueue
        metalQueue = metalDevice.makeCommandQueue()!
        
        do {
            pipelineState = try buildRenderPipelineWith(device: metalDevice, metalKitView: metalView)
        } catch {
            print(error)
        }

        //metal buffer
        vertexBuffer = metalDevice.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: [])!
    }
    
    public func setupEngineTap(){
        engine.mainMixerNode.installTap(onBus: 0, bufferSize: 1024, format: nil) { (buffer, time) in
            DispatchQueue.global(qos: .userInitiated).async{
                let volume = CGFloat(self.getVolume(from: buffer, bufferSize: 1024)) + 1
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
        
        renderDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 0, 0, 1)
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderDescriptor) else {return}

        //We tell it what render pipeline to use
        renderEncoder.setRenderPipelineState(pipelineState)
        // What vertex buffer data to use
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)

        renderEncoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
    
    func buildRenderPipelineWith(device: MTLDevice, metalKitView: MTKView) throws -> MTLRenderPipelineState {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        let shader = top + vertexStruct + vertexOutStruct + vertexShader + fragmentShader
        let library = try! device.makeLibrary(source: shader, options: nil)
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentShader")
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
        
        return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
}

