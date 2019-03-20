import UIKit
import AVFoundation
import MetalKit
import simd
import Accelerate

let top = "#include <metal_stdlib>\n"+"#include <simd/simd.h>\n"+"using namespace metal;"
let vertexStruct = "struct Vertex {vector_float4 color; vector_float2 pos;};"
let vertexOutStruct = "struct VertexOut{float4 color; float4 pos [[position]];};"
let uniformStruct = "struct Uniform{float scale;};"
let vertexShader = "vertex VertexOut vertexShader(const device Vertex *vertexArray [[buffer(0)]],const device Uniform *uniformArray [[buffer(1)]], unsigned int vid [[vertex_id]]){Vertex in = vertexArray[vid];VertexOut out;out.color = in.color; float scale = uniformArray[0].scale; float x = in.pos.x * scale; float y = in.pos.y * scale; out.pos = float4(x, y, 0, 1);return out;};"
let fragmentShader = "fragment float4 fragmentShader(VertexOut interpolated [[stage_in]]){return interpolated.color;};"

public class Visualizer : UIView {
    private var engine : AVAudioEngine
    
    private var metalView : MTKView!
    private var metalDevice : MTLDevice!
    private var metalQueue : MTLCommandQueue!
    private var pipelineState: MTLRenderPipelineState!
    private var vertexBuffer: MTLBuffer!
    private var uniformBuffer: MTLBuffer!
    
    struct Vertex {
        var color : simd_float4
        var pos : simd_float2
    }
    
    struct Uniform {
        var scale : Float
    }
    
    var uniform : [Uniform] = [Uniform(scale: 0.3)]
    var vertices : [Vertex] = []
    let originVertice = Vertex(color: [1,1,1,1], pos: [0,0])
    
    var scaleValue : Float? {
        didSet{
            uniform = [Uniform(scale: scaleValue!)]
            uniformBuffer = metalDevice.makeBuffer(bytes: uniform, length: uniform.count * MemoryLayout<Uniform>.stride, options: [])!
            DispatchQueue.main.async {
                self.metalView.setNeedsDisplay()
            }
        }
    }
    
    public required init(engine: AVAudioEngine) {
        self.engine = engine
        super.init(frame: .zero)
        makeVertices()
        setupView()
        setupMetal()
        setupEngineTap()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    fileprivate func makeVertices(){
        func degreesToRads(forValue x: Float)->Float32{
            return (Float.pi*x)/180
        }
        for i in 0..<720 {
            let position : simd_float2 = [cos(degreesToRads(forValue: Float(i)))*1,sin(degreesToRads(forValue: Float(i)))*1]
            if (i+1)%2 == 0 {
                vertices.append(originVertice)
            }
            let vertice = Vertex(color: [1,1,1,1], pos: position)
            vertices.append(vertice)
        }
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
        metalView.isPaused = true
        metalView.enableSetNeedsDisplay = true
        
        //metalQueue
        metalQueue = metalDevice.makeCommandQueue()!
        
        do {
            pipelineState = try buildRenderPipelineWith(device: metalDevice, metalKitView: metalView)
        } catch {
            print(error)
        }

        //metal buffer
        vertexBuffer = metalDevice.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: [])!
        uniformBuffer = metalDevice.makeBuffer(bytes: uniform, length: uniform.count * MemoryLayout<Uniform>.stride, options: [])!
    }
    
    public func setupEngineTap(){
        engine.mainMixerNode.installTap(onBus: 0, bufferSize: 1024, format: nil) { (buffer, time) in
            self.rms(from: buffer, with: 1024)
        }
    }
    
    public var normalSet = false
    
    public func rms(from buffer: AVAudioPCMBuffer, with bufferSize: UInt){
        guard let channelData = buffer.floatChannelData?[0] else {return}
        var val = Float(0);
        
        vDSP_vsq(channelData, 1, channelData, 1, bufferSize) //square
        vDSP_meanv(channelData, 1, &val, bufferSize) //mean
        val = val + 0.3
        if val == 0.3{ //makes sure it always ends up on 0.3 scale size
            if normalSet {
                return
            } else {
                normalSet = true
            }
        }
        if (val > 0.9) {val = 0.9}
        print(val, "MAIN MIXER")
        scaleValue = val
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

        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: vertices.count)

        renderEncoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
    
    func buildRenderPipelineWith(device: MTLDevice, metalKitView: MTKView) throws -> MTLRenderPipelineState {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        let shader = top + vertexStruct + uniformStruct + vertexOutStruct + vertexShader + fragmentShader
        let library = try! device.makeLibrary(source: shader, options: nil)
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentShader")
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
        
        return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
}

