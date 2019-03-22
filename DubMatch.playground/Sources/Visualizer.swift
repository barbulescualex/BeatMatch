import UIKit
import AVFoundation
import MetalKit
import simd
import Accelerate

let top = "#include <metal_stdlib>\n"+"#include <simd/simd.h>\n"+"using namespace metal;"
let vertexInStruct = "struct VertexIn {vector_float2 pos;};"
let vertexOutStruct = "struct VertexOut{float4 color; float4 pos [[position]];};"
let uniformStruct = "struct Uniform{float scale;};"
let uniformLineStruct = "struct LineUniform { float scale; };"
let vertexShader = "vertex VertexOut vertexShader(const device VertexIn *vertexArray [[buffer(0)]],const device Uniform *uniformArray [[buffer(1)]], const device LineUniform *lineArray [[buffer(2)]], unsigned int vid [[vertex_id]]){VertexIn in = vertexArray[vid];VertexOut out; float scale = uniformArray[0].scale; if(vid<=1080){out.color = float4(1,1,1,1); float x = in.pos.x*scale; float y = in.pos.y*scale; out.pos = float4(x,y,0,1);}else{float x = in.pos.x*scale; float y = in.pos.y*scale; if(vid%2==0){out.color = float4(1,0,0,1);out.pos = float4(x,y,0,1);}else{unsigned int lid = (vid-1081)/2; LineUniform lineIn = lineArray[lid]; out.color = float4(0,0,1,1); out.pos = float4(x*lineIn.scale, y*lineIn.scale,0,1);};}; return out;};"
let fragmentShader = "fragment float4 fragmentShader(VertexOut interpolated [[stage_in]]){return interpolated.color;};"

public class Visualizer : UIView {
    private var engine : AVAudioEngine
    
    private var metalView : MTKView!
    private var metalDevice : MTLDevice!
    private var metalQueue : MTLCommandQueue!
    private var pipelineState: MTLRenderPipelineState!
    private var vertexBuffer: MTLBuffer!
    private var uniformBuffer: MTLBuffer!
    private var lineBuffer: MTLBuffer!
    
    struct VertexIn {
        var pos : simd_float2
    }
    
    struct Uniform {
        var scale : Float
    }
    
    struct LineUniform {
        var scale : Float
    }
    
    var uniform : [Uniform] = [Uniform(scale: 0.3)]
    var vertices : [VertexIn] = []

    let originVertice = VertexIn(pos: [0,0])
    
    var lineVertices : [VertexIn] = []
    var lineUniforms : [LineUniform] = []
    
    var scaleValue : Float? {
        didSet{
            print(Thread.current, "Scale didSet")
            uniform = [Uniform(scale: scaleValue!)]
            uniformBuffer = metalDevice.makeBuffer(bytes: uniform, length: uniform.count * MemoryLayout<Uniform>.stride, options: [])!
            metalView.draw()
        }
    }
    
    var lineMagnitudes : [Float]? {
        didSet{
            lineUniforms = []
            for mag in lineMagnitudes! {
                lineUniforms.append(LineUniform(scale: 1 + mag))
            }
            lineBuffer = metalDevice.makeBuffer(bytes: lineUniforms, length: lineUniforms.count * MemoryLayout<LineUniform>.stride, options: [])!
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
            
            let vertice = VertexIn(pos: position)
            vertices.append(vertice)
            lineVertices.append(vertice)
            lineVertices.append(vertice)
            
            lineUniforms.append(LineUniform(scale: 1))
        }
        vertices = vertices + lineVertices
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
        vertexBuffer = metalDevice.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<VertexIn>.stride, options: [])!
        uniformBuffer = metalDevice.makeBuffer(bytes: uniform, length: uniform.count * MemoryLayout<Uniform>.stride, options: [])!
        lineBuffer = metalDevice.makeBuffer(bytes: lineUniforms, length: lineUniforms.count * MemoryLayout<LineUniform>.stride, options: [])!
    }
    
    public func setupEngineTap(){
        engine.mainMixerNode.installTap(onBus: 0, bufferSize: 1024, format: nil) { (buffer, time) in
            print(Thread.current, "In TAP")
            AVCoordinator.shared.buffer = buffer
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

        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        renderEncoder.setVertexBuffer(lineBuffer, offset: 0, index: 2)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 1080)
        renderEncoder.drawPrimitives(type: .line , vertexStart: 1080, vertexCount: 1440)

        renderEncoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
    
    func buildRenderPipelineWith(device: MTLDevice, metalKitView: MTKView) throws -> MTLRenderPipelineState {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        let shader = top + vertexInStruct + uniformStruct + uniformLineStruct + vertexOutStruct + vertexShader + fragmentShader
        let library = try! device.makeLibrary(source: shader, options: nil)
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentShader")
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
        
        return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
}

