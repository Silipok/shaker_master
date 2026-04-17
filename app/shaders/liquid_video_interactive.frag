#include <flutter/runtime_effect.glsl>

#define MAX_RIPPLES 8

uniform vec2 u_resolution;
uniform float u_time;

uniform float u_ripple_count;
uniform vec2 u_ripple_pos[MAX_RIPPLES];
uniform vec4 u_ripple_params[MAX_RIPPLES]; // (birth_t, amplitude, frequency, decay)

out vec4 fragColor;

float random(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {
    vec2 uv = FlutterFragCoord().xy / u_resolution;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= u_resolution.x / u_resolution.y;
    float time = u_time * 0.25;

    // Sum of analytic tap-ripples — each one is a radial damped sine wave
    // centred on its tap point.
    vec2 rippleWarp = vec2(0.0);
    int rippleCount = int(u_ripple_count);
    for (int i = 0; i < MAX_RIPPLES; ++i) {
        if (i >= rippleCount) break;
        vec2 c = u_ripple_pos[i] * 2.0 - 1.0;
        c.x *= u_resolution.x / u_resolution.y;
        vec4 prm = u_ripple_params[i];
        float birth = prm.x;
        float amp = prm.y;
        float freq = prm.z;
        float decay = prm.w;
        float age = max(u_time - birth, 0.0);
        vec2 d = p - c;
        float r = length(d) + 1e-4;
        float envelope = exp(-decay * age) * amp;
        float wave = sin(freq * r - age * 6.2831);
        rippleWarp += (d / r) * envelope * wave;
    }

    // Domain warp (keep subtle so diagonal folds read cleanly).
    vec2 warp = vec2(0.0);
    warp.x = sin(p.y * 2.0 + time) * 0.2 + cos(p.x * 1.5 - time) * 0.15;
    warp.y = cos(p.x * 2.0 + time) * 0.2 + sin(p.y * 1.5 + time) * 0.15;
    warp += rippleWarp * 2.2;

    // Strict 45° rotation so folds run diagonally.
    float angle = -0.785398;
    float s = sin(angle);
    float c = cos(angle);
    mat2 rot = mat2(c, -s, s, c);
    vec2 rp = rot * (p + warp * 0.25);

    // Silk-fold pattern along the rotated X axis.
    float flow = sin(rp.x * 6.0 - time * 1.5);
    flow += cos(rp.x * 11.0 + rp.y * 2.0 + time * 1.2) * 0.4;
    flow += sin(rp.x * 18.0 - time * 1.8) * 0.2;

    float v = (flow / 3.2) + 0.5;

    // Green palette (matches the non-interactive liquid_video.frag).
    vec3 colDark  = vec3(0.02, 0.10, 0.08);
    vec3 colBase  = vec3(0.04, 0.22, 0.14);
    vec3 colGlow  = vec3(0.00, 0.65, 0.42);
    vec3 colLight = vec3(0.35, 0.95, 0.65);

    vec3 color = mix(colDark, colBase, smoothstep(0.1, 0.45, v));

    float glow = smoothstep(0.45, 0.75, v);
    color = mix(color, colGlow, glow);

    float peak = smoothstep(0.85, 1.0, v);
    color = mix(color, colLight, pow(peak, 2.5));

    float vignette = length(uv - 0.5) * 1.5;
    color *= 1.0 - vignette * 0.2;

    float noise = (random(uv + fract(u_time)) - 0.5) * 0.04;
    color += noise;

    fragColor = vec4(clamp(color, 0.0, 1.0), 1.0);
}
