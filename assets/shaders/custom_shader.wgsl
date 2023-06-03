// This import gives us access to 2 global uniforms:
// - `globals`, which contains time information:
//    - `time: f32`: time since startup in seconds
//    - `delta_time: f32`: time since the previous frame in seconds
//    - `frame_count: u32`: the number of frames since startup
// - `view`, which contains information about the viewport (viewport size,
//    projection matrics, etc...). See
//    https://github.com/bevyengine/bevy/blob/main/crates/bevy_render/src/view/view.wgsl
//    for the current definition.
#import bevy_sprite::mesh2d_view_bindings

// For convenience, define a `FragmentInput` struct to hold all the inputs that
// are passed in to our fragment shader, and coming from the default vertex
// shader. Of interest are:
// - world_position: vec4<f32>,
// - world_normal: vec3<f32>,
// - uv: vec2<f32>,
//
// See
// https://github.com/bevyengine/bevy/blob/main/crates/bevy_sprite/src/mesh2d/mesh2d_vertex_output.wgsl
// for the full list.
struct FragmentInput {
  #import bevy_sprite::mesh2d_vertex_output
};

struct CustomMaterial {
  spatial_repetition: f32,
  iterations: u32,
}

@group(1) @binding(0)
var<uniform> material: CustomMaterial;

// Some examples of plain old functions.
//
// For instance here are a couple of signed distance field functions.
fn sd_circle(p: vec2<f32>, r: f32) -> f32 {
    return length(p) - r;
}

fn sd_box(p: vec2<f32>, b: vec2<f32>) -> f32 {
    let d = abs(p) - b;
    return length(max(d, vec2(0.0, 0.0))) + min(max(d.x, d.y), 0.0);
}

// Function to smoothly, and periodically, transition between a bunch of
// colours.
//
// See http://dev.thi.ng/gradients/ to generate such gradiants
fn palette(t: f32) -> vec3<f32> {
    let a = vec3(0.500, 0.500, 0.500);
    let b = vec3(0.500, 0.500, 0.500);
    let c = vec3(0.800, 0.800, 0.500);
    let d = vec3(0.000, 0.200, 0.500);

    return a + b * cos(6.28318 * (c * t + d));
}

// This is the entry point of our fragment shader.
//
// This particular shader is adapted from this video, which is a great
// introduction to shaders: https://www.youtube.com/watch?v=f4s1h2YETNY
@fragment
fn fragment(
    in: FragmentInput,
) -> @location(0) vec4<f32> {
    // Make uv0 be between -1.0 and 1.0, with center in the middle and Y pointing up
    let uv0 = vec2(in.uv.x, 1.0 - in.uv.y) * 2.0 - 1.0;
    var uv = uv0;
    let t = globals.time;
    var final_color = vec3(0.0);

    for (var i = 0u; i < material.iterations; i++) {
        uv = fract(uv * material.spatial_repetition) - 0.5;
        // Distance to origin
        var d = length(uv);
        d *= exp(-length(uv0));
        let col = palette(length(uv0) + f32(i) * 0.4 + t * 0.4);
        d = sin(d * 8.0 + t) / 8.0;
        d = abs(d);
        d = 0.005 / d;
        d = pow(d, 1.9);

        final_color += col * d;
    }
    return vec4(final_color, 1.0);
}
