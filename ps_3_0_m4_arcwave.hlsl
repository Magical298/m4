#define PC
#define IS_VERTEX_SHADER 0
#define IS_PIXEL_SHADER 1
#include <shader_vars.h>

#define PROJMAP_BLENDOFFSET 0.25
#define PROJMAP_BLENDEXPONENT 1.5
#define PROJECTION_SCALE 32.0

struct PixelInput
{
    float4 position : POSITION;
    float3 worldPos : TEXCOORD1;
    float3 worldNormal : TEXCOORD2;
};

struct PixelOutput
{
    float4 color : COLOR;
};

float3 electricPlasma(float2 uv, float time)
{
    float flow = uv.x * 0.22 + uv.y * 0.11 - time;

    float turbulence =
        sin(uv.y * 0.55 +
        sin(uv.x * 0.31 - time * 0.7) * 1.8 +
        time * 1.6);

    float wave = sin(flow * 6.0 + turbulence * 2.0);

    float veins = pow(saturate(1.0 - abs(wave)), 10.0);

    float wisps = 0.5 + 0.5 * sin(
        uv.x * 0.9 - uv.y * 0.45 -
        time * 2.2 +
        sin(uv.y * 0.7 + time) * 1.5
    );

    float glow = saturate(
        veins * 1.2 + pow(wisps, 5.0) * 0.35
    );

    float hue = 0.5 + 0.5 * sin(flow * 1.5 - time * 0.8);

    float3 cyan = float3(0.02, 0.65, 1.0);
    float3 violet = float3(0.42, 0.05, 1.0);

    float3 energy = lerp(cyan, violet, hue);

    return energy * (0.18 + glow * 1.4);
}

PixelOutput ps_main(const PixelInput pixel)
{
    PixelOutput output;

    float phase = gameTime.w * 0.8;

    // Object-space triplanar projection.
    float2 uvFront = pixel.worldPos.yz * PROJECTION_SCALE;
    float2 uvSide  = pixel.worldPos.xz * PROJECTION_SCALE;
    float2 uvTop   = pixel.worldPos.xy * PROJECTION_SCALE;

    float3 blend = abs(pixel.worldNormal);

    blend = saturate(blend - PROJMAP_BLENDOFFSET);
    blend = pow(blend, PROJMAP_BLENDEXPONENT);
    blend /= max(blend.x + blend.y + blend.z, 0.0001);

    float3 colorFront = electricPlasma(uvFront, phase);
    float3 colorSide  = electricPlasma(uvSide, phase);
    float3 colorTop   = electricPlasma(uvTop, phase);

    float3 finalColor =
        blend.x * colorFront +
        blend.y * colorSide +
        blend.z * colorTop;

    output.color.rgb = finalColor;
    output.color.a = 0.35;

    return output;
}