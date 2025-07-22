// LÖVE2D Shader Conversion

//original shader here: https://www.shadertoy.com/view/tl2yRm

#define Rot(a) mat2(cos(a),-sin(a),sin(a),cos(a))
#define antialiasing(n) n / min(iResolution.y, iResolution.x)
#define S(d, b) smoothstep(antialiasing(1.0), b, d)
#define matRotateZ(rad) mat3(cos(rad), -sin(rad), 0, sin(rad), cos(rad), 0, 0, 0, 1)

extern vec2 iResolution; // Screen resolution
extern number iTime;     // Time in seconds

// Distance functions
float sdBox(vec2 p, vec2 b) {
    vec2 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float sdCappedCylinder(vec3 p, float h, float r) {
    vec2 d = abs(vec2(length(p.xz), p.y)) - vec2(h, r);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

// Transformation
vec3 Transform(vec3 p, float angle) {
    p.xz *= Rot(angle);
    p.xy *= Rot(angle * 0.7);
    return p;
}

// Confetti function
float Confetti(vec3 ro, vec3 rd, vec3 pos, float angle, int type) {
    float t = dot(pos - ro, rd);
    vec3 p = ro + rd * t;
    float y = length(pos - p);
    vec2 bsize = vec2(0.2, 0.25);
    float d = 1.0;

    if (type == 0 && y < 1.0) {
        float x = sqrt(1.0 - y);

        vec3 pF = ro + rd * (t - x) - pos;
        pF = Transform(pF, angle);
        vec2 uvF = vec2(atan(pF.x, pF.z), pF.y);
        float f = sdBox(uvF, bsize);

        vec3 pB = ro + rd * (t + x) - pos;
        pB = Transform(pB, angle);
        vec2 uvB = vec2(atan(pB.x, pB.z), pB.y);
        float b = sdBox(uvB, bsize);

        d = min(f, b);
    }

    y = sdCappedCylinder((pos - p) * matRotateZ(radians(90.0)), 0.3, 0.001);
    bsize = vec2(1.0, 0.02);

    if (type == 1 && y < 0.07) {
        p = pos - p;

        vec2 uv = p.xy;
        uv *= Rot(radians(30.0));
        uv.y -= iTime * 0.2;

        uv.y = mod(uv.y, 0.1) - 0.05;
        d = sdBox(uv, bsize);
    }

    return d;
}

vec4 effect(vec4 color, Image texture, vec2 texcoords, vec2 screencoords) {
    vec2 uv = (screencoords - 0.5 * iResolution) / iResolution.y;
    vec3 ro = vec3(0.0, 0.0, -3.0);
    vec3 rd = normalize(vec3(uv, 1.0));

    vec3 bg = 0.9 * max(mix(vec3(1.2) + (0.1 - length(uv.xy) / 3.0), vec3(1.0), 0.1), 0.0);
    vec4 col = vec4(bg, 0.0);

    for (float i = 0.0; i < 1.0; i += 1.0 / 60.0) {
        float x = mix(-8.0, 8.0, fract(i));
        float y = mix(-5.0, 5.0, fract(sin(i * 564.3) * 4570.3 - iTime * 0.3));
        float z = mix(5.0, 0.0, i);
        float a = iTime + i * 563.34;
        float ratio = clamp(fract(sin(i * 1564.3) * 9570.3), 0.0, 1.0);
        int type = (i < ratio) ? 0 : 1;

        vec3 ccol = 0.5 + 0.5 * cos(iTime + uv.xyx + vec3(i, 2.0, 4.0));
        float confetti = Confetti(ro, rd, vec3(x, y, z), a, type);
        col = mix(col, vec4(ccol, 1.0), S(confetti, 0.0));
    }

    return col;
}
