// #import bevy_pbr::mesh_types
// Import the `globals` struct giving access to time
#import bevy_sprite::mesh2d_view_bindings

struct FragmentInput {
  #import bevy_sprite::mesh2d_vertex_output
};

fn sd_circle(p: vec2<f32>, r: f32) -> f32 {
    return length(p) - r;
}

fn sd_box(p: vec2<f32>, b: vec2<f32>) -> f32 {
    let d = abs(p) - b;
    return length(max(d, vec2(0.0, 0.0))) + min(max(d.x, d.y), 0.0);
}

fn palette(t: f32) -> vec3<f32> {
    let a = vec3(0.500, 0.500, 0.500);
    let b = vec3(0.500, 0.500, 0.500);
    let c = vec3(0.800, 0.800, 0.500);
    let d = vec3(0.000, 0.200, 0.500);

    return a + b * cos(6.28318 * (c * t + d));
}

@fragment
fn fragment(
    in: FragmentInput
) -> @location(0) vec4<f32> {
    // Make uv be between -1.0 and 1.0, with center in the middle and Y pointing up
    let uv0 = vec2(in.uv.x, 1.0 - in.uv.y) * 2.0 - 1.0;
    var uv = uv0;
    let t = globals.time;
    var final_color = vec3(0.0);

    for (var i = 0.0; i < 3.0; i += 1.0) {
        uv = fract(uv * 1.5) - 0.5;
        // Distance to origin
        var d = length(uv);
        d *= exp(-length(uv0));
        let col = palette(length(uv0) + i * 0.4 + t * 0.4);
        d = sin(d * 8.0 + t) / 8.0;
        d = abs(d);
        d = 0.005 / d;
        d = pow(d, 1.9);

        final_color += col * d;
    }
    return vec4(final_color, 1.0);
}
