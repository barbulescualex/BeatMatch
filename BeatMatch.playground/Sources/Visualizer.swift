import UIKit
import AVFoundation
import MetalKit
import simd
import Accelerate

public class Visualizer : UIView {
    //MARK:- Vars
    private var engine : AVAudioEngine
    
    //MARK:- Metal Vars
    private var metalView : MTKView!
    private var metalDevice : MTLDevice!
    private var metalQueue : MTLCommandQueue!
    private var pipelineState: MTLRenderPipelineState!
    
    private var vertexBuffer: MTLBuffer!
    private var uniformBuffer: MTLBuffer!
    private var lineBuffer: MTLBuffer!
    
    //MARK:- Metal Structs
    struct VertexIn {
        var pos : simd_float2
    }
    
    struct Uniform {
        var scale : Float
    }
    
    struct LineUniform {
        var scale : Float
    }
    
    //MARK:- Struct Arrays
    var uniform : [Uniform] = [Uniform(scale: 0.3)]
    var vertices : [VertexIn] = []

    let originVertice = VertexIn(pos: [0,0])
    
    var lineVertices : [VertexIn] = []
    var lineUniforms : [LineUniform] = []
    
    //MARK:- Uniform Setters
    var scaleValue : Float? {
        didSet{
            uniform = [Uniform(scale: scaleValue!)]
            uniformBuffer = metalDevice.makeBuffer(bytes: uniform, length: uniform.count * MemoryLayout<Uniform>.stride, options: [])!
            lineUniforms = []
            metalView.draw()
        }
    }
    
    var lineMagnitudes : [Float]? {
        didSet{
            for mag in lineMagnitudes! {
                lineUniforms.append(LineUniform(scale: 1 + mag))
            }
            lineBuffer = metalDevice.makeBuffer(bytes: lineUniforms, length: lineUniforms.count * MemoryLayout<LineUniform>.stride, options: [])!
        }
    }
    
    //MARK:- Setup
    public required init(engine: AVAudioEngine) {
        self.engine = engine
        super.init(frame: .zero)
        makeVertices()
        setupView()
        //setupMetal()
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
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            let source = MetalShaders().fetchLibraryString()
            let library = try! metalDevice.makeLibrary(source: source, options: nil)
            pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexShader")
            pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentShader")
            
            pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
            
            pipelineState = try metalDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print(error)
        }

        //metal buffer
        vertexBuffer = metalDevice.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<VertexIn>.stride, options: [])!
        uniformBuffer = metalDevice.makeBuffer(bytes: uniform, length: uniform.count * MemoryLayout<Uniform>.stride, options: [])!
        lineBuffer = metalDevice.makeBuffer(bytes: lineUniforms, length: lineUniforms.count * MemoryLayout<LineUniform>.stride, options: [])!
    }
    
    public func setupEngineTap(){
        engine.mainMixerNode.installTap(onBus: 0, bufferSize: 2048, format: nil) { (buffer, time) in
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
        renderEncoder.drawPrimitives(type: .lineStrip , vertexStart: 1080, vertexCount: 1440)

        renderEncoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
}

