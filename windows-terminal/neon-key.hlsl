Texture2D shaderTexture;
SamplerState samplerState;
cbuffer PixelShaderSettings { float Time; float Scale; float2 Resolution; float4 Background; };

float isKey(float3 c) { return (c.r < 0.06 && c.b > 0.55) ? 1.0 : 0.0; }

float4 main(float4 pos : SV_POSITION, float2 tex : TEXCOORD) : SV_TARGET
{
  float4 color = shaderTexture.Sample(samplerState, tex);
  float2 px = 1.0 / Resolution;
  float3 glow = 0;
  [unroll] for (int x = -3; x <= 3; x++)
  [unroll] for (int y = -3; y <= 3; y++) {
    float3 s = shaderTexture.Sample(samplerState, tex + float2(x, y) * px * 2.0).rgb;
    glow += s * isKey(s);
  }
  color.rgb += (glow / 49.0) * 1.1;
  return color;
}
