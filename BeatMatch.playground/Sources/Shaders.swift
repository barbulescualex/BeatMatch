import Foundation

class MetalShaders {
    private let top = "#include <metal_stdlib>\n"+"#include <simd/simd.h>\n"+"using namespace metal;"
    private let vertexInStruct = "struct VertexIn {vector_float2 pos;};"
    private let vertexOutStruct = "struct VertexOut{float4 color; float4 pos [[position]];};"
    private let uniformStruct = "struct Uniform{float scale;};"
    private let uniformLineStruct = "struct LineUniform { float scale; };"
    private let vertexShader = "vertex VertexOut vertexShader(const device VertexIn *vertexArray [[buffer(0)]],const device Uniform *uniformArray [[buffer(1)]], const device LineUniform *lineArray [[buffer(2)]], unsigned int vid [[vertex_id]]){VertexIn in = vertexArray[vid];VertexOut out; float scale = uniformArray[0].scale; if(vid<1080){out.color = float4(1,1,1,1); float x = in.pos.x*scale; float y = in.pos.y*scale; out.pos = float4(x,y,0,1);}else{float x = in.pos.x*scale; float y = in.pos.y*scale; if(vid%2==0){out.color = float4(1,0,0,1);out.pos = float4(x,y,0,1);}else{unsigned int lid = (vid-1081)/2; LineUniform lineIn = lineArray[lid]; out.color = float4(0,0,1,1); out.pos = float4(x*lineIn.scale, y*lineIn.scale,0,1);};}; return out;};"
    private let fragmentShader = "fragment float4 fragmentShader(VertexOut interpolated [[stage_in]]){return interpolated.color;};"
    
    public func fetchLibraryString() -> String {
        let library = top + vertexInStruct + uniformStruct + uniformLineStruct + vertexOutStruct + vertexShader + fragmentShader
        return library
    }
}
